apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    reflector.v1.k8s.emberstack.com/reflects: "cert-manager/tls-secret"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - argocd.${dns_name}
      secretName: tls-secret
  rules:
    - host: argocd.${dns_name}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: argocd-server
                port:
                  name: https
