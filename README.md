# drone-cam-app

Helm chart for a simple demo app (`quay.io/kenosborn/drone-cam:v1`, port 8081),
meant to be deployed via ArgoCD to a managed MicroShift or OpenShift cluster
from the hub. Originally split out of the `edge-management-demo` workspace's
`application/` directory.

## Files

| File | Purpose |
|---|---|
| `Chart.yaml`, `values.yaml`, `templates/` | The Helm chart: Deployment, Service, and a conditional Route. |
| `argocd-application.yaml` | Example ArgoCD `Application` pointing at this chart. |

## How it targets both cluster types with one chart

`templates/route.yaml` only renders when `route.openshift.io/v1` is present on
the destination cluster (`.Capabilities.APIVersions.Has "route.openshift.io/v1"`,
see `templates/_helpers.tpl`). ArgoCD populates Helm's `.Capabilities` from the
actual destination cluster it's syncing to, so:

- synced to a full OpenShift cluster (e.g. `dev-acp4` once provisioned) -> Route created
- synced to a plain MicroShift cluster (e.g. an `rhde/fleet.yaml` device) -> Service only

Override with `route.enabled: "true"|"false"` in values if a MicroShift
cluster has the optional route-controller-manager RPM installed, or if you
want to force it off on OpenShift.

## Using it

```console
helm lint .
helm template drone-cam .                                          # microshift-like (no Route API)
helm template drone-cam . --api-versions route.openshift.io/v1     # openshift-like
```

To deploy via ArgoCD, edit `argocd-application.yaml`'s `spec.destination` —
the target managed cluster (`name` if it's registered as an ArgoCD cluster
secret, e.g. via ACM's GitOpsCluster addon; otherwise `server` with its API
URL) — then:

```console
oc apply -f argocd-application.yaml
```

No image pull secret is needed — `quay.io/kenosborn/drone-cam` is public.
