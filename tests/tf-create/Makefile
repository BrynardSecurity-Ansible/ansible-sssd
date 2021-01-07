THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)

init:
	# skips init if .terraform directory already exists
	[ -d .terraform ] || terraform init

apply: init create-keypair
	terraform apply -auto-approve
	#-var-file=xenial.tfvars
	#terraform apply -auto-approve -var-file=bionic.tfvars
	#terraform apply -auto-approve -var-file=focal.tfvars

## recreate terraform resources
rebuild: destroy apply

destroy:
	terraform destroy -force -auto-approve
	#-var-file=xenial.tfvars

## create public/private keypair for ssh
create-keypair:
	# skips if file already exists
	[ -f id_rsa ] || ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

metadata:
	terraform refresh && terraform output

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg
