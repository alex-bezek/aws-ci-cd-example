
# Creates a route53 hosted zone matching the domain name
# Assumes single level domain, no subdomain
resource "aws_route53_zone" "primary" {
  name = local.domain_name
}

# Data source to get the zone id
# https://github.com/hashicorp/terraform/issues/7071
data "aws_elastic_beanstalk_hosted_zone" "current" {}

# Creates an A record for the domain name
# Maps it to the an alias record to the elastic beanstalk cname in the current hosted zone
resource "aws_route53_record" "primary" {
  # This was throwing this error when created. This might resolve it
  # expected length of alias.0.name to be in the range (1 - 1024), got
  depends_on = [aws_elastic_beanstalk_application.app]
  zone_id = aws_route53_zone.primary.zone_id
  name    = local.domain_name
  type    = "A"

  alias {
    # name                   = lower(aws_elastic_beanstalk_environment.prod.cname)
    name                   = aws_elastic_beanstalk_environment.prod.cname
    # name                   = lower(aws_elastic_beanstalk_environment.prod.*.cname[0])
    # name                   = "test"
    zone_id                = data.aws_elastic_beanstalk_hosted_zone.current.id
    evaluate_target_health = false
  }
}

# Create an ACM certificate for the required domain name
resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain_name
  validation_method = "DNS"
}

# Cretes a validation record in route53 matching the ACM validation record
# https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-dns.html
resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.primary.id
  records = [aws_acm_certificate.cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

# Create an ACM cert validation instance for the cert using the route53 validation record
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
