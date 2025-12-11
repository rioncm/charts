# Chart Design Specifications

Charts in this repository are tuned to my default Kubernetes environment. Each individual chart README documents any exceptions. This file captures the shared assumptions that every new chart must inherit.

## Design Operating Environment

- Kubernetes distribution: k3s
  - Three control-plane nodes, nine workers
  - Nodes are upgraded on a regular cadence; charts should tolerate rolling upgrades
- Most workloads run behind a firewall on private networks
- Projects that require internet exposure use split-horizon DNS with a Web Application Firewall (WAF) at the edge
- Charts apply sensible security defaults but are not hardened for hostile multi-tenant clusters
- Helm 3 only; templates should rely on supported Helm capabilities (no Helm 2 compatibility)

## Repository Baseline

- Chart structure follows Helm best practices (`Chart.yaml`, `values.yaml`, `templates/`, helpers, NOTES)
- Default namespace is defined per chart and may be overridden via `.Values.namespace`
- Image repositories, tags, and pull policies must be configurable; prefer upstream official images
- Where possible, charts should render cleanly with `helm template` using default values
- Avoid embedding secrets, credentials, or generated certs in the chart; reference existing Kubernetes resources instead

# Default Configurations

## Ingress and Networking

- Traefik is the default ingress controller and only supported implementation unless stated otherwise
- Standard annotations:
  - `traefik.ingress.kubernetes.io/router.entrypoints=websecure`
  - `cert-manager.io/cluster-issuer=letsencrypt-prod`
- HTTPS redirect option is exposed in values and enabled by default
- When public access is required, document any WAF- or DNS-specific hostnames
- Service exposure defaults to `ClusterIP`; use `LoadBalancer` only when strictly necessary

## TLS Termination

- Cert-Manager manages all TLS assets; other issuers are out of scope unless explicitly added to a chart
- Certificates reference DNS entries managed through split-horizon DNS
- Charts must not generate self-signed certificates automatically

## Storage and Persistence

- PersistentVolumeClaims may be created by the chart or reference an `existingClaim`
- Storage defaults: `ReadWriteOnce`, 10Gi (override per workload)
- Support optional persistence toggles so stateless deployments can run without volumes when appropriate
- For file stores (e.g., Outline uploads), expose storage class, size, and reclaim policy in `values.yaml`

## Secrets and Configuration

- Secrets are never templated directly; charts reference pre-created secrets supplied via values
- Document required keys (e.g., `DATABASE_URL`, `SECRET_KEY`, etc.) in the chart README
- ConfigMaps may hold non-sensitive defaults but should be overridable via `.Values`
- When multiple files or credentials are required (e.g., API keys, config certs), provide explicit `existingSecret` and key settings for each item

## External Services

- Databases are externalized unless the upstream app bundles an embedded option that is production-ready
- Common patterns:
  - PostgreSQL: Provide connection URL, SSL mode, and connection pool overrides
  - MySQL/MariaDB: Provide DSN and TLS options
  - Redis: Offer internal sidecar and external endpoint toggles
- Outline, Metabase, Odoo, and similar apps rely on managed databases; new charts should follow the same model

## Scaling and Availability

- `replicaCount` defaults to 1 but charts should support scaling (HPA toggles when applicable)
- Readiness and liveness probes must be defined with reasonable defaults (paths, delays, thresholds)
- Resource requests/limits are required; use conservative defaults consistent with existing charts (e.g., 500m/512Mi requests)
- Charts should allow pod disruption budgets, affinity, tolerations, and node selectors via values
- Charts include a bool value setting to add a default preventing running on control-planes 
    ```no-control-plane: true | false```

``` yaml
affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
          - matchExpressions:
              - key: node-role.kubernetes.io/control-plane
                operator: DoesNotExist
```

## Security Posture

- Service accounts are created per chart with the ability to disable/override via values
- Pods run as non-root (`runAsUser: 1000`, `fsGroup: 2000`) and drop all capabilities by default
- `allowPrivilegeEscalation` is disabled unless the workload explicitly needs it
- Network policies are optional today; document if a chart expects one

## Observability and Operations

- Charts should emit structured logs and allow overrides for log level or verbosity when the app supports it
- Include NOTES.txt guidance for verifying deployments (e.g., `kubectl port-forward`, ingress URLs)
- When upstream apps expose metrics endpoints, surface the service/port names so operators can scrape them
- Document backup/restore considerations for PVCs and databases

## Testing and Release Expectations

- Before publishing changes, run `helm lint` and `helm template` against representative values files (production and development profiles where available)
- Chart version bumps are required for any template/value change; keep `README.md` in sync
- Artifact Hub metadata (if present) must be updated with new releases
- When adding new configuration, include schema updates (`values.schema.json`) if the chart already maintains one

# Future Enhancements To Track

- Evaluate adding opinionated PodSecurityStandards labels when k3s enforces PSP replacements
- Consider documenting guidance for GitOps (Flux/Argo) installs as more workloads move to declarative pipelines
- Collect reusable helper templates for common patterns (Ingress TLS, annotations, resource presets) to reduce duplication across charts
