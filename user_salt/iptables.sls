# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Installs firewall rules in AppVMs
#
# Execute:
#   qubesctl state.sls firewall saltenv=user
##

{% if salt['cmd.run']('hostname') == salt['pillar.get']('hosts:network') %}

# into mos-firewall
webui traffic passing through {{ salt['pillar.get']('hosts:network') }} to hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: FORWARD
    - protocol: tcp
    - dport: 4567
    - destination: {{ salt['pillar.get']('ips:mineos-hq') }}
    - jump: ACCEPT
    - save: True

{% endif %}

{% if salt['cmd.run']('hostname') == salt['pillar.get']('hosts:hq') %}

# into mineos-hq
webui traffic into host:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: INPUT
    - dport: 4567
    - protocol: tcp
    - jump: ACCEPT

{% endif %}

