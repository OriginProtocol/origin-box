#!/bin/bash

if [ ! -f origin/values-secret.yaml ]; then
    echo -e "\033[31mNo secrets file found at origin/values-secret.yaml\033[0m"
    echo -e ""
    echo -e "It must be populated with the following configuration items:"
    echo -e "\t envKeyBridge - EnvKey key for use with origin-bridge"
    echo
    exit
fi

helm upgrade $1 \
	origin \
	-i \
	-f origin/values.yaml \
	-f origin/values-$1.yaml \
	-f origin/values-secret.yaml \
	--namespace $1
