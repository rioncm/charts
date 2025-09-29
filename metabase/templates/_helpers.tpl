{{/*
Expand the name of the chart.
*/}}
{{- define "metabase.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "metabase.fullname" -}}
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
{{- define "metabase.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metabase.labels" -}}
helm.sh/chart: {{ include "metabase.chart" . }}
{{ include "metabase.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metabase.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metabase.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "metabase.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "metabase.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Database connection string
*/}}
{{- define "metabase.databaseUrl" -}}
{{- if eq .Values.database.type "postgresql" }}
{{- printf "postgres://%s:%s@%s:%d/%s" .Values.database.postgresql.username .Values.database.postgresql.password .Values.database.postgresql.host (int .Values.database.postgresql.port) .Values.database.postgresql.database }}
{{- else if eq .Values.database.type "mysql" }}
{{- printf "mysql://%s:%s@%s:%d/%s" .Values.database.mysql.username .Values.database.mysql.password .Values.database.mysql.host (int .Values.database.mysql.port) .Values.database.mysql.database }}
{{- else }}
{{- printf "h2:file:/metabase-data/metabase.db" }}
{{- end }}
{{- end }}

{{/*
PVC name
*/}}
{{- define "metabase.pvcName" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- include "metabase.fullname" . }}-data
{{- end }}
{{- end }}
