apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jenkins-ingress
  namespace: jenkins
  annotations:
    reflector.v1.k8s.emberstack.com/reflects: "cert-manager/tls-secret"
spec:
  ingressClassName: nginx
  tls:
    - hosts:
        - jenkins.${dns_name}
      secretName: tls-secret
  rules:
    - host: jenkins.${dns_name}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: jenkins-service
                port:
                  name: jenkins-tcp
