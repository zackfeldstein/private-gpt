{{/*
Generate a name that avoids name conflicts by appending the release name to the chart name.
If the release name and chart name are the same, avoid duplicating the name.
*/}}
{{- define "private-gpt.fullname" -}}
{{- if eq .Release.Name .Chart.Name -}}
{{- .Release.Name -}}
{{- else -}}
{{- .Release.Name }}-{{ .Chart.Name -}}
{{- end -}}
{{- end -}}

{{/*
Generate the name of the chart.
*/}}
{{- define "private-gpt.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Generate the name of the chart with the version.
*/}}
{{- define "private-gpt.chart" -}}
{{- .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}

{{/*
Generate common labels.
*/}}
{{- define "private-gpt.labels" -}}
app.kubernetes.io/name: {{ include "private-gpt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Generate selector labels.
*/}}
{{- define "private-gpt.selectorLabels" -}}
app.kubernetes.io/name: {{ include "private-gpt.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
