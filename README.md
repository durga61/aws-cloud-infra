"# aws-cloud-infra" 
# EKS clustrer setup
terraform init
terraform apply

 update the Kubernetes context with the following command:

aws eks update-kubeconfig --name eks-training --region ap-south-1

# AWS LB controller 
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