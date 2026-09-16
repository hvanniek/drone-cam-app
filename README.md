# drone-cam-app

Helm chart for a simple demo app (`quay.io/kenosborn/drone-cam:v1`, port 8081),
meant to be deployed via ArgoCD to a managed MicroShift or OpenShift cluster
from the hub. Originally split out of the `edge-management-demo` workspace's
`application/` directory.

## Files

| File | Purpose |
|---|---|
| `Chart.yaml`, `values.yaml`, `templates/` | The Helm chart: Deployment, Service, and a conditional Route. |
| `gitops-placement.yaml` | `Placement` (label-selector) + `ApplicationSet` that roll this chart out to every labeled managed cluster. |

## Rollout: label-driven, not per-cluster files

`gitops-placement.yaml`'s `Placement` matches any `ManagedCluster` in the
`abb-demo` `ClusterSet` labeled `application.drone-cam=true`; its
`ApplicationSet` turns each match into a push-model `Application` (named
`drone-cam-<cluster>`) synced directly from the hub. To add or drop a cluster
from the rollout, just label/unlabel it — no new files needed:

```console
oc label managedcluster <cluster-name> application.drone-cam=true
```

The cluster must already be registered as an ArgoCD cluster secret in
`openshift-gitops` (see the hub's `systems-argocd-cluster-placement`) for the
generator to resolve a `{{server}}` for it.

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

To stand up the rollout mechanism itself (one-time, on the hub):

```console
oc apply -f gitops-placement.yaml
```

Then deploy to a cluster by labeling it (see above) — no further `oc apply` needed per cluster.

No image pull secret is needed — `quay.io/kenosborn/drone-cam` is public.
