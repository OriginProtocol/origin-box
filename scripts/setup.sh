#!/bin/bash
set -e # Exit shell script on an error
set -x # Echo shell commands as they run

# Clone bridge server, origin-js, and dapp sources
git clone -b develop https://github.com/OriginProtocol/origin-bridge.git
git clone -b develop https://github.com/OriginProtocol/origin-js.git
git clone -b develop https://github.com/OriginProtocol/origin-dapp.git

# Copy .env files to configure apps for the origin-box 
cp ./container/files/config/bridge_dev.env ./origin-bridge/.env
cp ./container/files/config/dapp_dev.env ./origin-dapp/.env

# Build bridge server image
docker build ./container -t origin-image
