#provider
provider "aws" {
  region = "us-east-1"

}

#Resource of multiple applications

resource "aws_instance" "multiple_applications" {
    ami="ami-01bc990364452ab3e"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.allow_ssh.id]
    tags = {
        Name="ubuntu_instance2"
    }
    key_name = "ubuntu_keypair2"

    connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file("ubuntu_keypair2")    
 }

   provisioner "remote-exec" {
  inline = [
#install java and Jenkins
  "sudo apt update",
  "sudo apt install openjdk-11-jdk -y",
  "java -version",
  "curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null",
  "sudo apt-get update",
  "sudo apt-get install jenkins -y",
  "sudo systemct1 status jenkins",
  "sudo systemct1 enable jenkins",
  "sudo systemct1 start jenkins"
   ]
    }  
  }


#Create the keypair the  of applications
resource "aws_key_pair" "tf-key-pair" {
key_name = "ubuntu_keypair2"
public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}

resource "local_file" "tf-key" {
content  = tls_private_key.rsa.private_key_pem
filename = "ubuntu_keypair2"
}

#Security group of multiple applications

resource "aws_security_group" "allow_ssh" {
  name        = "Multiple_App"
  description = "Allow SSH inbound traffic"
  #vpc_id      = aws_vpc.vpc_demo.id

  ingress {

    # SSH Port 22 allowed from any IP
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    # SSH Port 80 allowed from any IP
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    # SSH Port 80 allowed from any IP
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
