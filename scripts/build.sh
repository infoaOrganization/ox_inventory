#!/bin/sh

set -e

cd "$(dirname "$0")/.."

(cd web && pnpm install --frozen-lockfile)
(cd web && pnpm build)

# Create build directory for publishing
rm -rf build
mkdir -p build

# Copy core files
cp server.lua build/
cp README.md build/
cp LICENSE build/
cp fxmanifest.lua build/
cp client.lua build/
cp init.lua build/

# Copy directories
cp -r setup build/
cp -r modules build/
cp -r data build/
cp -r locales build/

# Create web directory structure
mkdir -p build/web

# Copy web build output
cp -r web/build build/web/build
cp -r web/images build/web/images
cp web/LICENSE build/web/build/

echo "Build directory created successfully at $(pwd)/build"
