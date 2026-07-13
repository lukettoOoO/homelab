# Optimization (Multi-stage Builds)

- Docker images can be bigger than they should be
- The bigger the image, the bigger the bandwidth and storage consumed
- We don't wanna ship our build tools and source code in the image that we deploy
- Example:
    - When using a compiled langauge (like Go), we need the whole SDK to generate the binary file
    - In a simple build, all the SDK elements remain in the final image:
    ```dockerfile
    FROM golang:1.22

    WORKDIR /app
    COPY main.go .

    # Compiling the binary inside the image
    RUN go build -o myapp main.go

    # App runs in the same enironment as Go SDK, which is inefficient
    CMD ["./myapp"]
    ```
    - The final image will have over **800 MB**, although the compiled binary is only 15-20 MB. The space is occupied by the Go compiler and its dependencies, completely useless during runtime
    - The solution is a multi-stage build:
    ```dockerfile
    # stage 1: compiling
    FROM golang:1.22 AS builder
    WORKDIR /src
    COPY main.go .
    RUN CGO_ENABLED=0 GOOS=linux go build -o myapp main.go

    # stage 2: the final production image
    # this resets everything
    FROM alpine:3.20
    WORKDIR /app
    # copying the previous compiled binary to current working directory
    COPY --from=builder /src/myapp .
    CMD ["./myapp"]
    ```
- The `FROM` statements separate the stages, as the build starts fresh from there

- Scratch is an empty image that can run compiled binaries
- We can also use multi-stage builds to take advantage of caching in our own build process
- A third stage can be used to cache dependencies
- External images can be used using `COPY --from` either using the local image name, a tag available locally or on a Docker registry, or a tag ID
```dockerfile
COPY --from=nginx:latest /etc/nginx/nginx.conf /nginx.conf
``
- A previous stage can be used as a new stage:
```dockerfile
# syntax=docker/dockerfile:1

FROM alpine:latest AS builder
RUN apk --no-cache add build-base

FROM builder AS build1
COPY source1.cpp source.cpp
RUN g++ -o /binary source.cpp

FROM builder AS build2
COPY source2.cpp source.cpp
RUN g++ -o /binary source.cpp
```
- Example:

