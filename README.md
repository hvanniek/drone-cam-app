# drone-cam-app

Helm chart for a simple demo app (`quay.io/kenosborn/drone-cam:v1`, port 8081),
meant to be deployed via ArgoCD to a managed MicroShift or OpenShift cluster
from the hub. Originally split out of the `edge-management-demo` workspace's
`application/` directory.

## Files

| File | Purpose |
|---|---|
| `Chart.yaml`, `values.yaml`, `templates/` | The Helm chart: Deployment, Service, and a conditional Route. |
| `argocd-application-dev-acp2.yaml` | ArgoCD `Application` deploying this chart to `dev-acp2` (managed OpenShift). |
| `argocd-application-snuc-ee2400.yaml` | ArgoCD `Application` deploying this chart to `snuc-ee2400` (managed MicroShift device). |

## How it targets both cluster types with one chart

`templates/route.yaml` only renders when `route.openshift.io/v1` is present on
the destination cluster (`.Capabilities.APIVersions.Has "route.openshift.io/v1"`,
see `templates/_helpers.tpl`). ArgoCD populates Helm's `.Capabilities` from the
actual destination cluster it's syncing to, so:

- synced to `dev-acp2` (full OpenShift) -> Route created
- synced to `snuc-ee2400` (plain MicroShift) -> Service only

Override with `route.enabled: "true"|"false"` in values if a MicroShift
cluster has the optional route-controller-manager RPM installed, or if you
want to force it off on OpenShift.

## Using it

```console
helm lint .
helm template drone-cam .                                          # microshift-like (no Route API)
helm template drone-cam . --api-versions route.openshift.io/v1     # openshift-like
```

To deploy to another managed cluster, copy one of the `argocd-application-*.yaml`
files, rename it, and change `metadata.name` and `spec.destination.name` to the
target cluster (must already be registered as an ArgoCD cluster secret in
`openshift-gitops` — see the hub's `systems-argocd-cluster-placement`). Then:

```console
oc apply -f argocd-application-<cluster>.yaml
```

No image pull secret is needed — `quay.io/kenosborn/drone-cam` is public.
