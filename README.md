"# aws-cloud-infra"
# EKS clustrer setup
terraform init
terraform apply --auto-approve


terraform destroy --auto-approve


 update the Kubernetes context with the following command:

aws eks update-kubeconfig --name cluster-dev --region ap-south-1

Verify that the autoscaler is running.

kubectl get pods -n kube-system


you can watch autoscaler logs just to make sure you don't have any errors.

 kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller  --all-containers=true --prefix


How to route traffic to a domain name before creating the dns record

curl -i --header "Host: myapp.example.com" http://k8s-6example-myapp-2bf9f030a0-1676692800.ap-south-1.elb.amazonaws.com/about
Now let's apply nginx Kubernetes deployment.

kubectl apply -f k8s/nginx.yaml

In a few seconds, you should get a few more node

kubectl get nodes -w



# Deploy AWS Load Balancer Controller with terraform
AWS Load Balancer Controller is a controller to help manage Elastic Load Balancers for a Kubernetes cluster.

It satisfies Kubernetes Ingress resources by provisioning Application Load Balancers.
It satisfies Kubernetes Service resources by provisioning Network Load Balancers.

similar to cluster-autoscaler, we need to create an IAM role for the load balancer controller with permissions to create and manage AWS load balancers. We're going to deploy it to the same kube-system namespace in Kubernetes.

Then the helm release. By default, it creates two replicas, but for the demo, we can use a single one. Then you need to specify the EKS cluster name, Kubernetes service account name and provide annotation to allow this service account to assume the AWS IAM role.

The load balancer controller uses tags to discover subnets in which it can create load balancers. We also need to update terraform vpc module to include them. It uses an elb tag to deploy public load balancers to expose services to the internet and internal-elb for the private load balancers to expose services only within your VPC.

Check if the controller is running.

kubectl get pods -n kube-system

You can watch logs with the following command.

kubectl logs -f -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller


# Deploy a sample application to use ELB

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml

kubectl get ingress/ingress-2048 -n game-2048

delete - kubectl delete -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/examples/2048/2048_full.yaml

if there is permission issue loabbalender taging, remove condtion

Testing the cluster by deploying a simple Hello World app

kubectl apply -f deployment.yaml
To see if your application runs correctly, you can connect to it with kubectl port-forward.

kubectl port-forward <hello-kubernetes-wfjdz> 8080:8080

If you visit http://localhost:8080 on your computer, you should be greeted by the application

If you wish to route live traffic to the Pod, you should have a more permanent solution.

In Kubernetes, you can use a Service of type: LoadBalancer to expose your Pods.

kubectl apply -f .\hello-loadbalencer.yml

The load balancer that you created earlier serves one service at the time.

Also, it has no option to provide intelligent routing based on paths.

So if you have multiple services that need to be exposed, you will need to create the same amount of load balancers.

Imagine having ten applications that have to be exposed.

If you use a Service to type: LoadBalancer for each of them, you might end up with ten Classic Load Balancers.
