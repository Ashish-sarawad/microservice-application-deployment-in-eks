## Ingress for http headers
resource "kubernetes_ingress_v1" "ingress" {
  metadata {
    name = "web-ingress"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" =  "internet-facing"
      "alb.ingress.kubernetes.io/target-type" =  "ip"
      # "alb.ingress.kubernetes.io/conditions.web" = jsonencode([
      #   {
      #     "field": "http-header",
      #     "httpHeaderConfig": {
      #       "httpHeaderName": "Strict-Transport-Security",
      #       "values": ["max-age=31536000; includeSubDomains"]
      #     }
      #   },
      #   {
      #     "field": "http-header",
      #     "httpHeaderConfig": {
      #       "httpHeaderName": "Content-Security-Policy-Report-Only",
      #       "values": ["default-src 'self'"]
      #     }
      #   }
      # ])
    }
  }
  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          backend {
            service {
              name = "web"
              port {
                number = 8080
                
              }
            }
          }
          path = "/*"

        }
      }
    }
  }
}

output "load_balancer_hostname" {
  value = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.hostname
}