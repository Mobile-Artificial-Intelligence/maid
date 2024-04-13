#!/bin/bash

# Get the current directory of the script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add Flutter to the PATH
export PATH="$DIR/packages/flutter/bin:$PATH"

echo "Flutter path set to $DIR/packages/flutter/bin"
