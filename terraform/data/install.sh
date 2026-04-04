#!/bin/bash

# Updated packages on linux machine
yum update -y 

# # install & start httpd server 
# yum install -y httpd
# systemctl enable httpd
# systemctl start httpd
# echo "<h1> Hello word from $(hostname -f)</h1>" > /var/www/html/index.html 

# install and start docker 
yum install -y docker
usermod -aG docker ec2-user
systemctl enable docker.service
systemctl start docker.service
systemctl status docker.service

# Login to ECR
ECR_REPO_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${ECR_REPO_NAME}"
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin $ECR_REPO_URI

# install nfs-utils
yum install -y amazon-efs-utils  

# Mount the EFS Volume on the Host
mkdir -p /mnt/efs
mount -t efs -o tls ${EFS_ID}:/ /mnt/efs

# assign read/write permissions to container user 
chown -R 1000:1000 /mnt/efs  # if container runs as UID 1000

# docker create network
docker network create web-network

# start mongodb container 
docker pull mongo
docker run -d --name mongodb -p 27017:27017 -e MONGO_INITDB_ROOT_USERNAME=mongoadmin -e MONGO_INITDB_ROOT_PASSWORD=secret --network web-network -v /mnt/efs:/data/db mongo

# start app container 
IMAGE=$ECR_REPO_URI:myapp
docker pull $IMAGE
docker run -d -p 80:3000 --name myapp --network web-network $IMAGE
