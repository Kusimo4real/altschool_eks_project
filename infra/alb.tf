# # IAM Policy for ALB Controller
# resource "aws_iam_policy" "alb_controller" {
#   name        = "AWSLoadBalancerControllerIAMPolicy"
#   description = "IAM policy for AWS Load Balancer Controller"
#   policy      = file("iam-policy.json")
# }

# data "aws_iam_openid_connect_provider" "eks" {
#   url = "https://oidc.eks.eu-west-2.amazonaws.com/id/E74E4B1A5FD9A4982C1E2B929D44F1F5"
# }

# # IAM Role for ALB Controller
# resource "aws_iam_role" "alb_controller_role" {
#   name = "alb-controller-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Principal = {
#         Federated = data.aws_iam_openid_connect_provider.eks.arn
#       }
#       Action = "sts:AssumeRoleWithWebIdentity"
#       Condition = {
#         StringEquals = {
#           "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })
# }

# # Attach Policy to Role
# resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
#   role       = aws_iam_role.alb_controller_role.name
#   policy_arn = aws_iam_policy.alb_controller.arn
# }

# # Kubernetes Service Account for ALB Controller
# resource "kubernetes_service_account" "alb_controller_sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
#     }
#   }
# }

# # Helm Release for ALB Controller
# resource "helm_release" "aws_lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   values = [
#     yamlencode({
#       clusterName    = aws_eks_cluster.eks.name
#       serviceAccount = { create = false, name = kubernetes_service_account.alb_controller_sa.metadata[0].name }
#       region         = local.region
#       vpcId          = aws_vpc.altsch_vpc.id
#     })
#   ]

#   depends_on = [kubernetes_service_account.alb_controller_sa]
# }



# # Kubernetes Service Account in retail-dev
# resource "kubernetes_service_account" "alb_controller_sa_retail_dev" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "retail-dev"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
#     }
#   }
# }

