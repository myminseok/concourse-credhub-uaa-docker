
#credhub login -s https://localhost:9000 --client-name=credhub_client --client-secret=secret --skip-tls-validation
#credhub login -s https://localhost:9000 --client-name=credhub_client --client-secret=secret --ca-cert=./server_ca_cert/server_ca_cert.pem

credhub api --server=https://localhost:9000/ --skip-tls-validation
credhub login  --client-name=credhub_client --client-secret=secret
credhub set -t value -n /concourse/main/hello-credhub/hello -v test
