## Install nginx ingress controller using helm

`helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx \ helm repo update ingress-nginx \ helm install ingress-nginx/ingress-nginx --version "4.1.3" \ --namespace ingress-nginx --create-namespace \ -f nginx-values.yaml`

## Install cert manager jetstack

`helm repo add jetstack https://charts.jetstack.io \ helm repo update jetstack \ helm install cert-manager jetstack/cert-manager --version "1.8.0" \ --namespace cert-manager --create-namespace \ -f cert-manager-values.yaml`

## Install async tls secret lib for cert wildcard

`helm repo add emberstack https://emberstack.github.io/helm-charts \ helm upgrade --install reflector emberstack/reflector --namespace cert-manager --create-namespace`

## Install prometheus for get pods metrics

`helm repo add prometheus-community https://prometheus-community.github.io/helm-charts \ helm repo update \ helm install prometheus prometheus-community/prometheus --namespace monitoring --create-namespace`

## Install grafana dashboard for monitoring

`helm repo add grafana https://grafana.github.io/helm-charts \ helm repo update \ helm install grafana grafana/grafana --namespace monitoring --create-namespace`
