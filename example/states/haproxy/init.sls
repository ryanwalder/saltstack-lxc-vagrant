haproxy:
  pkg:
    - latest
  file:
    - managed
    - name: /etc/haproxy/haproxy.cfg
    - source: salt://haproxy/files/haproxy.cfg
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: haproxy
    - watch_in:
      - service: haproxy
  service:
    - running
    - enable: True
    - require:
      - file: enable-haproxy-service

enable-haproxy-service:
  file.managed:
    - name: /etc/default/haproxy
    - contents_pillar: haproxy:enabled
    - watch_in:
      - service: haproxy
