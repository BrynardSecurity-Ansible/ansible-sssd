#!/bin/bash
#
# clones or does rebase pull of used roles
#

function pull() {
  cd $1
  git pull -r
  cd ..
}

for role in ansible-role-chrony ansible-role-domain-join ansible-sssd ansible-role-systemd-dns; do

  if [ -d $role ]; then
    cd $role; git pull -r; cd ..
  else
    git clone https://github.com/fabianlee/$role.git
  fi

done

