#!/bin/sh

set -eu

DIRNAME=$(dirname "$0")

KEYSTORE_PASSWORD=changeit

KEY_STORE=key_store.jks
MTLS_TRUST_STORE=trust_store.jks
AUTH_SERVER_TRUST_STORE=auth_server_trust_store.jks
UAA_CA=ca/dev_uaa.pem

setup_tls_key_store() {
    echo "Import signed certificate into the keystore"
	keytool -importkeystore \
        -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass changeit \
        -deststorepass "${KEYSTORE_PASSWORD}" -destkeypass "${KEYSTORE_PASSWORD}" \
        -destkeystore "${KEY_STORE}" -alias cert

    rm server.p12 server.csr
}

generate_server_ca() {
    echo "Generating root CA for the server certificates into server_ca_cert.pem and server_ca_private.pem"
    cat > server_ca_cert.pem  <<EOF
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
EOF

    cat > server_ca_private.pem <<EOF
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDKTEfLioA6sm7F
CpMfHOWD3t7DaGcaAleAt3ydNtHV2G4AFqiAwYsF6MmKjrlVn89bgzb1v6U/65Df
qAxfA/VHDi6KGQiL/yJf9suSFcgO4WL5BLpc/eaZc4ICSYFMRkpTsbNMidUabygy
EdhKS++5G1ucTo2l0jG9MSfU2UeTHM6vcioz9GT5F7n7hPyWPsp6BWZgaIYHfJUA
UAQ8fjNu+mSRQqesZo73hYa8w/1RO4Z09NBtfOsAe3178wduXYovRmF3lo9CqRV4
3XVOdWflFR9lBYbiJ49iJLLlI5sB+lHx/ZbKknIvqt68A8rV8r37LtuC5vCswbAt
icRzQudTAgMBAAECggEBALcgQkWwxM9dwwQ/xFp/0AyF7eW6VsqmoAt3DilK/Ly2
RS1zVWnoyi65QehZttAZ8J2ItHHV4INyfRzZhQlmDd0aq2p7qs8AUF/KixFdAlLm
GLAPZZzUgrEabPAhFhiz8Ii+7e41P2HEigB5QvBOuV05tL5UJcmb80aufr4hSreR
2f8BfyIn2h4X+Z/IAZPUvBqlxNuF5+63AOV0zWbtncu+PxvXXZ/LKUxG5/kHM8Vf
K8wd0kkGoE3BS7wwEzWWrKdEfNZBeE8bQQ2eIy04G3SlH/VkFD/V6UGfHwbjwYtq
qL30CLxE5mqdloFDIYykNgCz1FHUUrKco0CFOh+H8qECgYEA7HcTc1FTP4Mh4Kd2
wmthkWt9pj0IhXY0hSv5W2Gi1jZqjpaZWOVzkHASOIKOijAwaMh4t/P3T7uj4iN4
er5x3e7zMrnQScajXftFJ7XHWVoiBA6E5zk8BlnyWnlO2rpCuGCqgr6cq0vyd3AI
T1aIEZ4Yc4s0h/iJfRRkWlwWKvkCgYEA2wKdORDf+T1NWkHUfBp9vNxumqJQg2Hy
8WxI1rwRe0QFzuBElgYTiMniq20SEh0WMTCdsQmBbHlQ6FjimUwnsgZyAm4kPn3P
iQEQQH+YQy8qApEX3vIwwQkyNpCIQlDu9mI5yeKqbn3doTPLEljtOrmLYGRDV/l2
kAYqhVDXi6sCgYBEstOTzSzCZvaQrhZypX/TH8eBZHn1TEI17nCje9ozIdwTUO18
Ri0s6WJhyIxg2V83EgcAaoCPSZRzPpriDjJGqAU/13wL8wnDZBzTTJx9+RGo3A8A
nkAyGC+w2U1vfm2j43GmSnp5ybbHvGStqBYgCC5SYz7/wdUv4ZzGI7rNAQKBgQDa
+g8nerbmpqOL5hxFhdtIlYJFPJuR8cKOHz3o7pvwCsBf657H/gVUFL99tY2G7Ow+
fKR+2ck9I0OBPTY8HofmGUmvIl882GBEVPrh8nHUYvj3HgmnEbMrnz1Ej1ieLfvv
/6BWOjs8RL7vqjCWBLIVsGUqGLW45aXlNTUYnQ8XBwKBgFWAoYmZX1KahUv2t49q
b9/+GirjLzjq8SQrNqirUhYWmLvTT+lZfgbkMIttJQxqM8LlAgIN4V1y1hdohi9p
SLIc9eKSk0fVEj0UyIKObGcnOl+hGdJeEzidmW7/6LP5tr/+1PpH4yXMe2faFbN3
wCweqDB1xxbeHBPixLv/c2Pf
-----END PRIVATE KEY-----
EOF

}

add_client_ca_to_trust_store() {
    ls -al
    echo "Adding root CA to servers trust store for mTLS..."
    keytool -import -trustcacerts -noprompt -alias client_ca -file client_ca_cert.pem \
	    -keystore ${MTLS_TRUST_STORE} -storepass ${KEYSTORE_PASSWORD}
}

import_default_truststore_to_custom() {
  echo "Importing default trust store to custom trust store"
  keytool -importkeystore \
    -srckeystore ${JAVA_HOME}/jre/lib/security/cacerts \
    -destkeystore ${AUTH_SERVER_TRUST_STORE} \
    -deststoretype pkcs12 \
    -storepass ${KEYSTORE_PASSWORD}
}

setup_auth_server_trust_store() {
    echo "Adding dev UAA CA to auth server trust store"
    keytool -import \
        -trustcacerts \
        -noprompt \
        -alias auth_server_ca \
        -file ${UAA_CA} \
        -keystore ${AUTH_SERVER_TRUST_STORE} \
        -storepass ${KEYSTORE_PASSWORD}
}

main() {
    cd "${DIRNAME}/src/test/resources"
        echo "$(pwd)"
        generate_server_ca
        add_client_ca_to_trust_store
        setup_tls_key_store
        import_default_truststore_to_custom
        setup_auth_server_trust_store

        echo "Finished setting up key stores for TLS and mTLS!"

        echo "Run run_tests.sh in credhub-acceptance-tests to generate client certs"
        echo e.g., curl -H \"Content-Type: application/json\" \
            -X POST -d "'{\"name\":\"cred\",\"type\":\"password\"}'" \
            https://localhost:9000/api/v1/data --cacert "${PWD}/server_ca_cert.pem" \
            --cert "${GOPATH}/src/github.com/cloudfoundry-incubator/credhub-acceptance-tests/certs/client.pem" \
            --key "${GOPATH}"/src/github.com/cloudfoundry-incubator/credhub-acceptance-tests/certs/client_key.pem

    cd -
}

main
