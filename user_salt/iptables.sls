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

traffic passing through firewall:
  file.append:
    - name: /rw/config/qubes-firewall-user-script
    - text:
      - iptables -A FORWARD -d {{ salt['pillar.get']('ips:mineos-hq') }}/32 -p tcp -m tcp --dport 4567 -j ACCEPT
      - iptables -A FORWARD -d {{ salt['pillar.get']('ips:mineos-hq') }}/32 -p tcp -m tcp --dport 9001 -j ACCEPT
      - iptables -A FORWARD -d {{ salt['pillar.get']('ips:mineos-hq') }}/32 -p tcp -m tcp --dport 15672 -j ACCEPT

{% endif %}

{% if salt['cmd.run']('hostname') == salt['pillar.get']('hosts:hq') %}

# INGRESS mineos-hq

webui traffic into hq:
  file.append:
    - name: /rw/config/qubes-firewall-user-script
    - text:
      - iptables -A INPUT -p tcp -m tcp --dport 4567 -j ACCEPT
      - iptables -A INPUT -p tcp -m tcp --dport 9001 -j ACCEPT
      - iptables -A INPUT -p tcp -m tcp --dport 15672 -j ACCEPT

{% endif %}

