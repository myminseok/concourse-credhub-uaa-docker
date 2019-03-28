# CredHub

Docker image for CredHub (include a docker-compose file to run with UAA).

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
2. Start CredHub with Docker with binding UAA: `docker run -d --link uaa -e UAA_URL=http://uaa:8080/uaa -e UAA_INTERNAL_URL=http://uaa:8080/uaa -p 127.0.0.1:9000:9000 pcfseceng/uaa:latest`

## Run docker-compose

Clone this repo and run `docker-compose up` or `docker-compose up -d` inside folder [/docker-compose](/docker-compose).

## Use with credhub-cli

You can now connect to credhub with this command:

```bash
credhub-cli login -s https://localhost:9000 -u credhub -p password --ca-cert=server_ca_cert.pem
or
credhub-cli login -s https://localhost:9000 -u credhub -p password --skip-tls-validation
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
MIIDEDCCAfigAwIBAgIJANeDDfBkAyJ2MA0GCSqGSIb3DQEBCwUAMBwxGjAYBgNV
BAMMEWNyZWRodWJfc2VydmVyX2NhMCAXDTE4MDgyMjA3MDEyMFoYDzIxMTgwNzI5
MDcwMTIwWjAcMRowGAYDVQQDDBFjcmVkaHViX3NlcnZlcl9jYTCCASIwDQYJKoZI
hvcNAQEBBQADggEPADCCAQoCggEBAMoi1p8EvrFNDJCVuZHH8zOVw/SBUrfsiqEe
HlxdemVDT0hr2xysmWJO16F9dUIehGBD/r8xyVz+7fSd5OC/ZeV7AS5lgCds6g27
CJH0KxejtpIIWi89HBn/1OJyjowF0wHI1EwDJd4EE0aTE2AHfZLKbE//F88qbubV
ENHUXBqS9rxlr0ldUb2zwztsfQ2yfnb/7Joq6hs2VCjD+qeV98jJSIuvMuMI3rGO
U+tyOg0B6zZvo2iH0/OazayPnLyJw41BRIyhXMIt8mk8TtphnNHRuSxkvLhxWS3Z
ARerKGjf5E80fffBsWi/4qN6bnFR8aNZutXpYuLtaiK6i+S4Bu0CAwEAAaNTMFEw
HQYDVR0OBBYEFBTrhXS4ogDO/1u0MjhAcRT3Nx85MB8GA1UdIwQYMBaAFBTrhXS4
ogDO/1u0MjhAcRT3Nx85MA8GA1UdEwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQAD
ggEBAGxi/TBLJYAlLySo6vic9y4WcmHU+1bHZqGq0tca69XFnHD1H4z5+tVbbwdV
f3B1lFEyYYxxEIsb8YLyey4wWL6S9/aFCOraUMS3TkN0jDF9T8gXpqD6IBSX0Ca3
/V8qXar5vCO91T7qJWou5WcXoPzfYve2i8LV8c9xMBdF9o1hHNKNqCCvbshpOV35
qb3r/s+CL5elKUwWUc8/7N2tFuuSk9ETi8ApqnNPJA4OeqpDry9S+7JM/xEvIktc
utmLo8kRMd9hXZa06XIiLI23gOo08KsE98G9P79RdhpeZweAhbZoghRxj/YVmmEI
qe3dqmF87rObz/Vht6J+pH9ht30=
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
     }'   -H "authorization: bearer ${ACCESS_TOKEN}"   -H 'content-type: application/json' --cacert server_ca_cert.pem
```
