docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

docker compose -f docker-compose.yml -f docker-compose.prod.yml exec roach-0 \
 /cockroach/cockroach sql \
 --certs-dir=/certs --host=roach-0 \
 --execute="CREATE USER IF NOT EXISTS roach WITH PASSWORD 'roach';"

docker compose -f docker-compose.yml -f docker-compose.prod.yml exec roach-0 \
 /cockroach/cockroach sql \
 --certs-dir=/certs --host=roach-0 --execute="GRANT ADMIN TO roach;"