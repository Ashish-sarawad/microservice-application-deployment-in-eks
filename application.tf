resource "helm_release" "ecom-application" {
  name       = "ecom-app"
  repository = "https://ashish-sarawad.github.io/helm-charts/"
  chart      = "robot-shop"
  wait       =  true
  depends_on = [aws_eks_node_group.demo,aws_eks_addon.ebs_csi_driver]
}
