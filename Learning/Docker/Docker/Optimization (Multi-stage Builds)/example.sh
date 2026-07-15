# Build the multi-stage image (see example_dockerfile)
docker build -t hello .

# We can stop at specific build stages (see example_dockerfile1)
docker build --target build -t hello .

