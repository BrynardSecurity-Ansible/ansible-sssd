#!/bin/bash
#
# Did testing with Ubuntu bionic/18 and focal/20
# Used OOTB installs with baseline snapshot set at 'before-sssd-test'
# 
# This script is used to rollback the changes, for another test variation
#

set -x
for domain in focal1 bionic1; do
  virsh destroy $domain
  virsh snapshot-revert --domain $domain before-sssd-test
  virsh start $domain
done
