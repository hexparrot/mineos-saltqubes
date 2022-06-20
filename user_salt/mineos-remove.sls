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

{{ salt['pillar.get']('hosts:hq') }}:
  qvm.absent

{% for host in salt['pillar.get']('hosts:satellites') %}
{{ host }}:
  qvm.absent
{% endfor %}

mos-template-tmp:
  qvm.absent

{{ salt['pillar.get']('hosts:network') }}:
  qvm.absent

mos-template:
  qvm.absent

