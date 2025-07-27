#!/bin/bash

# Allora Worker Node Health Check Script for macOS
# Tests the worker node API functionality

echo "🔍 Allora Worker Node Health Check"
echo "==================================="

# Check if an argument is provided
if [ -z "$1" ]; then
  # Prompt for topic input if no argument is provided
  read -p "Enter topic (default: allora-topic-1-worker): " TOPIC
  TOPIC=${TOPIC:-allora-topic-1-worker}
else
  # Use the provided argument as the topic
  TOPIC=$1
fi

# Parse TOPIC_ID
TOPIC_ID=$(echo "$TOPIC" | awk -F'-' '{print $NF}')
echo "📊 Parsed TOPIC_ID: $TOPIC_ID"

# Determine the token based on TOPIC_ID
case "$TOPIC_ID" in
  1) TOKEN="ETH" ;;
  2) TOKEN="ETH" ;;
  3) TOKEN="BTC" ;;
  4) TOKEN="BTC" ;;
  5) TOKEN="SOL" ;;
  6) TOKEN="SOL" ;;
  7) TOKEN="ETH" ;;
  8) TOKEN="BNB" ;;
  9) TOKEN="ARB" ;;
  *) TOKEN="ETH" ;; # Default action set to ETH for invalid TOPIC_ID
esac

echo "💰 Token: $TOKEN"

# Get the current block height
echo "🔗 Fetching current block height..."
block_height=$(curl -s https://allora-rpc.testnet.allora.network/block | jq -r .result.block.header.height)

if [ -z "$block_height" ] || [ "$block_height" = "null" ]; then
    echo "❌ Failed to fetch block height from network"
    block_height="1000000"  # Use fallback value
    echo "⚠️  Using fallback block height: $block_height"
else
    echo "✅ Current block height: $block_height"
fi

echo ""
echo "🚀 Testing worker node API..."
echo "Endpoint: http://localhost:6000/api/v1/functions/execute"
echo "Topic ID: $TOPIC_ID"
echo "Token: $TOKEN"
echo ""

# Perform the curl request with the parsed topic and block height
response=$(curl --silent --location 'http://localhost:6000/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "'$TOPIC_ID'",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "'$TOKEN'"
            },
            {
                "name": "ALLORA_BLOCK_HEIGHT_CURRENT",
                "value": "'$block_height'"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 10
    }
}')

# Check if response is empty
if [ -z "$response" ]; then
    echo "❌ No response from worker node API"
    echo "🔍 Troubleshooting steps:"
    echo "   1. Check if worker service is running: ./scripts/manage_services.sh status worker"
    echo "   2. Check worker logs: ./scripts/manage_services.sh logs worker"
    echo "   3. Verify Docker containers: docker ps"
    echo "   4. Check port 6000: lsof -i :6000"
    exit 1
fi

# Print the response
echo "📄 Response:"
echo "$response" | jq . 2>/dev/null || echo "$response"

# Parse and validate the response
echo ""
echo "🔍 Response Analysis:"
echo "===================="

# Check if jq is available and response is valid JSON
if command -v jq >/dev/null 2>&1 && echo "$response" | jq . >/dev/null 2>&1; then
    # Extract code from response
    code=$(echo "$response" | jq -r '.code // empty')
    
    if [ "$code" = "200" ]; then
        echo "✅ Status Code: $code (SUCCESS)"
        
        # Try to extract inference value
        inference_value=$(echo "$response" | jq -r '.results[0].result.stdout // empty' 2>/dev/null | grep -o '"infererValue": "[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$inference_value" ]; then
            echo "💡 Inference Value: $inference_value"
            echo "🎉 Worker node is functioning correctly!"
        else
            echo "⚠️  Could not extract inference value from response"
        fi
        
        # Show peers if available
        peers=$(echo "$response" | jq -r '.results[0].peers[]? // empty' 2>/dev/null)
        if [ -n "$peers" ]; then
            echo "🌐 Connected Peers:"
            echo "$peers" | while read -r peer; do
                echo "   • $peer"
            done
        fi
        
    else
        echo "❌ Status Code: $code (ERROR)"
        echo "🚨 Worker node returned an error response"
    fi
else
    echo "⚠️  Response is not valid JSON or jq not available"
    echo "Raw response: $response"
fi

echo ""
echo "🔧 Additional Checks:"
echo "===================="

# Check if Docker is running
if docker ps >/dev/null 2>&1; then
    echo "✅ Docker is running"
    
    # Check for worker containers
    worker_containers=$(docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "(worker|allora)" || echo "None found")
    echo "🐳 Worker containers:"
    echo "$worker_containers"
else
    echo "❌ Docker is not running or not accessible"
fi

# Check if port 6000 is listening
if lsof -i :6000 >/dev/null 2>&1; then
    echo "✅ Port 6000 is listening"
else
    echo "❌ Port 6000 is not listening"
fi

echo ""
echo "✨ Health check completed!"
