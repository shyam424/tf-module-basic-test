resource "aws_instance" "instances" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = var.security_groups

  tags = {
    Name = var.name
  }
}


resource "aws_route53_record" "record" {
  zone_id = var.zone_id
  name    = "${var.name}.devopspractice23.online"
  type    = "A"
  ttl     = 30
  records =[ aws_instance.instances.private_ip ]
}


//once the machines are created , we will call the ansible scripts which will help to install the respected packages in their machines

resource "null_resource" "ansible" {

  depends_on = [ aws_route53_record.record]  #this is a dependency condition ,route 53 should be completed to proceed with the next steps

  provisioner "local-exec" {
    command = <<EOF
cd /home/centos/roboshop-ansible
git pull
sleep 30
ansible-playbook -i ${var.name}.devopspractice23.online, main.yml -e ansible_user=centos -e ansible_password=DevOps321 -e component=${var.name}
EOF

  }
}
