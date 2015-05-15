include:
  - consul

{% from "docker/map.jinja" import kernel with context %}

docker-python-apt:
  pkg.installed:
    - name: python-apt

{% if kernel.pkgrepo is defined %}
{{ grains['lsb_distrib_codename'] }}-backports-repo:
  pkgrepo.managed:
    {% for key, value in kernel.pkgrepo.items() %}
    - {{ key }}: {{ value }}
    {% endfor %}
    - require:
      - pkg: python-apt
    - onlyif: dpkg --compare-versions {{ grains['kernelrelease'] }} lt 3.8
{% endif %}

{% if kernel.pkg is defined %}
docker-dependencies-kernel:
  pkg.installed:
    {% for key, value in kernel.pkg.items() %}
    - {{ key }}: {{ value }}
    {% endfor %}
    - require_in:
      - pkg: lxc-docker
    - onlyif: dpkg --compare-versions {{ grains['kernelrelease'] }} lt 3.8
{% endif %}

docker-dependencies:
   pkg.installed:
    - pkgs:
      - iptables
      - ca-certificates
      - lxc

docker-repo:
    pkgrepo.managed:
      - humanname: Docker repo
      - name: deb http://get.docker.io/ubuntu docker main
      - file: /etc/apt/sources.list.d/docker.list
      - keyid: d8576a8ba88d21e9
      - keyserver: keyserver.ubuntu.com
      - require_in:
          - pkg: lxc-docker
      - require:
        - pkg: docker-python-apt

lxc-docker:
  pkg.latest:
    - fromrepo: docker
    - refresh: True
    - require:
      - pkg: docker-dependencies

/etc/default/docker:
  file:
     - managed
     - source: salt://docker/files/docker.defaults
     - template: jinja
     - context:
        internal_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}

/tmp/register_docker_consul.sh:
  file:
     - managed
     - source: salt://docker/files/register_docker_consul.sh
     - template: jinja
     - context:
       internal_ip: {{ salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
       tags: '"test","dev"'

docker-service:
  service.running:
    - name: docker
    - enable: True
    - watch: 
      - file: /etc/default/docker

cmd-register-docker-consul:
  cmd.run:
    - name: sh /tmp/register_docker_consul.sh && touch /var/lib/ran/cmd-register-docker-consul.ran
    - creates: /var/lib/ran/cmd-register-docker-consul.ran
    - require:
      - service: docker-service
      - file: /tmp/register_docker_consul.sh

file-register-docker-consul:
  file:
    - managed
    - name: /etc/consul.d/services/docker.json
    - source: salt://docker/files/docker.json.consul
    - template: jinja
    - context:
       tags: '"test","dev"'
