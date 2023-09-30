module "instances" {
  source       = "./ec2"
  ec2_tag_name = "red_social_server"
}
