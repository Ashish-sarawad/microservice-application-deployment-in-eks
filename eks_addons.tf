resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.demo.id
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.25.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.addon_ebs_csi_driver_role.arn
  resolve_conflicts_on_create  = "OVERWRITE"

  # coredns needs nodes to run on, so don't create it until
  # the node-pools have been created
  depends_on = [
    aws_eks_node_group.demo,
    aws_iam_openid_connect_provider.cluster_openid
  ]
  tags = {
    Name = "ebs-csi-driver"
  }
}

resource "aws_iam_role" "addon_ebs_csi_driver_role" {
  name  = "${aws_eks_cluster.demo.id}-addon-ebs-csi-driver-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRoleWithWebIdentity"
        Effect    = "Allow"
        Principal = { Federated = aws_iam_openid_connect_provider.cluster_openid.arn }
        Condition = {
          "StringEquals" = {
            "${replace(aws_iam_openid_connect_provider.cluster_openid.url, "https://", "")}:aud" = "sts.amazonaws.com",
            "${replace(aws_iam_openid_connect_provider.cluster_openid.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      },
    ]
  })

  tags = {
     Name = "ebs-csi-driver-role"
  }

}

data "aws_partition" "current" {}

resource "aws_iam_role_policy_attachment" "gitlab_addon_ebs_csi_driver_policy" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.addon_ebs_csi_driver_role.name
}