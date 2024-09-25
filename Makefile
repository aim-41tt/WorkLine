start:
	docker compose up -d
	sleep 10
	make kong-configure
clear:
	docker compose down --volumes
kong-configure:
	curl -i -X POST http://127.0.0.1:8001/plugins \
		--data "name=proxy-cache" \
		--data "config.request_method=GET" \
		--data "config.response_code=200" \
		--data "config.content_type=application/json" \
		--data "config.cache_ttl=30" \
		--data "config.strategy=memory"
	curl -X POST http://localhost:8001/upstreams --data name=usermanager_upstream
	curl -X POST http://localhost:8001/upstreams --data name=companymanager_upstream
	curl -X POST http://localhost:8001/upstreams --data name=projectmanager_upstream
	make kong-upstreams-configure
kong-upstreams-configure:
	curl -i -X POST 127.0.0.1:8001/upstreams/usermanager_upstream/targets \
		--form 'target="usermanager:8080"'
add-kong-service:
	curl -i -X POST '127.0.0.1:8001/services/ \
		--form 'name=${NAME}' \
		--form 'url=${URL}'
	curl -i -X POST 127.0.0.1:8001/services/${NAME}/routes \
		--form 'paths[]=/${NAME}'
add-kong-jwt:
	curl -i -X POST 127.0.0.1:8001/services/${NAME}/plugins --form 'name="jwt"'