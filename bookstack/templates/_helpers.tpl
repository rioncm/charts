{{/*
Expand the name of the chart.
*/}}
{{- define "bookstack.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bookstack.fullname" -}}
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
{{- define "bookstack.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bookstack.labels" -}}
helm.sh/chart: {{ include "bookstack.chart" . }}
{{ include "bookstack.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bookstack.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bookstack.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bookstack.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bookstack.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate the APP_KEY if not provided
*/}}
{{- define "bookstack.appKey" -}}
{{- if .Values.bookstack.appKey }}
{{- .Values.bookstack.appKey }}
{{- else }}
{{- "base64:GENERATE_YOUR_OWN_APP_KEY_USING_DOCKER_RUN" }}
{{- end }}
{{- end }}

{{/*
Create secret for database password if not using existing secret
*/}}
{{- define "bookstack.createDbSecret" -}}
{{- if and (not .Values.database.existingSecret) .Values.database.password }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Get database secret name
*/}}
{{- define "bookstack.dbSecretName" -}}
{{- if .Values.database.existingSecret }}
{{- .Values.database.existingSecret }}
{{- else }}
{{- printf "%s-db-secret" (include "bookstack.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Create secret for APP_KEY if requested
*/}}
{{- define "bookstack.createAppKeySecret" -}}
{{- if and .Values.bookstack.createAppKeySecret .Values.bookstack.appKey (not .Values.bookstack.appKeySecret) }}
{{- true }}
{{- else }}
{{- false }}
{{- end }}
{{- end }}

{{/*
Get APP_KEY secret name
*/}}
{{- define "bookstack.appKeySecretName" -}}
{{- if .Values.bookstack.appKeySecret }}
{{- .Values.bookstack.appKeySecret }}
{{- else if .Values.bookstack.createAppKeySecret }}
{{- printf "%s-app-key" (include "bookstack.fullname" .) }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}