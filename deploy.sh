#!/bin/bash
set -e

# ========== 修改这里为你自己的参数 ==========
ECR_REPO_URI="226503510091.dkr.ecr.ap-northeast-1.amazonaws.com/github-cicd-demo"
CONTAINER_NAME="github-cicd-demo"
IMAGE_TAG=$(cat /home/ec2-user/deploy/version.txt)
echo "当前部署镜像标签：${IMAGE_TAG}"
HOST_PORT=8080
CONTAINER_PORT=8080
# ============================================

# 登录ECR
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${ECR_REPO_URI}

# 拉取新镜像
docker pull ${ECR_REPO_URI}:${IMAGE_TAG}

# 停止并删除旧容器，忽略不存在报错
if docker ps -a --filter "name=^/${CONTAINER_NAME}$" | grep -q ${CONTAINER_NAME};then
    docker stop ${CONTAINER_NAME}
    docker rm ${CONTAINER_NAME}
fi

# 启动新容器
docker run -d \
  --name ${CONTAINER_NAME} \
  -p ${HOST_PORT}:${CONTAINER_PORT} \
  --restart always \
  ${ECR_REPO_URI}:${IMAGE_TAG}

# 简单健康检查，等待启动
sleep 5
if ! docker ps --filter "name=^/${CONTAINER_NAME}$" --filter "status=running" | grep -q ${CONTAINER_NAME};then
  echo "ERROR：容器启动失败"
  exit 1
fi

echo "✅部署完成，容器正常运行"