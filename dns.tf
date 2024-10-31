data "aws_route53_zone" "domain" {
  name = var.domain_name
}

resource "aws_route53_record" "webapp_A_record" {
  zone_id = data.aws_route53_zone.domain.zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = 60
  records = [aws_instance.web_app.public_ip]
}
