/var/lib/ran:
  file.directory:
    - mode: 755
    - user: root
    - group: root

supervisor:
  pkg.installed

python-pip:
  pkg.installed:
    - reload_modules: true

at:
  pkg.installed:
    - name: at
  service.running:
    - name: atd
    - enable: True
