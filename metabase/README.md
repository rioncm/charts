# Metabase Helm Chart

This Helm chart deploys Metabase on a Kubernetes cluster using the Helm package manager.

## Current Status 

**Functional**
This chart has been deployed and is in current use. Extensive testing has not been completed. Additional development needed to cover full functionality. External database is recomended. 

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- PV provisioner support in the underlying infrastructure (for persistent storage)
- cert-manager (if using automatic TLS certificate generation)

## Installing the Chart

To install the chart with the release name `metabase`:

```bash
helm install metabase ./metabase
```

To install with custom values:

```bash
helm install metabase ./metabase -f custom-values.yaml
```

## Configuration

The following table lists the configurable parameters and their default values:

### Basic Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of Metabase replicas | `1` |
| `image.repository` | Metabase image repository | `metabase/metabase` |
| `image.tag` | Metabase image tag | `v0.50.0` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `nameOverride` | Override the name | `""` |
| `fullnameOverride` | Override the full name | `""` |

### Service Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `service.type` | Kubernetes service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `internalHostname` | Internal service name for in-cluster access | `metabase` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `""` |
| `ingress.annotations` | Ingress annotations | See values.yaml |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | See values.yaml |

### Persistence Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable persistent storage | `true` |
| `persistence.storageClass` | Storage class name | `""` (default) |
| `persistence.accessMode` | Access mode | `ReadWriteOnce` |
| `persistence.size` | Storage size | `10Gi` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `database.type` | Database type (h2, postgresql, mysql) | `h2` |
| `database.postgresql.*` | PostgreSQL configuration | See values.yaml |
| `database.mysql.*` | MySQL configuration | See values.yaml |

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.limits.cpu` | CPU limit | `1000m` |
| `resources.limits.memory` | Memory limit | `2Gi` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `1Gi` |

### Metabase Specific Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `metabase.siteUrl` | Site URL for email links | `""` |
| `metabase.javaOpts` | Java options | `"-Xmx1g"` |
| `metabase.timezone` | Timezone | `"UTC"` |
| `metabase.admin.email` | Admin email | `""` |
| `metabase.admin.password` | Admin password | `""` |

## Examples

### Basic Installation with Ingress

```yaml
# values-basic.yaml
ingress:
  enabled: true
  hosts:
    - host: metabase.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: metabase-tls
      hosts:
        - metabase.yourdomain.com

metabase:
  siteUrl: "https://metabase.yourdomain.com"
```

```bash
helm install metabase ./metabase -f values-basic.yaml
```

### Production Setup with PostgreSQL

```yaml
# values-production.yaml
ingress:
  enabled: true
  hosts:
    - host: metabase.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: metabase-tls
      hosts:
        - metabase.yourdomain.com

database:
  type: postgresql
  postgresql:
    host: postgres.database.svc.cluster.local
    port: 5432
    database: metabase
    username: metabase
    existingSecret: metabase-db-secret
    secretKey: password

persistence:
  size: 20Gi
  storageClass: fast-ssd

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi

metabase:
  siteUrl: "https://metabase.yourdomain.com"
  javaOpts: "-Xmx2g"
```

```bash
helm install metabase ./metabase -f values-production.yaml
```

### Development Setup

```yaml
# values-dev.yaml
persistence:
  size: 5Gi

resources:
  limits:
    cpu: 500m
    memory: 1Gi
  requests:
    cpu: 250m
    memory: 512Mi

metabase:
  admin:
    email: admin@example.com
    password: admin123
    firstName: "Admin"
    lastName: "User"
```

```bash
helm install metabase-dev ./metabase -f values-dev.yaml
```

## Upgrading

To upgrade the chart:

```bash
helm upgrade metabase ./metabase
```

## Uninstalling

To uninstall/delete the deployment:

```bash
helm delete metabase
```

**Note**: This will not delete the persistent volume claim. To delete it:

```bash
kubectl delete pvc metabase-data
```

## Troubleshooting

### Common Issues

1. **Pod stuck in pending state**: Check if PVC can be provisioned
2. **Database connection issues**: Verify database credentials and connectivity
3. **Ingress not working**: Ensure ingress controller is installed and annotations are correct

### Logs

To check Metabase logs:

```bash
kubectl logs -l app.kubernetes.io/name=metabase
```

### Database Migration

When upgrading Metabase versions, database migrations may take time. Monitor the logs for migration progress.

## Security Considerations

1. Always use external databases (PostgreSQL/MySQL) in production
2. Enable TLS for ingress
3. Use Kubernetes secrets for sensitive data
4. Regularly update Metabase to the latest version
5. Configure proper RBAC and network policies

## Support

For Metabase specific issues, refer to the [Metabase documentation](https://www.metabase.com/docs/).
For Kubernetes deployment issues, check the pod logs and events.
