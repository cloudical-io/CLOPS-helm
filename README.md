# CLOPS Helm Chart
Installs various components to monitor your K8s cluster, including:
- [Kube-Prometheus-Stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
    - Alertmanager
    - Kube State Metrics
    - Prometheus Operator
    - Prometheus Node Exporter
    - Prometheus
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server/tree/master/charts/metrics-server)
- [Grafana](https://github.com/grafana/helm-charts/tree/main/charts/grafana)
- [Promtail](https://github.com/grafana/helm-charts/tree/main/charts/promtail)
- [Loki](https://github.com/grafana/loki/tree/main/production/helm/loki)
- [Prometheus Blackbox Exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-blackbox-exporter)

## Requirements
- An already running K8s cluster
- [Helm](https://helm.sh)

## Usage
Add the helm repo, edit the values.yaml to your liking and install the chart:

```
helm repo add clops https://harbor.cloudical.net/clops
helm upgrade --install --namespace clops --create-namespace clopsmonitoring clops/clops -f values.yaml
```

## Variables
| Parameter | Description | Default |
| --------- | ----------- | ------- |
| global.domain | Your domain | your.doma.in |
| kube-prometheus-stack.enabled | Enable Kube-Prometheus-Stack component | True |
| kube-prometheus-stack.fullnameOverride | Override the deployment name | prometheus-stack |
| kube-prometheus-stack.grafana.enabled | Enable Grafana inside Kube-Prometheus-Stack | False |
| kube-prometheus-stack.defaultRules.labels.role || alert-rules |
| kube-prometheus-stack.alertmanager.podDisruptionBudget.enabled | Enable PodDistributionBudget. For details see [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | True |
| kube-prometheus-stack.alertmanager.extraSecret.name | Name for the basic auth secret (If not set, it will be auto generated) | alertmanager-basic-auth |
| kube-prometheus-stack.alertmanager.extraSecret.data.auth | Basic auth username and password as bcrypt hashed string | alertadmin:$apr1$LN5vrqsG$SUjL9IbnRsUOTjUlrP2LL/ |
| kube-prometheus-stack.alertmanager.ingress.enabled | Enable ingress | True |
| kube-prometheus-stack.alertmanager.ingress.ingressClassName | Ingress class name (may be required for Kubernetes versions >= 1.18) | nginx |
| kube-prometheus-stack.alertmanager.ingress.annotations | Ingress annotations | [cert-manager.io/cluster-issuer: letsencrypt-prod, kubernetes.io/tls-acme: "true", nginx.ingress.kubernetes.io/auth-type: basic, nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth, nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"] |
| kube-prometheus-stack.alertmanager.ingress.hosts | Ingress accepted hostnames | ['alertmanager.{{ .Values.global.domain }}'] |
| kube-prometheus-stack.alertmanager.ingress.tls | Ingress TLS configuration | [{'secretName': 'alertmanager-general-tls', 'hosts': ['alertmanager.{{ .Values.global.domain }}']}] |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.replicas | Number of replications | 2 |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.externalUrl | External Alertmanager URL | https://alertmanager.{{ .Values.global.domain }} |
| kube-prometheus-stack.alertmanager.alertmanagerSpec.containers | Allows injecting additional containers. This is meant to allow adding an authentication proxy to an Alertmanager pod. (Work in progress!) | [] |
| kube-prometheus-stack.kubeControllerManager.serviceMonitor.https | Enalbe HTTPS for the service monitor | True |
| kube-prometheus-stack.kubeControllerManager.serviceMonitor.insecureSkipVerify | Skip TLS certificate validation when scraping | True |
| kube-prometheus-stack.kubeScheduler.serviceMonitor.https | Enalbe HTTPS for the service monitor | True |
| kube-prometheus-stack.kubeScheduler.serviceMonitor.insecureSkipVerify |Skip TLS certificate validation when scraping | True |
| kube-prometheus-stack.kubeProxy.enabled | Enable kube proxy | False |
| kube-prometheus-stack.kube-state-metrics.fullnameOverride | Override the deployment name | prometheus-kube-state-metrics |
| kube-prometheus-stack.prometheus-node-exporter.fullnameOverride |Override the deployment name | prometheus-node-exporter |
| kube-prometheus-stack.prometheusOperator.tls.enabled | Enable TLS | False |
| kube-prometheus-stack.prometheusOperator.tlsProxy.enabled | Enable tls proxy | False |
| kube-prometheus-stack.prometheusOperator.admissionWebhooks.enabled | Enable admission webhooks. [Do not change!](https://github.com/helm/charts/issues/21080#issuecomment-596958610) | False |
| kube-prometheus-stack.prometheus.service.targetPort | Prometheus service port | 9090 |
| kube-prometheus-stack.prometheus.podDisruptionBudget.enabled | Enable PodDistributionBudget. For details see [here](https://kubernetes.io/docs/tasks/run-application/configure-pdb/). | True |
| kube-prometheus-stack.prometheus.extraSecret.name | Name for the basic auth secret (If not set, it will be auto generated) | prometheus-basic-auth |
| kube-prometheus-stack.prometheus.extraSecret.data.auth | Basic auth username and password as bcrypt hashed string | promadmin:$apr1$e8kSmViA$It4clhTmgAybWtl47J9Ud. |
| kube-prometheus-stack.prometheus.ingress.enabled | Enable ingress | True |
| kube-prometheus-stack.prometheus.ingress.ingressClassName | Ingress class name (may be required for Kubernetes versions >= 1.18) | nginx |
| kube-prometheus-stack.prometheus.ingress.annotations | Ingress annotations | [cert-manager.io/cluster-issuer: letsencrypt-prod, kubernetes.io/tls-acme: "true", nginx.ingress.kubernetes.io/auth-type: basic, nginx.ingress.kubernetes.io/auth-secret: prometheus-basic-auth, nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"] |
| kube-prometheus-stack.prometheus.ingress.hosts | Ingress accepted hostnames | ['prometheus.{{ .Values.global.domain }}'] |
| kube-prometheus-stack.prometheus.ingress.tls | Ingress TLS configuration | [{'secretName': 'prometheus-general-tls', 'hosts': ['prometheus.{{ .Values.global.domain }}']}] |
| kube-prometheus-stack.prometheus.prometheusSpec.enableRemoteWriteReceiver | Enable RemoteWriteReceiver | True |
| kube-prometheus-stack.prometheus.prometheusSpec.externalUrl | External Prometheus URL | https://prometheus.{{ .Values.global.domain }} |
| kube-prometheus-stack.prometheus.prometheusSpec.retention | Retention time | 7d |
| kube-prometheus-stack.prometheus.prometheusSpec.walCompression | Enable compression of the write-ahead log using Snappy | False |
| kube-prometheus-stack.prometheus.prometheusSpec.replicas | Number of replications | 2 |
| kube-prometheus-stack.prometheus.prometheusSpec.resources.requests.memory | Memory resource request | 400Mi |
| metrics-server.enabled | Enable Metrics-Server component | True |
| metrics-server.fullnameOverride | Override the deployment name | metrics-server |
| metrics-server.replicas | Number of replications | 2 |
| metrics-server.serviceMonitor.enabled | Enable prometheus service monitor | False |
| grafana.enabled | Enable Grafana component | True |
| grafana.fullnameOverride | Override the deployment name | grafana |
| grafana.adminUser | Default admin username | grafanaAdmin |
| grafana.adminPassword | Default admin password | superSecretPassword |
| grafana.serviceMonitor.enabled | Enable prometheus service monitor | True |
| grafana.ingress.enabled | Enable ingress | True |
| grafana.ingress.ingressClassName | Ingress class name (may be required for Kubernetes versions >= 1.18) | nginx |
| grafana.ingress.annotations | Ingress annotations | [nginx.ingress.kubernetes.io/proxy-body-size: 1024m, cert-manager.io/cluster-issuer: letsencrypt-prod, kubernetes.io/tls-acme: "true"] |
| grafana.ingress.hosts | Ingress accepted hostnames | ['grafana.your.doma.in'] |
| grafana.ingress.tls | Ingress TLS configuration | [{'hosts': ['grafana.your.doma.in'], 'secretName': 'grafana-ingress-tls'}] |
| grafana.persistence.enabled | Enable storage | False |
| grafana.persistence.storageClassName | Storage class name | default |
| grafana.persistence.size | Storage size | 15Gi |
| grafana.datasources | Default Grafana data sources | See values.yaml |
| grafana.dashboardProviders | Default dashboard folders | See values.yaml |
| grafana.dashboards | Dashboards integrated by default | See values.yaml |
| loki.enabled | Enalbe Loki component | True |
| loki.fullnameOverride | Override the deployment name | loki |
| loki.loki.storage.bucketNames.chunks | 'chunks' S3 bucket name | loki-clops-chunks |
| loki.loki.storage.bucketNames.ruler | 'ruler' S3 bucket name | loki-clops-ruler |
| loki.loki.storage.bucketNames.admin | 'admin' S3 bucket name | loki-clops-admin |
| loki.loki.storage.type | Storage type | s3 |
| loki.loki.storage.s3.endpoint | S3 storage URL | https://s3.your.doma.in |
| loki.loki.storage.s3.region | S3 storage region | region-1 |
| loki.loki.storage.s3.accessKeyId | S3 access key id | clops-test-key |
| loki.loki.storage.s3.secretAccessKey | S3 secret access key | SUPERSECRETKEY |
| loki.loki.storage.gcs | GCS storage configuration | See values.yaml |
| loki.loki.storage.azure | Azure storage configuration | See values.yaml |
| loki.loki.storage.filesystem.chunks_directory | Local 'chunks' directory | /var/loki/chunks |
| loki.loki.storage.filesystem.rules_directory | Local 'rules' directory | /var/loki/rules |
| loki.gateway.enabled | Enable Loki gateway | True |
| loki.gateway.replicas | Number of replications | 1 |
| loki.gateway.ingress.enabled | Enable ingress | True |
| loki.gateway.ingress.ingressClassName | Ingress class name (may be required for Kubernetes versions >= 1.18) | nginx |
| loki.gateway.ingress.annotations | Ingress annotations | [cert-manager.io/cluster-issuer: letsencrypt-prod] |
| loki.gateway.ingress.hosts | Ingress accepted hostnames | [{'host': 'loki.your.doma.in', 'paths': [{'path': '/', 'pathType': 'Prefix'}]}] |
| loki.gateway.ingress.tls | Ingress TLS configuration | [{'secretName': 'loki-gateway-tls', 'hosts': ['loki.your.doma.in']}] |
| loki.gateway.basicAuth.enabled || True |
| loki.gateway.basicAuth.username || testloki |
| loki.gateway.basicAuth.password || testlokipassword |
| loki.grafana-agent-operator.fullnameOverride | Override the deployment name | loki-grafana-agent-operator |
| promtail.enabled | Enable Promtail component | True |
| promtail.fullnameOverride | Override the deployment name | promtail |
| promtail.resources.limits.cpu | CPU limit | 200m |
| promtail.resources.limits.memory | Memory limit | 375Mi |
| promtail.resources.requests.cpu | CPU request | 100m |
| promtail.resources.requests.memory | Memory request | 135Mi |
| promtail.serviceMonitor.enabled | Enable prometheus service monitor | True |
| promtail.config.logLevel | Promtail server log level | warn |
| promtail.config.clients | Promtail server clients | [{'url': 'http://loki-gateway.{{ .Release.Namespace }}.svc/loki/api/v1/push'}] |
| prometheus-blackbox-exporter.enabled | Enable Prometheues-Blackbox-Exporter component | True |
| prometheus-blackbox-exporter.fullnameOverride | Override the deployment name | prometheus-blackbox-exporter |
| prometheus-blackbox-exporter.configExistingSecretName | Name of an existing secret | "" |
| prometheus-blackbox-exporter.secretConfig | Store the configuration as a Secret instead of a ConfigMap | False |
| prometheus-blackbox-exporter.config | Prometheus-Blackbox-Exporter configuration | See values.yaml |
| prometheus-blackbox-exporter.serviceMonitor.enabled | Enable prometheus service monitor | True |
| prometheus-blackbox-exporter.serviceMonitor.selfMonitor.enabled | Enable self monitoring | [] |
| prometheus-blackbox-exporter.serviceMonitor.defaults | Service monitor defaults | See values.yaml |
| prometheus-blackbox-exporter.serviceMonitor.scheme | Service monitor protocol (http, https) | http |
| prometheus-blackbox-exporter.serviceMonitor.tlsConfig | TLS configuration | {} |
| prometheus-blackbox-exporter.serviceMonitor.bearerTokenFile | Path to bearer token file | None |
| prometheus-blackbox-exporter.serviceMonitor.targets | The targets that are scraped | See values.yaml |
| prometheus-blackbox-exporter.prometheusRule.enabled | Enable additional Prometheus rules | True |
| prometheus-blackbox-exporter.prometheusRule.rules | Additional rules | See values.yaml |
| prometheus-blackbox-exporter.dnsPolicy | DNS policy setting for deployments and daemonsets | None |
| prometheus-blackbox-exporter.dnsConfig | DNS configuration for deployments and daemonsets | See values.yaml |
