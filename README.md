# Helm Charts Repository

This repository contains a collection of Helm charts for deploying various applications on Kubernetes. Each chart is designed for production use with external database support and secure configuration practices.

## Available Charts

### 📝 [Outline](./outline/) - Knowledge Base & Wiki
**Version:** 0.1.3 | **App Version:** 0.87.4 | **Status:** Functional ✅

A robust Helm chart for deploying [Outline](https://www.getoutline.com/), the fastest wiki and knowledge base for growing teams.

**Key Features:**
- 🚀 Kubernetes-native with streamlined configuration
- 🔐 External secret management (no auto-generated secrets)
- 🗄️ External PostgreSQL database support (required)
- 📦 Optional Redis sidecar or external Redis
- 🔧 Multiple auth providers (Google, Slack, Azure, Discord, OIDC)
- 🌐 Ingress ready with Traefik and cert-manager defaults
- 📁 Local PVC or S3-compatible storage

**Prerequisites:** Kubernetes 1.23+, External PostgreSQL, Helm 3.2.0+

---

### 📚 [BookStack](./bookstack/) - Wiki Platform
**Version:** 0.2.2 | **App Version:** v25.02 | **Status:** In Testing 🧪

A Helm chart for deploying [BookStack](https://www.bookstackapp.com/) - a simple, self-hosted, easy-to-use wiki platform.

**Key Features:**
- 📖 Simple and intuitive wiki interface
- 🗄️ External MySQL/MariaDB database support
- 💾 Persistent storage for file uploads
- 🌐 Ingress with SSL support via cert-manager
- 🔧 Comprehensive configuration options
- 🛡️ Production-ready with health checks and security contexts

**Prerequisites:** Kubernetes 1.19+, External MySQL/MariaDB, Ingress controller

---

### 📊 [Metabase](./metabase/) - Business Intelligence
**Version:** 0.1.2 | **App Version:** 0.56.6.x | **Status:** Functional ✅

A Helm chart for deploying [Metabase](https://www.metabase.com/) - an open-source business intelligence tool for creating dashboards and analyzing data.

**Key Features:**
- 📈 Business intelligence and data visualization
- 🗄️ External database support recommended
- 💾 Persistent storage for application data
- 🌐 Configurable ingress and SSL termination
- 🔧 Flexible configuration through values.yaml
- 📊 Dashboard creation and data analysis tools

**Prerequisites:** Kubernetes 1.16+, Helm 3.0+, External database (recommended)

---

### 🏢 [ODOO](./odoo/) - ERP & CRM Platform
**Version:** 1.0.0 | **App Version:** 18.0 | **Status:** In Development 🚧

A clean, generic Helm chart for deploying [ODOO](https://www.odoo.com/) using the official Docker image - an open source ERP and CRM platform.

**Key Features:**
- 🏪 Complete ERP and CRM solution
- 🗄️ External PostgreSQL database only (no embedded DB)
- 🧹 Clean implementation without Bitnami dependencies
- ⚙️ Uses official `docker.io/odoo:18.0` image
- 📧 SMTP configuration support
- 🔧 Resource presets and configurable probes

**Prerequisites:** Kubernetes 1.19+, Helm 3.x, External PostgreSQL database

---

## Installation

Each chart can be installed from this repository:

```bash
# Add this repository (if hosted)
helm repo add charts https://your-repo-url

# Or install directly from local files
helm install my-release ./chart-name/

# With custom values
helm install my-release ./chart-name/ -f custom-values.yaml
```

## Status Legend

- ✅ **Functional** - Deployed and in production use
- 🧪 **In Testing** - Deployed but undergoing validation
- 🚧 **In Development** - Not yet tested or deployed

## Contributing

When contributing to these charts:

1. Update the chart version in `Chart.yaml`
2. Test with `helm lint` and `helm template`
3. Update the README with any configuration changes
4. Ensure external database configurations are documented

## Support

Each chart includes comprehensive documentation in its respective directory. For issues or questions, please refer to the individual chart README files or create an issue in this repository.