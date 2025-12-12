# GPROX Helm Chart

Helm chart for deploying GPROX, a lightweight Flask-based ACME DNS proxy that brokers `acme.sh` requests to Google Cloud DNS. The chart follows the shared repository design spec (k3s, Traefik, cert-manager) and assumes you provide two pre-existing secrets that store the runtime configuration and Google service account file.

## Prerequisites

- Kubernetes 1.26+ (k3s cluster with three control planes/nine workers per design spec)
- Helm 3.12+
- Traefik ingress controller and cert-manager (`letsencrypt-prod` ClusterIssuer) available
- Google Cloud project with Cloud DNS API enabled and service account holding `roles/dns.admin`
- Existing Kubernetes secrets that contain `config.yaml` and `gcloud.json`

## Required Secrets

```bash
# Config file with API keys, allowed zones, log level, etc.
kubectl create secret generic gprox-config \
  --from-file=config.yaml=./config.yaml

# Google Cloud service account JSON key
kubectl create secret generic gprox-gcloud \
  --from-file=google.json=./gcloud.json
```

If you name the secrets differently, update `.Values.secrets.config.existingSecret` and `.Values.secrets.gcloud.existingSecret` accordingly. Both volumes are mounted read-only under `/etc/gprox` and the container sets `GPROX_CONFIG_PATH` to the mounted config file.

## Installation

```bash
helm install gprox charts/gprox \
  --namespace gprox \
  --create-namespace \
  -f charts/gprox/examples/values-prod.yaml
```

## Configuration Highlights

| Key | Description | Default |
| --- | --- | --- |
| `namespace` | Target namespace override | `gprox` |
| `replicaCount` | Pod replicas when autoscaling disabled | `2` |
| `autoscaling.*` | Optional HorizontalPodAutoscaler settings | disabled |
| `image.repository` | Container image | `ghcr.io/pminc/gprox` |
| `ingress.*` | Traefik ingress + cert-manager annotations | Enabled |
| `secrets.config.existingSecret` | Secret containing `config.yaml` | `""` (falls back to `<release>-config`)
| `secrets.gcloud.existingSecret` | Secret containing service account JSON | `""` (falls back to `<release>-gcloud`)
| `noControlPlane` | Adds node affinity to avoid control-plane nodes | `true` |
| `tmpfs.enabled` | Mounts memory-backed `/tmp` for Gunicorn/Prometheus workers | `true` (`/tmp`, medium `Memory`) |
| `metrics.enabled` | Adds Prometheus scrape annotations on the Service | `true` (path `/metrics`) |
| `metrics.serviceMonitor.enabled` | Creates a `ServiceMonitor` resource for the chart | `false` |
| `livenessProbe` / `readinessProbe` | Hits `/v1/health` | Enabled |
| `podDisruptionBudget.enabled` | Ensures minimum pods remain during maintenance | `false` |

See `values.yaml` for the full list, including resource requests, security contexts, and optional `extraEnv`, `extraVolumes`, and Traefik-specific annotations.

## Example values

`charts/gprox/examples/values-prod.yaml` demonstrates a production-style configuration with:

- Custom ingress host (`gprox.example.com`)
- TLS secret issued by `letsencrypt-prod`
- Explicit secret names (`gprox-config`, `gprox-gcloud`)
- Autoscaling disabled but `replicaCount: 2`

## Operations

- Health endpoint: `GET /v1/health`
- Metrics endpoint: `GET /metrics` (annotations and optional `ServiceMonitor` provided)
- TXT management: `POST /v1/dns/add` and `/v1/dns/remove`
- Mount paths (read-only): `/etc/gprox/config.yaml`, `/etc/gprox/google.json`
- Writable runtime path: `/tmp` (mounted as `emptyDir` tmpfs and exported via `TMPDIR`/`PROMETHEUS_MULTIPROC_DIR`)

Check the rendered NOTES after installation for quick validation commands and a reminder about the required secrets. Before each release, run `helm lint charts/gprox` and `helm template` with representative values as described in the root `design_spec.md`.
