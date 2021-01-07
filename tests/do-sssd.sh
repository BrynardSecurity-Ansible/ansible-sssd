#!/bin/bash

# show commands, exit if any errors
set -ex

# sanity test
ansible all -m ping

echo "uncomment next line for secure LDAP SSSD"
#ansible-playbook ansible-sssd-playbook-ad-ldap-only.yml -l ldap_managed --extra-vars "extravar_ldap_default_authtok=MyP4ss!"

echo "uncomment next line for secure LDAP with Kerberos SSSD"
#ansible-playbook ansible-sssd-playbook-ad-ldap-plus-krb5.yml -l ldap_krb5_managed --extra-vars "extravar_ldap_default_authtok=MyP4ss! kerberos_user_password=MyP4ss!"

