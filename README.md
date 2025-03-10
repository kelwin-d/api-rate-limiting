# api-rate-limiting
API Rate Limiting in Kong, Apache APISIX, and Azure API Management

This repository will provide hands-on implementations of API Rate Limiting across three API Gateways:

✅ Kong API Gateway (Redis-based Rate Limiting)

✅ Apache APISIX (LuaJIT-powered Rate Limiting)

✅ Azure API Management (APIM) (Managed Quota & Throttling)

📌 Folder Structure for the GitHub Repo

api-rate-limiting/
│── kong/               # Kong API Gateway Rate Limiting
│   ├── docker-compose.yml
│   ├── kong.yml
│   ├── setup.sh
│   ├── README.md
│
│── apisix/             # Apache APISIX Rate Limiting
│   ├── docker-compose.yml
│   ├── config.yaml
│   ├── setup.sh
│   ├── README.md
│
│── azure-apim/         # Azure API Management Rate Limiting
│   ├── policies.xml
│   ├── setup.md
│   ├── README.md
│
│── app.py              # Simple Flask API for testing rate limits
│── README.md           # Main documentation

📌 1️⃣ Kong API Gateway: Implementing Rate Limiting

🛠 Step 1: Deploy Kong with Redis Using Docker

kong/docker-compose.yml

version: "3.8"
services:
  kong-database:
    image: postgres:13
    environment:
      POSTGRES_USER: kong
      POSTGRES_DB: kong
      POSTGRES_PASSWORD: kong

  kong:
    image: kong/kong-gateway:latest
    depends_on:
      - kong-database
      - redis
    environment:
      KONG_DATABASE: postgres
      KONG_PG_HOST: kong-database
      KONG_PROXY_LISTEN: "0.0.0.0:8000"
      KONG_ADMIN_LISTEN: "0.0.0.0:8001"
      KONG_PLUGINS: bundled,rate-limiting
    ports:
      - "8000:8000"
      - "8001:8001"

  redis:
    image: redis:latest
    ports:
      - "6379:6379"

🛠 Step 2: Apply Rate Limiting via Kong Admin API

kong/setup.sh

curl -X POST http://localhost:8001/services/ \
  --data "name=my-api" \
  --data "url=http://mockbin.org/request"

curl -X POST http://localhost:8001/services/my-api/plugins \
  --data "name=rate-limiting" \
  --data "config.minute=100" \
  --data "config.policy=redis" \
  --data "config.redis_host=redis"
📌 2️⃣ Apache APISIX: Implementing Rate Limiting

🛠 Step 1: Deploy APISIX with Redis

apisix/docker-compose.yml

version: "3.8"
services:
  etcd:
    image: bitnami/etcd
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes

  apisix:
    image: apache/apisix:latest
    depends_on:
      - etcd
      - redis
    ports:
      - "9080:9080" # API Gateway
      - "9180:9180" # Admin API

  redis:
    image: redis:latest
    ports:
      - "6379:6379"

🛠 Step 2: Apply Rate Limiting via APISIX Admin API

apisix/setup.sh

curl -X PUT http://localhost:9180/apisix/admin/routes/1 \
  -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" \
  -d '{
    "uri": "/my-api",
    "plugins": {
      "limit-count": {
        "count": 100,
        "time_window": 60,
        "redis_host": "redis",
        "policy": "redis"
      }
    },
    "upstream": {
      "type": "roundrobin",
      "nodes": {
        "httpbin.org:80": 1
      }
    }
  }'

📌 3️⃣ Azure API Management (APIM): Implementing Rate Limiting

🛠 Step 1: Apply Rate Limiting Policy in Azure APIM

azure-apim/policies.xml

<inbound>
    <rate-limit-by-key 
        calls="100" 
        renewal-period="60" 
        counter-key="@(context.Subscription.Id)" />
</inbound>

🛠 Step 2: Apply Policy via Azure CLI

az apim api policy set --api-id my-api --service-name my-apim-service --resource-group my-rg --policy azure-apim/policies.xml

📌 4️⃣ Simple Flask API for Testing Rate Limiting

app.py

from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/my-api', methods=['GET'])
def my_api():
    return jsonify({"message": "Rate Limiting Test API"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)

📌 Testing Rate Limits

Run these commands to test API Rate Limiting in each gateway:

🔹 Kong

for i in {1..120}; do curl -i http://localhost:8000/my-api; done

🔹 APISIX

for i in {1..120}; do curl -i http://localhost:9080/my-api; done

🔹 Azure APIM

for i in {1..120}; do curl -i "https://my-apim.azure-api.net/my-api?subscription-key=YOUR_KEY"; done

📌 Monitoring Rate Limiting Status

🔹 Check active rate-limiting plugins in Kong

curl -X GET http://localhost:8001/plugins?name=rate-limiting

🔹 Check APISIX rate-limit status

curl -X GET http://localhost:9180/apisix/admin/routes/1

🔹 Azure APIM Analytics

Check logs in Azure Monitor → API Gateway Metrics.

📌 Summary

✔ Kong API Gateway – Best for SaaS & enterprise APIs needing Redis-based distributed Rate Limiting.

✔ Apache APISIX – Best for high-performance edge APIs with flexible rate-limit policies.

✔ Azure APIM – Best for fully managed API Rate Limiting & enterprise cloud integrations.
