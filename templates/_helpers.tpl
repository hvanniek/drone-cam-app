{{- define "drone-cam.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "drone-cam.fullname" -}}
{{- if .Release.Name | eq .Chart.Name -}}
{{- .Chart.Name -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "drone-cam.labels" -}}
app.kubernetes.io/name: {{ include "drone-cam.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
{{- end -}}

{{- define "drone-cam.selectorLabels" -}}
app.kubernetes.io/name: {{ include "drone-cam.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Whether to render the Route: honors an explicit "true"/"false" override,
otherwise auto-detects the route.openshift.io/v1 API on the destination cluster.
*/}}
{{- define "drone-cam.routeEnabled" -}}
{{- $mode := .Values.route.enabled | toString -}}
{{- if eq $mode "true" -}}
true
{{- else if eq $mode "false" -}}
false
{{- else if .Capabilities.APIVersions.Has "route.openshift.io/v1" -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}
