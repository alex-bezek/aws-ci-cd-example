resource "aws_route53_zone" "primary" {
  name = "alexbezek.me"
}

data "aws_elastic_beanstalk_hosted_zone" "current" {}

resource "aws_route53_record" "primary" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "alexbezek.me"
  type    = "A"

  alias {
    name                   = lower(aws_elastic_beanstalk_environment.prod.cname)
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id # FROM https://github.com/hashicorp/terraform/issues/7071
    evaluate_target_health = false
  }
}

# resource "aws_route53_record" "www" {
#   zone_id = "${aws_route53_zone.primary.zone_id}"
#   name    = "www.alexbezek.me"
#   type    = "A"

#   alias {
#     name                   = "${lower(aws_elastic_beanstalk_environment.prod.cname)}"
#     zone_id                = "${data.aws_elastic_beanstalk_hosted_zone.current.id}"
#   }
# }

resource "aws_acm_certificate" "cert" {
  domain_name       = "alexbezek.me"
  validation_method = "DNS"
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.primary.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
