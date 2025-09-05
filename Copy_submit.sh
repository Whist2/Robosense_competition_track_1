#!/bin/bash
#SBATCH -p L40
#SBATCH -n 1
#SBATCH --cpus-per-task=7
#SBATCH --gres=gpu:l40:1
#SBATCH --job-name=robosense
#SBATCH -t 5:00:00
#SBATCH -o robosense_%j.out
#SBATCH -e robosense_%j.err

cd /share/home/u22537/data/DXW/track1-main

source ~/.bashrc
conda activate drive

# 启动 vLLM 服务（后台运行）
echo "🚀 启动 vLLM 服务..."
bash service.sh 1 > service.log 2>&1 &

# 等待服务响应 /v1/models 接口，最多尝试 60 次（大约 5 分钟）
echo "⏳ 等待 vLLM 接口 http://localhost:8000/v1/models 可访问..."
MAX_RETRIES=80
RETRY_INTERVAL=5
RETRY_COUNT=0

until curl -s http://localhost:8000/v1/models | grep -q "object"; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "❌ vLLM 服务在规定时间内未启动。退出任务。"
        exit 1
    fi
    echo "等待中（尝试 $RETRY_COUNT/$MAX_RETRIES）..."
    sleep $RETRY_INTERVAL
done

echo "✅ vLLM 服务可用，开始执行推理任务..."

# 启动推理脚本
bash inference.shnull
