# Docker Compose

- `docker run` command:
```bash
docker run -d \
--name mongodb \
-p 27017:27017 \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=password \
--net mongo-network \
mongo
```

- `mongo-docker-compose.yaml`:
```yaml
version: '3'
services:
  mongodb:
    image: mongo
    ports:
      - 27017:27017
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password
```

`version` - Version of Docker Compose used
`services` - List of used container names
`image` - Image that the container is going to be built from
`ports` - `host:container` port mapping
`environment` - Environment variable mapping

- Docker Compose is a structured way of running multiple Docker commands
- Docker Compose takes care of creating a common network
- Indentation in `.yaml` files is important

`docker-compose -f [FILE] up` - Start all the containers in the `.yaml` file (ex. `docker-compose -f mongo.yaml up`)
`docker-compose -f [FILE] down` - Stop all the containers in the `.yaml`, also removes the created network
`docker compose stop` - Preserves the containers so data survives, but it is not reliable in production

- `.dockerignore` file can be used to keep unecessary files out of the build context

```yaml
services:
  web:
    build: .
    ports:
      - "${APP_PORT}:5000"
    environment:
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
    depends_on:
      redis:
        condition: service_healthy

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
```
- The `healthcheck` block tells Compose how to test whether Redis is ready:
    - `test` is the command Compose runs inside the container to check its health. `redis-cli ping` connects to Redis and expects a `PONG` response — if it gets one, the container is healthy.
    - `start_period` gives Redis 10 seconds to initialize before health checks begin. Any failures during this window don't count toward the retry limit.
    - `interval` runs the check every 5 seconds after the start period has elapsed.
    - `timeout` gives each check 3 seconds to respond before treating it as a failure.
    - `retries` sets how many consecutive failures are allowed before Compose marks the container as unhealthy. With `interval: 5s` and `retries: 5`, Compose will wait up to 25 seconds before giving up.

```yaml
services:
  web:
    build: .
    ports:
      - "${APP_PORT}:5000"
    environment:
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
    depends_on:
      redis:
        condition: service_healthy
    develop:
      watch:
        - action: sync+restart
          path: .
          target: /code
        - action: rebuild
          path: requirements.txt

  redis:
    image: redis:alpine
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
```

- The `watch` block defines two rules:
    - The `sync+restart` action watches the project directory (`.`) on the host. When a file changes, Compose copies any changed files into `/code` inside the running container, then, restarts the container. Because the container restarts with the updated files already in place, Flask starts up reading the new code directly - no manual rebuild or restart needed.
    - The `rebuild` action on `requirements.txt` triggers a full image rebuild whenever we add a new dependency, since intalling packages requires rebuilding the image, not just syncing files

```yaml
services:
  web:
    build: .
    ports:
      - "${APP_PORT}:5000"
    environment:
      - REDIS_HOST=${REDIS_HOST}
      - REDIS_PORT=${REDIS_PORT}
    depends_on:
      redis:
        condition: service_healthy
    develop:
      watch:
        - action: sync+restart
          path: .
          target: /code
        - action: rebuild
          path: requirements.txt

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s

volumes:
  redis-data:
```
- The `redis-data:/data` entry under `redis.volumes` mounts the named volume at `/data`, the path where Redis writes its data files
- The The top-level `volumes` key registers it with Docker so it persists between `compose down` and `compose up` cycles.
- Volumes of the containers can be reset using `docker compose down -v`

- A single `compose.yaml` becomes harder to maintain, as an application grows. The `include` top-level element lets us split services across multiple files while keeping them part of the same application.

- For stack inspection, we can verify vefore starting Compose using the `docker compose config` command if Compose has resolved all `.env` variables and merged all files correctly
- Starting the stack in detached mode: `docker compose up -d`
- Streaming logs from all services: `docker compose logs -f`
- Streaming logs from a single service: `docker compose logs -f web`
- `docker compose exec` runs a command inside an already-running container without starting a new one. Examples:
    - `docker compose exec web env | grep REDIS`
    - `docker compose exec web python -c "import redis; r = redis.Redis(host='redis'); print(r.ping())"`
    - `docker compose exec redis redis-cli GET hits`
- To list all the services along with their current status: `docker compose ps`



