#!/bin/bash

helm upgrade $1 \
	origin \
	-i \
	-f origin/values.yaml \
	-f origin/environments/values-$1.yaml \
	--namespace $1
