# CredHub

Docker image for CredHub (include a docker-compose file to run with uaa).

Do not use this image in production! This image is meant to be used for development and testing purposes only.

## Status

Master Branch: [![CircleCI](https://circleci.com/gh/ampersand8/credhub-docker/tree/master.svg?style=svg)](https://circleci.com/gh/ampersand8/credhub-docker/tree/master)

## Run without UAA

```bash
docker run -d -p 127.0.0.1:9000:9000 ampersand8/credhub:latest
```

## Run with UAA

You will need a config file for UAA which can be found [here](/docker-compose/uaa.yml).

1. Start a UAA with Docker: `docker run -d --name uaa --mount type=bind,source=$PWD/docker-compose/config/uaa.yml,target=/uaa/uaa.yml -p 127.0.0.1:8081:8080 pcfseceng/uaa:latest`
2. Start credhub with docker with binding uaa: `docker run -d --link uaa -e UAA_URL=http://localhost:8081/uaa -e UAA_INTERNAL_URL=http://uaa:8080/uaa -p 127.0.0.1:9000:9000 pcfseceng/uaa:latest`

## Run docker-compose

Clone this repo and run `docker-compose up -d` inside folder [/docker-compose](/docker-compose).

## Use with credhub-cli

You can now connect to credhub with this command:

```bash
credhub-cli login -s https://localhost:9000 -u credhub -p password --ca-cert=server_ca_cert.pem
```

## Use with curl

Get token from UAA
```bash
token=$(curl -q -s -XPOST -H"Application/json" --data "client_id=credhub_client&client_secret=secret&client_id=credhub_client&grant_type=client_credentials&response_type=token" http://localhost:8081/uaa/oauth/token | jq -r .access_token)
```

Get CredHub version
```bash
curl -k https://localhost:9000/version -H "content-type: application/json" -H "authorization: bearer ${token}"
```

Set CredHub JSON credential
```bash
curl -k -XPUT https://localhost:9000/api/v1/data -H "content-type: application/json" -H "authorization: bearer ${token}" -d '{"name": "/thisissometest","type":"json","value": {"password":"testpassword"}}' | jq .
```

Get CredHub credential 
```bash
curl -k https://localhost:9000/api/v1/data?name=/thisissometest -H "content-type: application/json" -H "authorization: bearer ${token}" | jq .
```

## CA Certificate
The CA Certificate is valid until the year 2118.

server_ca_cert.pem
```
-----BEGIN CERTIFICATE-----
MIIDDjCCAfagAwIBAgIJAPjHrDQAK8dlMA0GCSqGSIb3DQEBCwUAMBwxGjAYBgNV
BAMMEWNyZWRodWJfc2VydmVyX2NhMB4XDTE5MDIwODExMzUyM1oXDTIwMDIwODEx
MzUyM1owHDEaMBgGA1UEAwwRY3JlZGh1Yl9zZXJ2ZXJfY2EwggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDKTEfLioA6sm7FCpMfHOWD3t7DaGcaAleAt3yd
NtHV2G4AFqiAwYsF6MmKjrlVn89bgzb1v6U/65DfqAxfA/VHDi6KGQiL/yJf9suS
FcgO4WL5BLpc/eaZc4ICSYFMRkpTsbNMidUabygyEdhKS++5G1ucTo2l0jG9MSfU
2UeTHM6vcioz9GT5F7n7hPyWPsp6BWZgaIYHfJUAUAQ8fjNu+mSRQqesZo73hYa8
w/1RO4Z09NBtfOsAe3178wduXYovRmF3lo9CqRV43XVOdWflFR9lBYbiJ49iJLLl
I5sB+lHx/ZbKknIvqt68A8rV8r37LtuC5vCswbAticRzQudTAgMBAAGjUzBRMB0G
A1UdDgQWBBT+rivBi4znyGGO6wK0JVsNHpU4/jAfBgNVHSMEGDAWgBT+rivBi4zn
yGGO6wK0JVsNHpU4/jAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IB
AQBzFxivvPa6gpBNwdZCJFzznWhL7cPMCXG99H+rMcQPfOkp1/2tW9zQBpG8uNrJ
UiUQtUTtnX6dsJ1MS/t97SunX8F2hDoDB96NVZsSyh1vXOC1wE7r5bCD4eoIS4sp
qRq7uITjYuRC2BufPCwX+BWCX4aj1P/2BVrinhiZF1XyOtrlJ2TwkVrnzYscSW4Z
m3lP0xQSr+DuudWpDRetjUSXK0pSAAHgdSUh3TxdZc0LX5aLDY4iUUJTVZJZTVS2
s+Y6K6YRseAMYX01ZsHNHmW51nMt0qluYw4HAyCr+hX6DtZ7dG61N6uahc41npB/
mHBtu8vqvwEdI0wAY54k95UH
-----END CERTIFICATE-----
```

## Test with curl
Generate a sample password
```
export ACCESS_TOKEN=$(curl -u 'credhub_client:secret' "http://localhost:8080/uaa/oauth/token?grant_type=client_credentials&response_type=token" -H 'Accept: application/json' | jq -r .access_token)
curl "https://localhost:9000/api/v1/data"   -X POST   -d '{
      "name": "/example-password",
      "type": "password",
      "parameters": {
        "length": 40
      }
     }'   -H "authorization: bearer ${ACCESS_TOKEN}"   -H 'content-type: application/json' --cacert ~/dev/credhub-docker/server_ca_cert.pem
```
