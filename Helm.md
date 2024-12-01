# Helm commands
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm search repo argoc
helm show values argo/argocd-image-updater --version 0.9.1 > image-updater.yaml
helm install updater -n argocd argo/argocd-image-updater --version 0.9.1 -f terraform/values/image-updater.yaml


 kubectl get pods -n argocd

 since no ingress is avaiable , port forward argocd-server

 kubectl port-forward svc/argocd-server -n argocd 8080:80

 Intial password

 kubectl get secrets  argocd-initial-admin-secret -o yaml -n argocd

 echo "MU5IeC1QZ0xDZEZGQ2d0Uw==" | base64 -d
