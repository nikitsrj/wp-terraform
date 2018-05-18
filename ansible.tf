resource "null_resource" "ansible" {
  depends_on = ["aws_efs_mount_target.wp-efs-mtarget1"]

  provisioner "local-exec" {
  	command = "sed -i \"s/SERVER1_IP/${aws_instance.wp-server-1b.private_ip}/g\" ansible/hosts"
  }

  provisioner "local-exec" {
  	command = "sed -i \"s/SERVER2_IP/${aws_instance.wp-server-1c.private_ip}/g\" ansible/hosts"
  }

  provisioner "local-exec" {
  	command = "sed -i \"s/FSID/${aws_efs_file_system.wp-efs.id}/g\" ansible/playbook.yml"
  }
 
  provisioner "local-exec" {
  	command = "sed -i \"s/FSID/${aws_efs_file_system.wp-efs.id}/g\" ansible/playbook.yml"
  }

  provisioner "local-exec" {
  	command = "sed -i \"s/DBHOST/${aws_db_instance.wp-db.address}/g\" ansible/playbook.yml"
  }
  provisioner "local-exec" {
  	command = "sed -i \"s/BASTION_IP/${aws_instance.bastion.public_ip}/g\" ansible/ssh.config"
  }

  provisioner "local-exec" {
    command = "cd ansible && ansible-playbook -i hosts playbook.yml -vvv"
    interpreter = ["/bin/bash", "-c"]
  }
}



