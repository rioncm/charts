{{/*
Common template helpers for the simplified Outline chart.
*/}}

{{- define "outline.namespace" -}}
{{- if .Values.namespace }}{{ .Values.namespace }}{{ else }}{{ .Release.Namespace }}{{ end -}}
{{- end }}

{{- define "outline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "outline.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end }}

{{- define "outline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end }}

{{- define "outline.labels" -}}
app.kubernetes.io/name: {{ include "outline.name" . }}
helm.sh/chart: {{ include "outline.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "outline.selectorLabels" -}}
app.kubernetes.io/name: {{ include "outline.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "outline.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "outline.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end }}

{{- define "outline.configMapName" -}}
{{ include "outline.fullname" . }}-config
{{- end }}

{{- define "outline.redisURL" -}}
{{- if .Values.redis.enabled -}}
redis://localhost:6379
{{- else -}}
{{- required "Set redis.externalUrl when redis.enabled=false" .Values.redis.externalUrl -}}
{{- end -}}
{{- end }}

{{- define "outline.toString" -}}
{{- if kindIs "float64" . -}}
{{- printf "%.0f" . -}}
{{- else if kindIs "int" . -}}
{{- printf "%d" . -}}
{{- else if kindIs "int64" . -}}
{{- printf "%d" . -}}
{{- else -}}
{{- printf "%v" . -}}
{{- end -}}
{{- end }}