# Story: Implement AWS Load Balancer Controller for EKS Application Exposure

Description:

 As a DevOps engineer, I need to implement the AWS Load Balancer Controller in our EKS clusters to improve how we expose applications. The legacy cloud controller manager, which historically created load balancers for Kubernetes applications, presents several limitations that we need to address. It defaults to creating classic load balancers and its development is tied to the Kubernetes release cycle, which slows down the release of new features. Furthermore, it routes traffic using NodePorts behind the scenes, adding an additional network hop and imposing a hard limit of 500 nodes for target groups, which is a concern for large Kubernetes clusters.
The AWS Load Balancer Controller, being a separate project with an independent release cycle, allows for faster feature development and release. This controller can create both Layer 7 Application Load Balancers (ALB) and Layer 4 Network Load Balancers (NLB). A significant advantage is its ability to directly add pod IP addresses to the load balancer target group (IP mode) when using EKS with native VPC networking. This eliminates the NodePort hop and the 500-node target group limit, making traffic routing more efficient.
For securing applications, the AWS Load Balancer Controller supports TLS termination on the Application Load Balancer itself. This means we can obtain TLS certificates from AWS Certificate Manager and attach them using annotations, eliminating the need to store certificates and private keys inside Kubernetes. This controller also supports creating Ingress resources, a feature that was not part of the original cloud controller. We can configure these load balancers to be either public (internet-facing) or internal (within the VPC only).
Acceptance Criteria:

- The AWS Load Balancer Controller is successfully deployed to the kube-system namespace within our EKS cluster using Helm charts.
- The controller has been granted the necessary IAM permissions to create and manage AWS load balancers, with access configured using pod identities (IAM role linked to the Kubernetes service account).
- A sample application exposed via a Kubernetes Service of type LoadBalancer successfully provisions an AWS Load Balancer using the AWS Load Balancer Controller by specifying the loadBalancerType annotation.
- The provisioned load balancer in the above scenario operates in IP mode, targeting the pod's IP addresses directly rather than NodePorts.
- The provisionb a load balencer using instance mode and observe nodes are getting added to target group which create additional network hop
- A sample application exposed via a Kubernetes Ingress resource successfully provisions an AWS Application Load Balancer using the AWS Load Balancer Controller by specifying the ingressClassName property.
- For an Ingress example, TLS termination is successfully handled by the Application Load Balancer, leveraging a certificate from AWS Certificate Manager, demonstrating that the certificate and private key are not stored within the Kubernetes cluster.
- The ability to deploy both internet-facing and internal (VPC-only) load balancers via the controller using appropriate annotations is confirmed.

Labels: EKS, Kubernetes, AWS, LoadBalancer, Ingress, DevOps, Infrastructure Components: Networking, Application-Delivery
