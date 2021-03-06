include:
  - common

/usr/local/bin/consul:
  file.managed:
    - source: salt://consul/consul.bin
    - mode: 755
    - user: root
    - group: root

/etc/consul.d/agent:
  file.directory:
    - makedirs: True

/etc/consul.d/services:
  file.directory:
    - makedirs: True

/etc/consul.d/agent/config.json:
  file.managed:
    - source: salt://consul/config.json
    - mode: 644
    - user: root
    - group: root

/etc/supervisor/conf.d/consul.conf:
  file.managed:
    - source: salt://consul/consul.conf
    - mode: 644
    - user: root
    - group: root

setcap 'cap_net_bind_service=+ep' /usr/local/bin/consul:
  cmd.run

consul:
  user.present:
    - fullname: Consul Role
    - home: /var/lib/consul
    - createhome: True
  supervisord.running:
    - update: True
    - restart: True
    - require:
      - pkg: supervisor
    - watch:
      - file: /etc/consul.d/agent/config.json

/var/lib/consul:
  file.directory:
    - mode: 755
    - user: consul
    - group: consul

## modify the resolv.conf file before enabling this! (though it should still work if consul is configured properly)
#/etc/resolv.conf:
#  file.managed:
#    - source: salt://consul/resolv.conf
#    - mode: 644
#    - user: root
#    - group: root
#
## keep this from being overwritten
#chattr +i /etc/resolv.conf:
#  cmd.run
