# Outline Helm Chart (Simplified)# Outline Helm Chart



This chart packages the [Outline](https://www.getoutline.com/) knowledge base for Kubernetes with a streamlined feature set focused on production readiness without automatic secret generation or bundled databases. It is designed around the requirements captured in `reference/chart-plan-simple.md` and keeps sensitive configuration outside of the chart itself.A robust Helm chart for deploying [Outline](https://www.getoutline.com/), the fastest wiki and knowledge base for growing teams.


## Current Status 

**Functional**
This chart has been deployed and is in current use. Extensive testing has not been completed. Additional development may to cover full functionality. External database has been tested and is recomended. 

## Key Features## Features



- Ships Outline `outlinewiki/outline:0.87.4` by default (overrideable via values)- 🚀 **Kubernetes-native**: Built from the ground up for Kubernetes

- Exposes all configuration through environment variables- 🔐 **Flexible secret management**: Auto-generation with Helm hooks or external secret references

- No in-cluster database – you must provide an external PostgreSQL connection string- 🗄️ **Database flexibility**: Optional PostgreSQL deployment or external database support

- Optional in-pod Redis sidecar (enabled by default) or external Redis endpoint- 📦 **Redis sidecar**: Built-in Redis or external Redis support

- Optional one-time database initialization via an init container- 🔧 **Multiple auth providers**: Slack, Google, Azure, Discord, OIDC support

- Supports mounting existing secrets or configmaps through `extraEnvFrom`- 🌐 **Ingress ready**: Traefik and cert-manager defaults

- Provides Kubernetes-native Service and Ingress resources with Traefik-friendly defaults- 📁 **Persistent storage**: Local PVC or S3-compatible storage

- Includes PVC management for local file storage- 🔌 **Integrations**: GitHub, Linear, Slack, Sentry, Notion, and more

- 📊 **Schema validation**: Complete values.yaml validation

## Using This Chart

## Prerequisites

1. Review the environment variable expectations in `reference/env-sample.env` and the Docker Compose example in `reference/compose-sample.yaml`.

2. Create a Kubernetes secret that contains at minimum:- Kubernetes 1.19+

   - `SECRET_KEY`- Helm 3.2.0+

   - `UTILS_SECRET`- PV provisioner support in the underlying infrastructure (if persistence is enabled)

   - `DATABASE_URL`

   - Any provider credentials (for example `GOOGLE_CLIENT_ID` / `GOOGLE_CLIENT_SECRET`)

## Installation

### OCI Registry (Recommended)

Install directly from GitHub Container Registry:

```bash
# Install with default values
helm install outline oci://ghcr.io/rioncm/charts/outline \
  --namespace outline-project \
  --create-namespace

# Or with custom configuration
helm install outline oci://ghcr.io/rioncm/charts/outline \
  --namespace outline-project \
  --create-namespace \
  --set outline.url="https://docs.example.com" \
  --set database.existingSecret="outline-secrets"
```

### Local Installation

If installing from a local copy of the chart:

```bash
helm install outline . --namespace outline-project --create-namespace
```

### Production Installation

For production deployments, create a custom values file:



outline:```yaml

  url: "https://docs.example.com"# values-prod.yaml

outline:

extraEnv:  url: "https://docs.yourcompany.com"

  - name: SMTP_HOST

    value: relay.example.com# Use external PostgreSQL

  - name: SMTP_PORTpostgresql:

    value: "25"  enabled: false

  external:

ingress:    host: "postgres.yourcompany.com"

  enabled: true    database: "outline"

  className: traefik    username: "outline"

  annotations:    password: "secure-password"

    cert-manager.io/cluster-issuer: letsencrypt-prod

    traefik.ingress.kubernetes.io/router.entrypoints: websecure 


  hosts:  providers:

    - host: docs.example.com    google:

      paths:      enabled: true

        - path: /      clientId: "your-google-client-id"

          pathType: Prefix      clientSecret: "your-google-client-secret"

  tls:

    - secretName: outline-tls# Configure ingress

      hosts:ingress:

        - docs.example.com  hosts:

```    - host: docs.yourcompany.com

      paths:

Apply with:        - path: /

          pathType: Prefix
  tls:
    - secretName: docs-yourcompany-com-tls
      hosts:
        - docs.yourcompany.com
```

Then install:

```bash
helm install outline oci://ghcr.io/rioncm/charts/outline \
  -f values-prod.yaml \
  --namespace outline-project \
  --create-namespace
```

## Configuration Reference

# Enable persistence

- **namespace** – Namespace written into resource manifests (defaults to `outline-project`).persistence:

- **image** – Repository / tag / pull policy for the Outline container image.  enabled: true

- **secrets.existingSecret** – Main secret mounted via `envFrom` for sensitive Outline variables.  size: 50Gi

- **database** – Controls database initialization and how `DATABASE_URL` is provided. Set `database.url` for inline values _or_ point to `database.existingSecret` / `database.existingSecretKey`.  storageClass: "fast-ssd"

- **redis** – Toggle the built-in Redis sidecar or provide `redis.externalUrl` for a managed Redis service.```

- **fileStorage** – Configure `local` (PVC-backed) or `s3` storage. When using S3, supply credentials via secrets and fill in the non-sensitive keys here.

- **extraEnv / extraEnvFrom** – Append additional environment variables or entire secrets/configmaps to both the main container and the init job.Then install:

- **persistence** – PVC controls for local storage. Disable for ephemeral deployments.

- **ingress** – Traefik-oriented defaults with TLS support. Adjust class/annotations as needed.```bash

Then install:

```bash
helm install outline oci://ghcr.io/rioncm/charts/outline \
  -f values-prod.yaml \
  --namespace outline-project \
  --create-namespace
```

Consult `values.yaml` and `values.schema.json` for the full list of tunables and validation rules.

## Configuration

## Database Initialization

If `database.initialize: true` (default), the chart launches an init container that applies Outline's database schema using Sequelize migrations:

```
yarn sequelize db:migrate --env=production
```

When `database.sslMode` is set to `disable`, the init container automatically switches to `--env=production-ssl-disabled` so that migrations run without SSL. The PostgreSQL database itself must already exist; the job only applies schema updates. If you manage migrations externally, set `database.initialize: false` to skip the init container entirely.

Ensure that `DATABASE_URL` (and any SSL settings such as `PGSSLMODE`) are accessible to the init container via the referenced configmap or secret entries.



## Secret Management#### Internal PostgreSQL (Development)



This chart never creates or mutates Kubernetes secrets. Use your preferred workflow (External Secrets Operator, Sealed Secrets, Vault, etc.) to provision the required environment variables and reference them through `secrets.existingSecret` or `extraEnvFrom`.```yaml

postgresql:

## Redis Options  enabled: true

  persistence:

- **Sidecar (default)** – Lightweight Redis container colocated with Outline (`redis.enabled: true`). `REDIS_URL` is automatically set to `redis://localhost:6379`.    enabled: true

- **External** – Disable the sidecar and set `redis.externalUrl` to the connection string for your managed Redis instance.    size: 8Gi

```

## Development Notes

#### External PostgreSQL (Recommended for Production)

- The legacy, feature-rich chart has been moved to `future-development/` for reference.

- Keep sensitive overlays and production values in the `private/` directory; update `.gitignore` for any additional local files.```yaml

- `helm lint` and `helm template` should be run from this directory before publishing new versions.postgresql:

  enabled: false

## Further Reading  external:

    host: "your-postgres-host"

- Official Outline environment reference: `reference/env-sample.env`    port: 5432

- Docker Compose example from upstream docs: `reference/compose-sample.yaml`    database: "outline"

- Design goals and checklist: `reference/chart-plan-simple.md`    username: "outline"

```    password: "your-password"
    sslMode: "require"
```

### Redis Configuration

#### Sidecar Redis (Default)

```yaml
redis:
  enabled: true
  resources:
    limits:
      cpu: 100m
      memory: 128Mi
```

#### External Redis

```yaml
redis:
  enabled: false
  external:
    url: "redis://your-redis-host:6379"
```

### Authentication Providers

#### Google OAuth

```yaml
auth:
  providers:
    google:
      enabled: true
      clientId: "your-google-client-id"
      clientSecret: "your-google-client-secret"
```

#### Slack OAuth

```yaml
auth:
  providers:
    slack:
      enabled: true
      clientId: "your-slack-client-id"
      clientSecret: "your-slack-client-secret"
```

#### Azure/Entra ID

```yaml
auth:
  providers:
    azure:
      enabled: true
      clientId: "your-azure-client-id"
      clientSecret: "your-azure-client-secret"
      resourceAppId: "your-resource-app-id"
```

#### Generic OIDC

```yaml
auth:
  providers:
    oidc:
      enabled: true
      clientId: "your-oidc-client-id"
      clientSecret: "your-oidc-client-secret"
      authUri: "https://your-provider.com/auth"
      tokenUri: "https://your-provider.com/token"
      userinfoUri: "https://your-provider.com/userinfo"
      displayName: "Your SSO Provider"
```

### File Storage

#### Local Storage (Default)

```yaml
fileStorage:
  type: "local"

persistence:
  enabled: true
  size: 10Gi
  storageClass: "your-storage-class"
```

#### S3-Compatible Storage

```yaml
fileStorage:
  type: "s3"
  s3:
    region: "us-west-2"
    uploadBucketName: "outline-uploads"
    accessKeyId: "your-access-key"
    secretAccessKey: "your-secret-key"
    uploadBucketUrl: "https://s3.amazonaws.com"
    forcePathStyle: false
    acl: "private"
```

### Integrations

#### GitHub Integration

```yaml
integrations:
  github:
    enabled: true
    clientId: "your-github-app-client-id"
    clientSecret: "your-github-app-client-secret"
    webhookSecret: "your-webhook-secret"
    appId: "your-github-app-id"
    appPrivateKey: |
      -----BEGIN RSA PRIVATE KEY-----
      your-github-app-private-key
      -----END RSA PRIVATE KEY-----
```

#### Using External Secrets

```yaml
integrations:
  github:
    enabled: true
    existingSecret: "github-integration-secret"
```

### Secret Management

#### Auto-generated Secrets (Default)

```yaml
secrets:
  autoGenerate: true
```

This will automatically generate:
- `SECRET_KEY`: 32-byte hex key for general encryption
- `UTILS_SECRET`: 32-byte hex key for utilities
- `POSTGRES_PASSWORD`: PostgreSQL password (auto-generated for internal DB or taken from values)
- `DATABASE_URL`: Complete connection string derived from chart values

#### Manual Secret Management

```yaml
secrets:
  autoGenerate: false
  secretKey: "your-32-byte-hex-secret-key"
  utilsSecret: "your-32-byte-hex-utils-secret"
  postgresPassword: "your-db-password"
  # Optional override (otherwise derived from postgresql.* values)
  databaseUrl: "postgres://outline:your-password@postgres:5432/outline"
```

When `autoGenerate` is disabled you must provide either `secrets.postgresPassword` (so the chart can build `DATABASE_URL`) or the full `secrets.databaseUrl` string yourself.

#### External Secret Reference

```yaml
secrets:
  existingSecret: "outline-secrets"
```

When `secrets.existingSecret` is set the chart will not create or mutate any secrets; instead it will mount the referenced secret into the Outline pod. This is the preferred pattern when credentials are provisioned by tools such as External Secrets Operator, Vault, or Sealed Secrets.

#### Providing Auth Provider Credentials via an Existing Secret

Create a secret that contains the minimum required keys for Outline plus any authentication providers you plan to use. The key names must match the environment variables expected by Outline:

| Provider | Required keys |
|----------|----------------|
| Google | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` |
| Slack | `SLACK_CLIENT_ID`, `SLACK_CLIENT_SECRET` |
| Azure / Entra | `AZURE_CLIENT_ID`, `AZURE_CLIENT_SECRET`, `AZURE_RESOURCE_APP_ID` (if required) |
| Discord | `DISCORD_CLIENT_ID`, `DISCORD_CLIENT_SECRET`, optional `DISCORD_SERVER_ID`, `DISCORD_SERVER_ROLES` |
| OIDC | `OIDC_CLIENT_ID`, `OIDC_CLIENT_SECRET`, plus any of `OIDC_AUTH_URI`, `OIDC_TOKEN_URI`, `OIDC_USERINFO_URI`, `OIDC_LOGOUT_URI`, `OIDC_USERNAME_CLAIM`, `OIDC_DISPLAY_NAME`, `OIDC_SCOPES` |

Example secret manifest:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: outline-secrets
  namespace: outline-project
type: Opaque
stringData:
  SECRET_KEY: "$(openssl rand -hex 32)"
  UTILS_SECRET: "$(openssl rand -hex 32)"
  GOOGLE_CLIENT_ID: "your-google-client-id"
  GOOGLE_CLIENT_SECRET: "your-google-client-secret"
  SLACK_CLIENT_ID: "your-slack-client-id"
  SLACK_CLIENT_SECRET: "your-slack-client-secret"
  POSTGRES_PASSWORD: "your-external-postgres-password"
  DATABASE_URL: "postgres://outline-user:your-external-postgres-password@postgres.yourcompany.com:5432/outline?sslmode=require"
```

You can omit any provider-specific keys that are not in use. Once the secret is created, reference it in `values.yaml`:

```yaml
secrets:
  existingSecret: "outline-secrets"

auth:
  providers:
    google:
      enabled: true
    slack:
      enabled: true
```

#### Pulling External PostgreSQL Passwords from Another Secret

If the database password already lives in a separate Kubernetes Secret (for example, one managed by your database team), reference it directly. The pre-install hook will read the key, populate the Outline secret, and construct `DATABASE_URL` automatically:

```yaml
postgresql:
  enabled: false
  external:
    host: "postgres.yourcompany.com"
    port: 5432
    database: "outline"
    username: "outline"
    existingSecret: "shared-postgres-credentials"
    existingSecretKey: "password"
    sslMode: "require"
```

Optionally set `secrets.postgresPassword` if you need to override the password for manual secret rendering or CI templating without the hook job.

#### External PostgreSQL Passwords in Outline Secrets

For external PostgreSQL deployments you can store the connection details exclusively inside the Outline secret. Ensure the secret contains at least `POSTGRES_PASSWORD` and `DATABASE_URL` (matching the format above). Then configure the external connection details without embedding the password in `values.yaml`:

```yaml
secrets:
  existingSecret: "outline-secrets"

postgresql:
  enabled: false
  external:
    host: "postgres.yourcompany.com"
    port: 5432
    database: "outline"
    username: "outline"
  # credentials are supplied via the referenced secret (POSTGRES_PASSWORD & DATABASE_URL)
    sslMode: "require"
```

If you manage secrets outside of Kubernetes (for example, AWS Secrets Manager or HashiCorp Vault), synchronize the data into the referenced Kubernetes Secret using your preferred operator, keeping the same key names shown above.

### Environment Variables

Most Outline settings are generated automatically through the chart’s ConfigMap and Secrets, but you can layer additional variables as needed.

#### Inline Variables via `values.yaml`

Use the `env` array to append extra variables directly to the Outline container:

```yaml
env:
  - name: "OUTLINE_WHITELIST_DOMAINS"
    value: "example.com,example.org"
  - name: "OUTLINE_FORCE_HTTPS"
    value: "true"
```

#### Referencing Secret Keys

Target individual keys from existing secrets using `valueFrom`:

```yaml
env:
  - name: "GOOGLE_ANALYTICS_ID"
    valueFrom:
      secretKeyRef:
        name: outline-analytics
        key: ga-id
```

#### Importing Entire Secrets or ConfigMaps

If you want to expose several variables at once, append additional `envFrom` entries. These sources are mounted **after** the chart’s default ConfigMap and Secret references, so they can override defaults when needed.

```yaml
envFrom:
  - secretRef:
      name: outline-extra-secrets
  - configMapRef:
      name: outline-extra-config
```

You can combine `env`, `envFrom`, and `secrets.existingSecret` to meet complex configuration requirements. When values collide, Kubernetes resolves them in declaration order (later entries win).

### Ingress Configuration

#### Traefik with cert-manager (Default)

```yaml
ingress:
  enabled: true
  className: "traefik"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"

  hosts:
    - host: docs.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: outline-tls
      hosts:
        - docs.example.com
```

#### nginx-ingress

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: docs.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: outline-tls
      hosts:
        - docs.example.com
```

## Troubleshooting

### Database Initialization

If the database fails to initialize, check the logs:

```bash
kubectl logs -n outline-project deployment/outline-outline -c outline
```

You can manually rerun the migrations:

```bash
kubectl exec -n outline-project deployment/outline-outline -c outline -- yarn sequelize db:migrate --env=production
```

Add `--env=production-ssl-disabled` instead if you are running without PostgreSQL SSL (`database.sslMode: disable`).

### Secret Generation

If auto-generated secrets fail, check the secret generation job:

```bash
kubectl get jobs -n outline-project
kubectl logs -n outline-project job/outline-secret-generator
```

### Authentication Issues

Ensure your authentication provider configuration matches your OAuth app settings:
- Redirect URLs must match your outline.url
- Client IDs and secrets must be correct
- Appropriate scopes must be granted

### File Upload Issues

For local storage, ensure the PVC is properly mounted:

```bash
kubectl get pvc -n outline-project
kubectl describe pvc outline -n outline-project
```

For S3 storage, verify your credentials and bucket permissions.

## Values Reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `namespace` | string | `"outline-project"` | Namespace for all resources |
| `outline.url` | string | `""` | **Required**: Instance URL |
| `secrets.autoGenerate` | bool | `true` | Auto-generate secrets |
| `postgresql.enabled` | bool | `false` | Enable internal PostgreSQL |
| `redis.enabled` | bool | `true` | Enable Redis sidecar |
| `fileStorage.type` | string | `"local"` | Storage type: local or s3 |
| `persistence.enabled` | bool | `true` | Enable persistent storage |
| `ingress.enabled` | bool | `true` | Enable ingress |

For a complete list of configuration options, see [values.yaml](values.yaml).

## Contributing

1. Make changes to templates or values
2. Test with `helm template` or `helm install --dry-run`
3. Update this README if needed
4. Test the schema validation: `helm lint .`

## License

This Helm chart is provided under the same license as Outline itself.