nginx:
  pkg:
    - latest
  service:
    - running

nginx-files:
  file.recurse:
    - name: /usr/share/nginx/html
    - template: jinja
    - source: salt://nginx/files
    - user: root
    - group: root
    - file_mode: 644
