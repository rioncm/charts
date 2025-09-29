{{/*
Expand the name of the chart.
*/}}
{{- define "odoo-cs.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "odoo-cs.fullname" -}}
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
{{- define "odoo-cs.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "odoo-cs.labels" -}}
helm.sh/chart: {{ include "odoo-cs.chart" . }}
{{ include "odoo-cs.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{ toYaml .Values.commonLabels }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "odoo-cs.selectorLabels" -}}
app.kubernetes.io/name: {{ include "odoo-cs.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Return the proper Odoo image name
*/}}
{{- define "odoo-cs.image" -}}
{{- $registryName := .Values.image.registry -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $separator := ":" -}}
{{- $termination := .Values.image.tag | toString -}}
{{- if .Values.image.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .Values.image.digest | toString -}}
{{- end -}}
{{- if .Values.global }}
    {{- if .Values.global.imageRegistry }}
        {{- $registryName = .Values.global.imageRegistry -}}
    {{- end -}}
{{- end -}}
{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s" $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Return the proper Docker Image Registry Secret Names
*/}}
{{- define "odoo-cs.imagePullSecrets" -}}
{{- $pullSecrets := list }}
{{- if .Values.global }}
  {{- range .Values.global.imagePullSecrets -}}
    {{- $pullSecrets = append $pullSecrets . -}}
  {{- end -}}
{{- end -}}
{{- range .Values.image.pullSecrets -}}
  {{- $pullSecrets = append $pullSecrets . -}}
{{- end -}}
{{- if (not (empty $pullSecrets)) }}
imagePullSecrets:
{{- range $pullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end -}}

{{/*
Return the external database hostname
*/}}
{{- define "odoo-cs.databaseHost" -}}
{{- .Values.externalDatabase.host | quote -}}
{{- end -}}

{{/*
Return the external database port
*/}}
{{- define "odoo-cs.databasePort" -}}
{{- .Values.externalDatabase.port | quote -}}
{{- end -}}

{{/*
Return the external database name
*/}}
{{- define "odoo-cs.databaseName" -}}
{{- .Values.externalDatabase.database -}}
{{- end -}}

{{/*
Return the external database user
*/}}
{{- define "odoo-cs.databaseUser" -}}
{{- .Values.externalDatabase.user -}}
{{- end -}}

{{/*
Return the External Database Secret Name
*/}}
{{- define "odoo-cs.databaseSecretName" -}}
{{- default (printf "%s-externaldb" (include "odoo-cs.fullname" .) | trunc 63 | trimSuffix "-") .Values.externalDatabase.existingSecret -}}
{{- end -}}

{{/*
Return the database secret password key
*/}}
{{- define "odoo-cs.databaseSecretPasswordKey" -}}
{{- if .Values.externalDatabase.existingSecret -}}
    {{- if .Values.externalDatabase.existingSecretPasswordKey -}}
        {{- printf "%s" .Values.externalDatabase.existingSecretPasswordKey -}}
    {{- else -}}
        {{- print "password" -}}
    {{- end -}}
{{- else -}}
    {{- print "password" -}}
{{- end -}}
{{- end -}}

{{/*
Odoo credential secret name
*/}}
{{- define "odoo-cs.secretName" -}}
{{- coalesce .Values.existingSecret (include "odoo-cs.fullname" .) -}}
{{- end -}}

{{/*
Return the SMTP Secret Name
*/}}
{{- define "odoo-cs.smtpSecretName" -}}
{{- coalesce .Values.smtpExistingSecret (include "odoo-cs.fullname" .) -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "odoo-cs.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "odoo-cs.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Resource preset definitions
*/}}
{{- define "odoo-cs.resources.preset" -}}
{{- $preset := .preset -}}
{{- if eq $preset "nano" -}}
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
{{- else if eq $preset "micro" -}}
resources:
  requests:
    cpu: 500m
    memory: 512Mi
  limits:
    cpu: 1
    memory: 1Gi
{{- else if eq $preset "small" -}}
resources:
  requests:
    cpu: 1
    memory: 1Gi
  limits:
    cpu: 2
    memory: 2Gi
{{- else if eq $preset "medium" -}}
resources:
  requests:
    cpu: 2
    memory: 2Gi
  limits:
    cpu: 4
    memory: 4Gi
{{- else if eq $preset "large" -}}
resources:
  requests:
    cpu: 4
    memory: 4Gi
  limits:
    cpu: 8
    memory: 8Gi
{{- else if eq $preset "xlarge" -}}
resources:
  requests:
    cpu: 8
    memory: 8Gi
  limits:
    cpu: 16
    memory: 16Gi
{{- else if eq $preset "2xlarge" -}}
resources:
  requests:
    cpu: 16
    memory: 16Gi
  limits:
    cpu: 32
    memory: 32Gi
{{- end -}}
{{- end -}}
