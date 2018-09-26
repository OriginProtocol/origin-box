{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bridge.fullname" -}}
{{- printf "%s-%s" .Release.Name "bridge" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bridge.host" -}}
{{- $prefix := "bridge" -}}
{{- if ne .Release.Namespace "prod" -}}
{{- printf "%s.%s.originprotocol.com" $prefix .Release.Namespace -}}
{{- else -}}
{{- printf "%s.originprotocol.com" $prefix -}}
{{- end -}}
{{- end -}}

{{- define "dapp.fullname" -}}
{{- printf "%s-%s" .Release.Name "dapp" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "dapp.host" -}}
{{- if ne .Release.Namespace "prod" -}}
{{- printf "demo.%s.originprotocol.com" .Release.Namespace -}}
{{- else -}}
{{- printf "dapp.originprotocol.com" -}}
{{- end -}}
{{- end -}}

{{- define "ethereum.fullname" -}}
{{- printf "%s-%s" .Release.Name "ethereum" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "faucet.fullname" -}}
{{- printf "%s-%s" .Release.Name "faucet" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "faucet.host" -}}
{{- if eq .Release.Namespace "staging" -}}
{{- printf "faucet.originprotocol.com" }}
{{- else -}}
{{- printf "faucet.%s.originprotocol.com" .Release.Namespace -}}
{{- end -}}
{{- end -}}

{{- define "ipfs.fullname" -}}
{{- printf "%s-%s" .Release.Name "ipfs" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "ipfs.host" -}}
{{- $prefix := "ipfs" -}}
{{- if ne .Release.Namespace "prod" -}}
{{- printf "%s.%s.originprotocol.com" $prefix .Release.Namespace -}}
{{- else -}}
{{- printf "%s.originprotocol.com" $prefix -}}
{{- end -}}
{{- end -}}

{{- define "messaging.fullname" -}}
{{- printf "%s-%s" .Release.Name "messaging" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "messaging.host" -}}
{{- $prefix := "messaging" -}}
{{- if ne .Release.Namespace "prod" -}}
{{- printf "%s.%s.originprotocol.com" $prefix .Release.Namespace -}}
{{- else -}}
{{- printf "%s.originprotocol.com" $prefix -}}
{{- end -}}
{{- end -}}

{{- define "eventlistener.fullname" -}}
{{- printf "%s-%s" .Release.Name "eventlistener" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "discovery.fullname" -}}
{{- printf "%s-%s" .Release.Name "discovery" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "discovery.host" -}}
{{- $prefix := "discovery" -}}
{{- if ne .Release.Namespace "prod" -}}
{{- printf "%s.%s.originprotocol.com" $prefix .Release.Namespace -}}
{{- else -}}
{{- printf "%s.originprotocol.com" $prefix -}}
{{- end -}}
{{- end -}}
