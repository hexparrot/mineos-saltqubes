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
    - name: "mc alias set mineos http://{{ salt['pillar.get']('object-store:host') }}:{{ salt['pillar.get']('object-store:port') }} {{ salt['pillar.get']('object-store:access_key') }} {{ salt['pillar.get']('object-store:secret_key') }} --api S3v4"

setup profile bucket:
  cmd.run:
    - name: "mc mb --ignore-existing mineos/profiles"

{% for profile, values in salt['pillar.get']('profiles').items() %}

{% if profile == "mojang" %}
# logic for mojang profiles

{% for version in values %}

download {{ profile }} server v{{ version }}:
  cmd.run:
    - name: "wget -nc -q -O /home/user/Downloads/minecraft_server.{{ version }}.jar https://s3.amazonaws.com/Minecraft.Download/versions/{{ version }}/minecraft_server.{{ version }}.jar"
    - creates: "/home/user/Downloads/minecraft_server.{{ version }}.jar"
    - unless: salt['file.exists']("/rw/volumes/profiles/{{ profile }}/{{ version }}/minecraft_server.{{ version }}.jar")

upload {{ profile }} server v{{ version }} to obj store:
  cmd.run:
    - name: "mc cp /home/user/Downloads/minecraft_server.{{ version }}.jar mineos/profiles/{{ profile }}/{{ version }}/minecraft_server.{{ version }}.jar"
    - creates: "/rw/volumes/profiles/{{ profile }}/{{ version }}/minecraft_server.{{ version }}.jar"

{% endfor %}

# end mojang

{% else %}

# default handling of profiles in pillar

{% set shortprofile = profile.split("/")|first %}
{% set version = profile.split("/")|last %}
{% for fn, uri in values.items() %}

download {{ profile }} serverfile {{ fn }}:
  cmd.run:
    - name: "wget -nc -q -O /home/user/Downloads/{{ fn }} {{ uri }}"
    - creates: "/home/user/Downloads/{{ fn }}"
    - unless: salt['file.exists']("/rw/volumes/profiles/{{ shortprofile }}/{{ version }}/{{ fn }}")

upload {{ profile }} serverfile {{ fn }} to obj store:
  cmd.run:
    - name: "mc cp /home/user/Downloads/{{ fn }} mineos/profiles/{{ shortprofile }}/{{ version }}/{{ fn }}"
    - creates: "/rw/volumes/profiles/{{ shortprofile }}/{{ version }}/{{ fn }}"

{% endfor %}

# end default handling
{% endif %}

{% endfor %}
