{{/*
Expand the name of the chart.
*/}}
{{- define "inference-stack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "inference-stack.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "inference-stack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "inference-stack.labels" -}}
helm.sh/chart: {{ include "inference-stack.chart" . }}
{{ include "inference-stack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for onwards
*/}}
{{- define "inference-stack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "inference-stack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for onwards component
*/}}
{{- define "inference-stack.onwards.selectorLabels" -}}
{{ include "inference-stack.selectorLabels" . }}
app.kubernetes.io/component: onwards
{{- end }}

{{/*
Selector labels for model group component
*/}}
{{- define "inference-stack.modelGroup.selectorLabels" -}}
{{ include "inference-stack.selectorLabels" . }}
app.kubernetes.io/component: model-group
{{- end }}

{{/*
Create the name of the service account to use for onwards
*/}}
{{- define "inference-stack.onwards.serviceAccountName" -}}
{{- if .Values.onwards.serviceAccount.create }}
{{- default (printf "%s-onwards" (include "inference-stack.fullname" .)) .Values.onwards.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.onwards.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the config.json content for onwards
*/}}
{{- define "inference-stack.onwards.config" -}}
{{- $targets := dict }}
{{- range $groupName, $group := .Values.modelGroups }}
{{- if $group.enabled }}
{{- range $alias := $group.modelAlias }}
{{- $target := dict }}
{{- $_ := set $target "url" (printf "http://%s-%s:%v" (include "inference-stack.fullname" $) $groupName $group.service.port) }}
{{- if $group.apiKey }}
{{- $_ := set $target "onwards_key" $group.apiKey }}
{{- end }}
{{- $_ := set $target "onwards_model" ($group.modelName | default $alias) }}
{{- $_ := set $targets $alias $target }}
{{- end }}
{{- end }}
{{- end }}
{{- $config := dict "targets" $targets }}
{{- $config | toJson }}
{{- end }}