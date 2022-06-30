# -*- coding: utf-8 -*-
# vim: set syntax=yaml ts=2 sw=2 sts=2 et :

##
# Download profiles and upload into bucket
#
# Execute:
#   qubesctl --skip-dom0 --targets=mineos-hq state.sls profiles saltenv=user
##

setup mc client:
  cmd.run:
    - name: "mc alias set mineos http://{{ salt['pillar.get']('object-store:host') }} {{ salt['pillar.get']('object-store:access_key') }} {{ salt['pillar.get']('object-store:secret_key') }} --api S3v4"

{% for profile, values in salt['pillar.get']('profiles').items() %}

{% if profile == "mojang" %}
# logic for mojang profiles

setup mojang bucket:
  cmd.run:
    - name: "mc mb --ignore-existing mineos/mojang"

{% for version in values %}

download {{ profile }} server v{{ version }}:
  cmd.run:
    - name: "wget -nc -q -O /home/user/Downloads/{{ version }}.jar https://s3.amazonaws.com/Minecraft.Download/versions/{{ version }}/minecraft_server.{{ version }}.jar"
    - creates: "/home/user/Downloads/{{ version }}.jar"
    - unless: salt['file.exists']("/rw/volumes/{{ profile }}/{{ version }}.jar")

upload {{ profile }} server v{{ version }} to obj store:
  cmd.run:
    - name: "mc cp /home/user/Downloads/{{ version }}.jar mineos/{{ profile }}/{{ version }}.jar"
    - creates: "/rw/volumes/{{ profile }}/{{ version }}.jar"

{% endfor %}

# end mojang
{% endif %}

{% endfor %}
