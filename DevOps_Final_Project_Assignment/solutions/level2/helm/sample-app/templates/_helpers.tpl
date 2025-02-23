{{/*
Return the chart name.
*/}}
{{- define "sample-app.name" -}}
sample-app
{{- end -}}

{{/*
Return the fully qualified app name.
*/}}
{{- define "sample-app.fullname" -}}
{{ include "sample-app.name" . }}
{{- end -}}

{{/*
Return the value "Helm" without quotes.
*/}}
{{- define "sample-app.managedBy" -}}
{{- printf "Helm" -}}
{{- end -}}
