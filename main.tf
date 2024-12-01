provider "aws" {
    region = "us-east-1"
  
}


resource "aws_key_pair" "test1" {
    key_name = "test1"
    public_key = var.key_pair

  
}

resource "aws_vpc" "koti" {
    cidr_block = "10.0.0.0/16"
  
}

resource "aws_subnet" "koti" {
    vpc_id = aws_vpc.koti.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
  
}

resource "aws_security_group" "kotisg" {
    name = "kotisg"
    vpc_id = aws_vpc.koti.id

    ingress {
        description = "allow ssh"
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [ "0.0.0.0/0" ]
        
        }

        ingress {
            description = "allow 8080 traffic"
            from_port = 8080
            to_port = 8080
            protocol = "TCP"
            cidr_blocks = [ "0.0.0.0/0" ]
        }

        egress {

            description = "allow outbondtraffic"
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = [ "0.0.0.0/0" ]
        }
    }

    resource "aws_internet_gateway" "kotigw" {
      vpc_id = aws_vpc.koti.id
    }

    resource "aws_route_table" "kotirt" {
        vpc_id = aws_vpc.koti.id

        route {
            gateway_id = aws_internet_gateway.kotigw.id
            cidr_block = "0.0.0.0/0"
        }
      
    }

    resource "aws_route_table_association" "name" {
        route_table_id = aws_route_table.kotirt.id
        subnet_id = aws_subnet.koti.id
      
    }



resource "aws_instance" "dev" {
    instance_type = var.instance_type
    ami = var.AMI
    key_name = aws_key_pair.test1.id
    vpc_security_group_ids = [ aws_security_group.kotisg.id ]
    user_data = base64encode(file("script.sh"))
    subnet_id = aws_subnet.koti.id



 provisioner "remote-exec" {
    inline = [ 
        "sudo apt install default-jdk -y",
        "curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee  /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
  "echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]   https://pkg.jenkins.io/debian binary/ | sudo tee   /etc/apt/sources.list.d/jenkins.list > /dev/null",
        "sudo apt update",
         "sudo apt-get update",
        "sudo apt-get install jenkins -y"
      
         
     ]

        
         connection {
       type = "ssh"
       user = "ubuntu"
       private_key = file("~/.ssh/id_rsa")
       host = self.public_ip
     }

  
 
}

}

resource "aws_instance" "QA" {
    instance_type = var.instance_type
    ami = var.AMI
    key_name = aws_key_pair.test1.id
    vpc_security_group_ids = [ aws_security_group.kotisg.id ]
    subnet_id = aws_subnet.koti.id
    user_data = base64encode(file("qa.sh"))
  
}
