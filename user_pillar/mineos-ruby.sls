object-store:
  host: localhost:9000
  console: :9001
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
  browser: mineos-webui
  worker_username: user
  satellites:
    - mineos-worker

ips:
  mineos-hq: 10.137.0.1
  mineos-worker: 10.137.0.9
  mos-firewall: 10.137.0.6

profiles:
  mojang:
    - 1.6.4
    - 1.8.9
  manualmojang/1.0:
    minecraft_server.1.6.4.jar: https://s3.amazonaws.com/Minecraft.Download/versions/1.6.4/minecraft_server.1.6.4.jar
    minecraft_server.1.8.8.jar: https://s3.amazonaws.com/Minecraft.Download/versions/1.8.8/minecraft_server.1.8.8.jar

