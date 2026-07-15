# set base image as python 3.11 slim
FROM python:3.11-slim

# set working directory to /app
WORKDIR /app

# install dependencies
RUN apt-get update && apt-get install -y iputils-ping curl

# copy the network_monitor.py local script to the container
COPY network_monitor.py /app/

# set the command to run the network_monitor.py script when the container starts
CMD ["python", "network_monitor.py"]