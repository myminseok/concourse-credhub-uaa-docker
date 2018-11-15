#!/bin/bash
cp truststore_preparation.sh credhub/
cp fetch-version.sh credhub/
pushd credhub
./truststore_preparation.sh
./gradlew --no-daemon assemble
popd
