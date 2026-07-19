# Docker Compose Lifecycle

| Command | Description | Common Use Case |
| :--- | :--- | :--- |
| **`docker compose up`** | Builds, creates, and starts containers. | Use `-d` to run in the background. |
| **`docker compose down`** | Stops and removes containers, networks, and volumes. | Use `-v` to wipe persistent data volumes. |
| **`docker compose ps`** | Lists running containers and their status. | Perfect for checking ports and health. |
| **`docker compose logs`** | Displays log output from all services. | Use `-f` to stream logs in real-time. |
| **`docker compose build`** | Builds or rebuilds images from Dockerfiles. | Run after modifying local source code. |
| **`docker compose exec`** | Runs a command inside a running container. | `docker compose exec web bash` |
| **`docker compose run`** | Runs a one-off command in a new container. | Great for database migrations. |
| **`docker compose restart`** | Restarts services without recreating them. | `docker compose restart <service_name>` |
| **`docker compose stop`** | Stops running containers without removing them. | Bring them back with `docker compose start`. |
| **`docker compose config`** | Validates and renders the final Compose file. | Useful for debugging multi-file setups. |