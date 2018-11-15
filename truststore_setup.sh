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
EOF

    cat > server_ca_private.pem <<EOF
-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQDKItafBL6xTQyQ
lbmRx/MzlcP0gVK37IqhHh5cXXplQ09Ia9scrJliTtehfXVCHoRgQ/6/Mclc/u30
neTgv2XlewEuZYAnbOoNuwiR9CsXo7aSCFovPRwZ/9Tico6MBdMByNRMAyXeBBNG
kxNgB32SymxP/xfPKm7m1RDR1Fwakva8Za9JXVG9s8M7bH0Nsn52/+yaKuobNlQo
w/qnlffIyUiLrzLjCN6xjlPrcjoNAes2b6Noh9Pzms2sj5y8icONQUSMoVzCLfJp
PE7aYZzR0bksZLy4cVkt2QEXqyho3+RPNH33wbFov+Kjem5xUfGjWbrV6WLi7Woi
uovkuAbtAgMBAAECggEBAKJ03YlwhtJ42mBZ9Yr06MHM3HDmf1TTB5f2XPBfML+y
GUZbaP7iuWQJecSQ0G0TmdDE1TlVCkFzoku3mvwG2B5XfduMODN3laTzbS/gzcFy
EonLrK/KrYs30iEtcOOYyr3karuszAJjxBo0mp3TZ1lS1zp0Cu61a+yZ0arSwjOX
/HJB6/jg3/QTQ3aLBTOCX05tl6hVewiySJsAB3J6iRZgvuZsjJG1niDM49s71QXc
mUnHZrBcOwAHnANNHKSKN7HzaCMFLOH9IAvY0IPv6ed0AODBHQr2aPEfYh1CiE5O
krjwTRsc/gXpTV2ldR/Q6P3EfYqmztibUHeUX/Fc0AECgYEA6RroriHjYN21EKuJ
5XK6F/kAgXTlfah9obA8uC0lKwiCoWX0mGBfvyMEZcF7NFvR36UDkMlywLjF32kT
ywOGbwQAwe+lmQninUqxZMLqY4PEL5jI7A0NWHg4OWwqsdI8RL9/SQ1C9sNOZBlO
9jjZw0rYgtpCSKDoMF2Jssr8lV0CgYEA3f1CEVq9AjE+MbybYX0ScA2ktz993TcW
3QVlL+FkEWmZSmriK8hTqT8CmQzh8mX7UzxYPZZbyQ+VBxhboAX3X3EXUumYJiJ4
vKhgKWhWpq71FDUJoQThauYczFojRkrw6n1XPPKwYEUitAH9pyohqhM6oas5LOyV
+oiqqwlDDtECgYEA3DNsPBqNJdMqGS5CXHqNKtowzRn1NEf3LcdDBKS46LboV7jt
XwgjSna0z77/OM3IK2FBRgPWoBGr8kjbxrp0wuhgItPUdgYtiXKmss2iBxHRQTku
DDakNb+TNUNl7YbxIexYPFUHvf1vTwXNXrEDnQVWE/5EAUHnNNEXo8s24Y0CgYBy
1mQKNEWYz76b3jUHbrtOClDOl2LWQHxsZDEfXtr0gwtQyxArlBtrb3Q5lseALS+h
tJL1cUYUMiJnJDuqAcwhrJBjTQJvn9+TwQrWAOrqmZGhHXrYuHygX2BAetTKtVQC
CktJ9UY21y0HsAv3IT1/DSmEnt4aFl3T2EVp64WsMQKBgQC3jeJcfvnf90KOj/hW
sVxYECfZz8TvvRGo8CJcxNxOTjTXurYlYT4Nar79MwrszQ4R+5ErX/Xfb8KWPuFr
54liPTjGx5tdFFEtsmC/lDoHcir9qTKg6tv8vDr59pO984xLYO7l04RMpMh++R10
BBVCjfkjV9PsEixyORobcQbJQg==
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
