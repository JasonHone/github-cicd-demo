#!/bin/bash
# rollback.sh

# 1. 解析传入的环境变量或参数
DEPLOYMENT_NAME=${1:-"aws-cicd-demo"}
NAMESPACE=${2:-"k8s-cicd"}
APP_NAME=${3:-"aws-cicd-demo"}

if [ -z "$DEPLOYMENT_NAME" ]; then
    echo "❌ 错误：请提供 Deployment 名称作为参数。"
    exit 1
fi

echo "🚨 触发紧急回滚机制！"
echo "🔄 正在将 Deployment [$DEPLOYMENT_NAME] 回退到上一个稳定版本..."

# 2. 执行 K8s 回滚命令
kubectl rollout undo deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE}

# 3. 等待回滚完成（设置 120 秒超时）
echo "⏳ 等待回滚完成..."
if kubectl rollout status deployment/${DEPLOYMENT_NAME} -n ${NAMESPACE} --timeout=120s; then
    echo "✅ 回滚成功！服务已恢复到上一个稳定状态。"

    # --- 扩展：发送回滚成功通知 (可选) ---
    # curl -X POST "你的钉钉/企微机器人Webhook地址" \
    # -H "Content-Type: application/json" \
    # -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"⚠️ 应用 [$APP_NAME] 灰度发布失败，已自动回滚成功！\"}}"

    exit 0
else
    echo "❌ 回滚超时或失败！请立即人工介入排查！"

    # --- 扩展：发送回滚失败告警 (可选) ---
    # curl -X POST "你的钉钉/企微机器人Webhook地址" \
    # -H "Content-Type: application/json" \
    # -d "{\"msgtype\": \"text\", \"text\": {\"content\": \"🔥 严重故障：应用 [$APP_NAME] 自动回滚失败！请立即人工介入！\"}}"

    exit 1
fi