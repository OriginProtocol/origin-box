#!/bin/bash

helm install origin -f origin/values.yaml -f origin/values-$1.yaml --namespace $1
