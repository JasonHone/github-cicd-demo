#!/bin/bash
# zabbix-gate-check.sh

# 1. 解析参数
TRIGGER_NAME=${1:-"Linux: High CPU utilization"}
ZABBIX_URL=${2:-"http://zabbix-server-zabbix-web.monitoring.svc.cluster.local/api_jsonrpc.php"}
ZABBIX_USER=${3:-"Admin"}
ZABBIX_PASS=${4:-"zabbix"}
# TRIGGER_NAME=${5:-"Linux: High CPU utilization"}

if [ -z "$TRIGGER_NAME" ]; then
    echo "❌ 错误：请提供要检查的 Zabbix 触发器名称作为参数。"
    exit 1
fi

echo "🔑 正在登录 Zabbix API..."
# 2. 获取 Auth Token
# 获取原始响应
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {"username": "'"$ZABBIX_USER"'", "password": "'"$ZABBIX_PASS"'"},
    "id": 1
}' "$ZABBIX_URL")

echo "🔍 Zabbix API 原始返回结果: $RESPONSE"

# 提取 Token
AUTH_TOKEN=$(echo "$RESPONSE" | jq -r '.result')

if [ "$AUTH_TOKEN" == "null" ] || [ -z "$AUTH_TOKEN" ]; then
    echo "❌ Zabbix 登录失败！请检查 URL、用户名或密码。"
    exit 1
fi

echo "🔍 正在检查触发器状态: [$TRIGGER_NAME]..."
# 3. 查询触发器状态
# value=1 表示 PROBLEM 状态
PROBLEM_COUNT=$(curl -s -X POST -H "Content-Type: application/json" -d '{
    "jsonrpc": "2.0",
    "method": "trigger.get",
    "params": {
        "output": ["description", "value"],
        "search": {"description": "'"$TRIGGER_NAME"'"},
        "only_true": true
    },
    "auth": "'"$AUTH_TOKEN"'",
    "id": 2
}' "$ZABBIX_URL" | jq '.result | length')

# 4. 判断门禁结果
if [ "$PROBLEM_COUNT" -gt 0 ]; then
    echo "❌ 门禁未通过！检测到 Zabbix 存在活跃告警 [$TRIGGER_NAME]，准备回滚..."
    exit 1
fi

echo "✅ 门禁通过！Zabbix 当前无相关异常告警，继续发布流程。"
exit 0