#!/bin/bash

helm upgrade $1 \
	origin \
	-i \
	-f origin/values.yaml \
	-f origin/values-$1.yaml \
	-f origin/values-secret.yaml \
	--namespace $1
