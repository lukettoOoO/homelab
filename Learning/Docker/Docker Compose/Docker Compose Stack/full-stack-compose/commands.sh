mkdir full-stack-compose
cd full-stack-compose
nano docker-compose.yaml
sudo docker compose up -d
sudo docker exec -it homelab-app bash -c "cat < /dev/tcp/db/5432"
sudo docker exec -it homelab-proxy sh -c "cat < /dev/tcp/db/5432"
sudo docker compose down
