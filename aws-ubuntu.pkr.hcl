packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "bagisto" {
  ami_name      = "bagisto-test_{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "RHEL_HA-8.4.0_HVM-20210504-x86_64-2-Hourly2-GP2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  ssh_username = "ec2-user"
}

build {
  name = "learn-packer"
  sources = [
    "source.amazon-ebs.bagisto"
  ]

  provisioner "file" {
    source      = "config_files"
    destination = "/tmp"
  }

  provisioner "shell" {
    script = "setup.sh"
  }

  provisioner "shell" {
    inline = ["sudo echo DB_PASSWORD='${aws_secretsmanager("prod/bagisto", null)}' | sudo tee -a /var/www/html/bagisto/.env"]
  }
}
