# github-oidc.tf

# GitHub OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}
# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "${var.app_name}-github-actions-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:Abraham-Temitope/nairatransfer-pro:*"
        }
      }
      }
    ]
  })
}
# === Policies ===
resource "aws_iam_role_policy_attachment" "github_ecs" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}
resource "aws_iam_role_policy_attachment" "github_ecr" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# Custom policy for additional permissions (including PassRole)
resource "aws_iam_policy" "github_additional" {
  name        = "${var.app_name}-github-additional"
  description = "Additional permissions for GitHub Actions"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["iam:PassRole"]
      Resource = "*"
      Condition = {
        StringEquals = {
          "iam:PassedToService" : "ecs-tasks.amazonaws.com"
        }
      }
      }
    ] }
  )
}
resource "aws_iam_role_policy_attachment" "github_additional" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_additional.arn
}











