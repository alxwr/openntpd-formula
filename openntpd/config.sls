{% from "openntpd/map.jinja" import openntpd with context %}

include:
  - openntpd

openntpd-config:
  file.managed:
    - name: {{ openntpd.conffile }}
    - source: salt://openntpd/files/ntpd.conf
    - template: jinja
{% if openntpd.apparmor_enabled %}
    {% set cfg = openntpd.conffile %}
    {% set bak = openntpd.conffile ~ '.check_bak' %}
    - check_cmd: sh -c 'cp {{ cfg }} {{ bak }} && cp $0 {{ cfg }} && {{ openntpd.binary }} -n -f {{ cfg }}; res=$?; mv {{ bak }} {{ cfg }}; exit $res'
{% else %}
    - check_cmd: {{ openntpd.binary }} -n -f
{% endif %}
    - watch_in:
      - service: openntpd
    - require_in:
      - service: openntpd

{%- if grains['os_family'] in ['Debian'] %}
/etc/default/openntpd:
  file.managed:
    - source: salt://openntpd/files/defaults.openntpd.jinja
    - template: jinja
    - watch_in:
      - service: openntpd
    - require_in:
      - service: openntpd
{%  endif%}
