object-store:
  host: localhost:9000
  access_key: minecraft
  secret_key: Budk86v4F3JR8CE 

amqp:
  host: localhost
  port: 5672
  vhost: mineos
  user: wirt
  pass: overthegardenwall

hosts:
  hq: mineos-hq
  network: mos-firewall
  worker_username: user
  satellites:
    - mineos-worker

profiles:
  mojang:
    - 1.6.4
    - 1.8.9

