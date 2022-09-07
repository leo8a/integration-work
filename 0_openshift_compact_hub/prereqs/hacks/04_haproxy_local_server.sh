#!/bin/bash


# 1) Configure Haproxy server
printf "\n============================\n"
printf "| Configure Haproxy server |\n"
printf "============================\n\n"

cat <<EOF > /etc/quay-install/haproxy.cfg
global
    log         127.0.0.1 local2
    maxconn     4000
    daemon

defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen quay-8443
    bind :::8443 v6only
    mode http
    balance source
    server localhost 127.0.0.1:8443 check inter 1s

listen httpd-9000
    bind :::9000 v6only
    mode http
    balance source
    server localhost 127.0.0.1:9000 check inter 1s

#listen gitserver-3000
#    bind :::3000 v6only
#    mode http
#    balance source
#    server localhost 127.0.0.1:3000 check inter 1s
EOF

cat <<EOF > /usr/lib/systemd/system/quay_haproxy.service
[Unit]
Description=Haproxy Podman Container for Quay
Wants=network.target
After=network-online.target

[Service]
Type=simple
TimeoutStartSec=5m
ExecStartPre=-/bin/rm -f %t/%n-pid %t/%n-cid
ExecStart=/usr/bin/podman run \
    --name quay-haproxy \
    -v /etc/quay-install/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
    --net host --privileged \
    --pod=quay-pod \
    --conmon-pidfile %t/%n-pid \
    --cidfile %t/%n-cid \
    --cgroups=no-conmon \
    --replace \
    quay.io/karmab/haproxy:latest

ExecStop=-/usr/bin/podman stop --ignore --cidfile %t/%n-cid -t 10
ExecStopPost=-/usr/bin/podman rm --ignore -f --cidfile %t/%n-cid
PIDFile=%t/%n-pid
KillMode=none
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target default.target
EOF


# 2) Start & Enable Haproxy server
printf "\n=================================\n"
printf "| Start & Enable Haproxy server |\n"
printf "=================================\n\n"

systemctl daemon-reload
systemctl enable quay_haproxy --now ; sleep 25


# 3) Check Haproxy server's endpoints
printf "\n====================================\n"
printf "| Check Haproxy server's endpoints |\n"
printf "====================================\n\n"

ss -lptn | grep haproxy

curl -v http://"[2620:52:0:1305::1]":9000
curl -k https://"[2620:52:0:1305::1]":8080/redfish/v1/Systems/
