#!/bin/bash

# Set Kong Admin API URL
KONG_ADMIN_URL="http://localhost:8001"

echo "🚀 Setting up Kong API Rate Limiting..."

# 1️⃣ Create an API Service
echo "🔹 Creating API Service..."
curl -X POST $KONG_ADMIN_URL/services/ \
  --data "name=my-api" \
  --data "url=http://mockbin.org/request"

# 2️⃣ Create a Route for the Service
echo "🔹 Creating API Route..."
curl -X POST $KONG_ADMIN_URL/services/my-api/routes \
  --data "paths[]=/my-api"

# 3️⃣ Enable Global Rate Limiting for the API
echo "🔹 Applying Rate Limiting Plugin to Service..."
curl -X POST $KONG_ADMIN_URL/services/my-api/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.policy=redis" \
  --data "config.redis_host=redis"

# 4️⃣ Create a Consumer for API Key-Based Rate Limiting
echo "🔹 Creating API Consumer..."
curl -X POST $KONG_ADMIN_URL/consumers/ \
  --data "username=my-consumer"

# 5️⃣ Apply Rate Limiting Per Consumer (API Key-Based)
echo "🔹 Applying Rate Limiting Plugin to Consumer..."
curl -X POST $KONG_ADMIN_URL/consumers/my-consumer/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=50" \
  --data "config.policy=redis" \
  --data "config.redis_host=redis"

# 6️⃣ Enable Rate Limiting for a Specific Route
echo "🔹 Applying Rate Limiting Plugin to Route..."
curl -X POST $KONG_ADMIN_URL/routes/my-api-route/plugins \
  --data "name=rate-limiting" \
  --data "config.hour=500" \
  --data "config.policy=cluster"

echo "✅ Kong API Rate Limiting Setup Completed!"

