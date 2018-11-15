#!/bin/sh
cp truststore_preparation.sh credhub/
cp fetch-version.sh credhub/
cd credhub
./truststore_preparation.sh
./gradlew --no-daemon assemble
