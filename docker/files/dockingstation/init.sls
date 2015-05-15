include:
  - common
  - consul
  - docker

/etc/supervisor/conf.d/dockingstation.conf:
  file.managed:
    - source: salt://dockingstation/dockingstation.conf
    - mode: 644
    - user: root
    - group: root

/usr/local/bin/dockingstation:
  file.managed:
    - source: salt://dockingstation/dockingstation.bin
    - mode: 755
    - user: root
    - group: root

dockingstation:
  supervisord.running:
    - update: True
    - require:
      - pkg: supervisor
    - watch:
      - file: /etc/supervisor/conf.d/dockingstation.conf
