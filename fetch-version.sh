#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERSION_FILE="$DIR/src/main/resources/version"
echo "2.0.0" > "$VERSION_FILE"
echo "Version file has been updated."
