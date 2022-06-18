# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Removes 'mineos-hq' and 'mineos-worker' AppVMs, as well as the 
# templateVM 'mos-template' that supports them.
#
# located in ``/srv/salt/``
#
# Execute:
#   qubesctl state.sls mineos-remove saltenv=user
##

mineos-worker:
  qvm.absent

mineos-hq:
  qvm.absent

mos-template:
  qvm.absent

mos-template-tmp:
  qvm.absent

