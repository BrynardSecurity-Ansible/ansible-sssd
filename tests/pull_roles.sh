#!/bin/bash
#
# Uses ansible-galaxy to pull all dependent roles
#

function pull() {
  cd $1
  git pull -r
  cd ..
}

######### MAIN #####################

# pulls all dependent roles
ansible-galaxy install -r requirements.yml -p roles/ -vvv --force
exit $?

# DEPRECATED: pulled dependent roles manually
#pushd .
#mkdir -p roles && cd $_
#for role in ansible-role-chrony ansible-role-domain-join ansible-sssd ansible-role-systemd-dns; do
#
#  if [ -d $role ]; then
#    cd $role; git pull -r; cd ..
#  else
#    git clone https://github.com/fabianlee/$role.git
#  fi
#
#done
#popd

