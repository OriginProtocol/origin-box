{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dapp.fullname" -}}
{{- printf "%s-%s" .Release.Name "dapp" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bridge.fullname" -}}
{{- printf "%s-%s" .Release.Name "bridge" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ipfs.fullname" -}}
{{- printf "%s-%s" .Release.Name "ipfs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "messaging-ipfs.fullname" -}}
{{- printf "%s-%s" .Release.Name "messaging-ipfs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "messaging.fullname" -}}
{{- printf "%s-%s" .Release.Name "messaging" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "eth.fullname" -}}
{{- printf "%s-%s" .Release.Name "eth-node" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

