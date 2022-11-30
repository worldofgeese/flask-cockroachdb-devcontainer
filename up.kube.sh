kubectl apply -f client-secure.yaml

kubectl exec -it cockroachdb-client-secure \
 -- ./cockroach sql \
 --certs-dir=./cockroach-certs --host=my-cockroachdb-public \
 --execute="CREATE USER IF NOT EXISTS roach WITH PASSWORD 'roach';"

kubectl exec -it cockroachdb-client-secure \
 -- ./cockroach sql \
 --certs-dir=./cockroach-certs --host=my-cockroachdb-public \
 --execute="GRANT ADMIN TO roach;"
