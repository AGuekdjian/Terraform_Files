module "instances" {
  source       = "./ec2"
  ec2_tag_name = "scheduler_server"
}
