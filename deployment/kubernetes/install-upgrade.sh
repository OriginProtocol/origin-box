#!/bin/bash

helm upgrade $1 \
	origin \
	-i \
	-f origin/values/values.yaml \
	-f origin/values/values-$1.yaml \
	--namespace $1
