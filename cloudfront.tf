resource "aws_s3_bucket" "site_bucket" {
  bucket = "${var.site_bucket_name}"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "logging" {
  bucket = "${var.project_name}-cloundfront-logs"
  acl    = "private"

  tags {
    Name = "${var.project_name}-cloudfront-logs"
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name = "${var.route53_domain_name}"
  validation_method = "DNS"
  tags {
    Environment = "test"
  }
}


resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.fqdn}"]
}

resource "aws_route53_record" "cert_validation" {
   name = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
   zone_id = "${var.route53_domain_zoneid}"
   type = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_type}"
   records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
   ttl = 60
}


resource "aws_route53_record" "www" {
  count = "${length(var.route53_domains)+1}"
   name = "${var.route53_domains[count.index]}"
   zone_id = "${var.route53_domain_zoneid}"
   type = "A"
   alias {
     name = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
     zone_id = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
     evaluate_target_health = true
   }
 }

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.site_bucket.bucket_domain_name}"
    origin_id   = "myS3Origin"
  }

  custom_error_response {
    error_code = "404"
    error_caching_min_ttl = "30"
    response_page_path = "/index.html"
    response_code = "200"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project_name} distribution"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.logging.bucket_domain_name}"
    prefix          = "${project_name}"
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  tags {
    Environment = "production"
  }

  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.cert.certificate_arn}"
    ssl_support_method = "sni-only"
  }
}

