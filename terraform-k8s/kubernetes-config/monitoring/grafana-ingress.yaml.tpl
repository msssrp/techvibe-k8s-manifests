apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: monitoring
  annotations:
    reflector.v1.k8s.emberstack.com/reflects: "cert-manager/tls-secret"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - grafana.${dns_name}
      secretName: tls-secret
  rules:
    - host: grafana.${dns_name}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  name: service
