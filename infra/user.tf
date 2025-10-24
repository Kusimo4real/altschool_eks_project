resource "aws_iam_user" "developer" {
  name = "innocent"
}

resource "aws_iam_policy" "developer-eks" {
  name = "AmazonEKSDeveloperPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "eks:ListClusters",
        "eks:DescribeCluster"
      ],
      Resource = "*"
    }]
  })
}

resource "aws_iam_user_policy_attachment" "developer-eks" {
  user       = aws_iam_user.developer.name
  policy_arn = aws_iam_policy.developer-eks.arn
}

resource "aws_eks_access_entry" "developer" {
  cluster_name      = aws_eks_cluster.eks.name
  principal_arn     = aws_iam_user.developer.arn
  kubernetes_groups = ["my-viewer"]
}