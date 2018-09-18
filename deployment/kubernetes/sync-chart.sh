#!/bin/bash

if [ "$1" != "dev" ] && [ "$1" != "staging" ] && [ "$1" != "prod" ]; then
    echo -e "\033[31mArgument must be one of dev, staging or prod\033[0m"
    exit
fi

if [ ! -f values/secrets-$1.yaml ]; then
    echo -e "\033[31mNo secrets file found at values/secrets-$1.yaml\033[0m"
    echo -e ""
    echo -e "Did you forget to decrypt it? :)"
    exit
fi

helm upgrade $1 \
	chart \
	-i \
	-f chart/values.yaml \
	-f values/values-$1.yaml \
	-f values/secrets-$1.yaml \
	--namespace $1
