"# aws-cloud-infra" 
# EKS clustrer setup
terraform init
terraform apply


terraform destroy --auto-approve


 update the Kubernetes context with the following command:

aws eks update-kubeconfig --name eks-training --region ap-south-1

Verify that the autoscaler is running.

kubectl get pods -n kube-system


you can watch autoscaler logs just to make sure you don't have any errors.

kubectl logs -f -n kube-system -l app=cluster-autoscaler

Now let's apply nginx Kubernetes deployment.

kubectl apply -f k8s/nginx.yaml

In a few seconds, you should get a few more node

kubectl get nodes -w

# AWS LB controller  manually 
Create an IAM role. Create a Kubernetes service account named aws-load-balancer-controller in the kube-system namespace for the AWS Load Balancer Controller and annotate the Kubernetes service account with the name of the IAM role.

create iam policy

curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

a. Retrieve your cluster's OIDC provider ID and store it in a variable.
oidc_id=$(aws eks describe-cluster --name eks-training --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

b. Determine whether an IAM OIDC provider with your cluster's ID is already in your account.
aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

c.
 
  cat >load-balancer-role-trust-policy.json <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::288822231308:oidc-provider/oidc.eks.region-code.amazonaws.com/id/BB0B6FB16B7EA509AA8D9F6C21A2B49E"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.eks.region-code.amazonaws.com/id/BB0B6FB16B7EA509AA8D9F6C21A2B49E:aud": "sts.amazonaws.com",
                    "oidc.eks.region-code.amazonaws.com/id/BB0B6FB16B7EA509AA8D9F6C21A2B49E:sub": "system:serviceaccount:kube-system:aws-load-balancer-controller"
                }
            }
        }
    ]
}
EOF

d. Create the IAM role.

aws iam create-role \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --assume-role-policy-document file://"load-balancer-role-trust-policy.json"
e
e. Attach the required Amazon EKS managed IAM policy to the IAM role. Replace 111122223333 with your account ID.

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::288822231308:policy/AWSLoadBalancerControllerIAMPolicy \
  --role-name AmazonEKSLoadBalancerControllerRole

f. create sa
cat >aws-load-balancer-controller-service-account.yaml <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::288822231308:role/AmazonEKSLoadBalancerControllerRole
EOF
g. create the Kubernetes service account on your cluster. 

# Install the AWS Load Balancer Controller using Helm V3 

helm repo add eks https://aws.github.io/eks-charts

helm repo update eks

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=eks-training \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 


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