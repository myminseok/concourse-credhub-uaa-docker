# CredHub

Docker image for CredHub (include a docker-compose file to run with UAA).

Do not use this image in production! This image is meant to be used for development and testing purposes only.

## Run docker-compose

Clone this repo and run `docker-compose up` or `docker-compose up -d` inside folder [/docker-compose](/docker-compose).

```bash
cd concourse-credhub-uaa-docker/docker-compose
docker-compose up -d

```
## test
set-pipeline.sh
```bash
fly -t demo login -u test -p test -c http://localhost:8081  -k
fly -t demo sp -p hello-credhub -c ./hello-credhub.yml
```

set-credhub.sh
```bash
credhub api --server=https://localhost:9000/ --skip-tls-validation
credhub login  --client-name=credhub_client --client-secret=secret
credhub set -t value -n /concourse/main/hello-credhub/hello -v test
```
