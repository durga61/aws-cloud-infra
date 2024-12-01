# Check ArgoCD components

kubectl get pods -n argocd

# create a base app

 create a base app with k8s resources deployment, namespace along with kustomization object
 kustomization object has info about which resources to be updated during deployment

# create environments

 create a environment needed and overwrite k8s object using kustomiaztion.yml in which namespace and docker tag are

 and overwrrite namespace, replicas , target deployment object to update replicas count
 mention docker image name and intial tag

 # App of apps pattren

 deploy-argocd/application.yml --> argocd application configuration setup along with repo to use for apps deployment, along with sync polices

  path mentioned is argocd-examples/environments/staging/my-app which is kustomization of apps

# image updater via argocd api

kubectl apply -f deploy-argocd-image-updater-argcd-api/application.yaml

 get application

 kubectl get application -n argocd

 examin the applicaiton

  kubectl get application -n argocd my-app -o yaml | less

# image updater via git write back

    kubectl apply -f deploy-argocd-image-updater-git/application.yaml
