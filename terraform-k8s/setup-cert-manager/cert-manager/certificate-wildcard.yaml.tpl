apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: techvibe-app
  namespace: cert-manager
spec:
  secretName: tls-secret
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-nginx-ingress
    group: cert-manager.io
  commonName: ${dns_name}
  dnsNames:
    - "*.${dns_name}"
    - "${dns_name}"
  secretTemplate:
    annotations:
      reflector.v1.k8s.emberstack.com/reflection-allowed: "true"
      reflector.v1.k8s.emberstack.com/reflection-allowed-namespaces: "argocd,quote,monitoring,jenkins,techvibe" # Control destination namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-enabled: "true" # Auto create reflection for matching namespaces
      reflector.v1.k8s.emberstack.com/reflection-auto-namespaces: "argocd,quote,monitoring,jenkins,techvibe" # Control auto-reflection namespaces
