{{/*
Expand the name of the chart.
*/}}
{{- define "backstage-utility.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backstage-utility.fullname" -}}
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
{{- define "backstage-utility.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backstage-utility.labels" -}}
helm.sh/chart: {{ include "backstage-utility.chart" . }}
{{ include "backstage-utility.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backstage-utility.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backstage-utility.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: backstage-utility
environment: {{ .Values.global.environment }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "backstage-utility.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "backstage-utility.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the current environment configuration
*/}}
{{- define "backstage-utility.env" -}}
{{- $env := .Values.global.environment }}
{{- $config := index .Values.environments $env }}
{{- $config | toYaml }}
{{- end }}

{{/*
Get PostgreSQL service name
*/}}
{{- define "backstage-utility.postgresql.fullname" -}}
{{- printf "%s-postgresql" (include "backstage-utility.fullname" .) }}
{{- end }}