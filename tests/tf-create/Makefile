THISDIR := $(notdir $(CURDIR))
PROJECT := $(THISDIR)

init: create-keypair
	# skips init if .terraform directory already exists
	[ -d .terraform ] || terraform init

apply: init 
	terraform apply -auto-approve
	terraform output

destroy:
	terraform destroy -force -auto-approve
	#rm terraform.tfstate*

## create public/private keypair for ssh
create-keypair:
	# skips if file already exists
	[ -f id_rsa ] || ssh-keygen -t rsa -b 4096 -f id_rsa -C $(PROJECT) -N "" -q

refresh:
	terraform refresh && terraform output

libvirt-pool:
	$(eval POOLDIR=$(shell virsh pool-dumpxml default | grep -E "<path>.*</path>" | grep -Po "(?<=\>)[^<]+"))

snapshot-create: libvirt-pool
	@echo default pool is $(POOLDIR)
	set -x; for d in xenial1-192.168.122.200 bionic1-192.168.122.201 focal1-192.168.122.202; do \
	  virsh domblklist $$d ;\
	  virsh snapshot-create-as $$d --name before-test --disk-only --diskspec vda,file=$(POOLDIR)/$$d-snapshot.qcow2 --diskspec hdd,snapshot=no ;\
	  virsh snapshot-list $$d ;\
	  sudo qemu-img info $(POOLDIR)/$$d-snapshot.qcow2 -U | grep backing ;\
	done

snapshot-revert: libvirt-pool
	set -x; for d in xenial1-192.168.122.200 bionic1-192.168.122.201 focal1-192.168.122.202; do \
	  shortname=`echo $$d | cut -d"-" -f1` ;\
	  virsh destroy $$d; \
	  sleep 2; \
	  virt-xml $$d --edit target=vda --disk path=$(POOLDIR)/$$shortname.qcow2 --update ;\
	  virsh snapshot-delete --metadata $$d before-test ;\
	  sudo rm $(POOLDIR)/$$d-snapshot.qcow2 ;\
	  virsh start $$d; \
	done

## validate syntax of cloud_init
validate-cloud-config:
	cloud-init devel schema --config-file cloud_init.cfg
