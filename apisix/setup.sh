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

