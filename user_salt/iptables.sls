# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Installs firewall rules in AppVMs
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq,mos-firewall state.sls iptables saltenv=user
##

{% if salt['cmd.run']('hostname') == salt['pillar.get']('hosts:network') %}

# INGRESS mos-firewall

webui traffic through {{ salt['pillar.get']('hosts:network') }} to hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: FORWARD
    - protocol: tcp
    - dport: 4567
    - destination: {{ salt['pillar.get']('ips:mineos-hq') }}
    - jump: ACCEPT
    - save: True

amqp webui traffic through {{ salt['pillar.get']('hosts:network') }} to hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: FORWARD
    - protocol: tcp
    - dport: 15672
    - destination: {{ salt['pillar.get']('ips:mineos-hq') }}
    - jump: ACCEPT
    - save: True

minio webui traffic through {{ salt['pillar.get']('hosts:network') }} to hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: FORWARD
    - protocol: tcp
    - dport: 9001
    - destination: {{ salt['pillar.get']('ips:mineos-hq') }}
    - jump: ACCEPT
    - save: True

{% endif %}

{% if salt['cmd.run']('hostname') == salt['pillar.get']('hosts:hq') %}

# INGRESS mineos-hq

webui traffic into hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: INPUT
    - dport: 4567
    - protocol: tcp
    - jump: ACCEPT

amqp webui traffic into hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: INPUT
    - dport: 15672
    - protocol: tcp
    - jump: ACCEPT

minio webui into hq:
  iptables.insert:
    - table: filter
    - position: 1
    - chain: INPUT
    - dport: 9001
    - protocol: tcp
    - jump: ACCEPT

{% endif %}

