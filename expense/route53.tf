resource "aws_route53_record" "expanse" {
  count = length(var.instance_names)
  zone_id = var.zone_id
  name    = var.instance_names[count.index] == "frontend" ? var.domain_name : "${var.instance_names[count.index]}.${var.domain_name}"
  #name = local.record_name

  type    = "A"
  ttl     = 1
  records = var.instance_names[count.index] == "frontend" ?[aws_instance.expense[count.index].public_ip] : [aws_instance.expense[count.index].private_ip]
  #records = local.record_value

  allow_overwrite = true
}