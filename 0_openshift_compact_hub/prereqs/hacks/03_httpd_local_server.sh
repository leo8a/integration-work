#!/bin/bash


mkdir -pv /opt/httpd
setenforce 0

cat <<EOF > /etc/systemd/system/podman-httpd.service
[Unit]
Description=Podman container - Apache
Wants=network-online.target
After=network-online.target
RequiresMountsFor=%t/containers

[Service]
Environment=PODMAN_SYSTEMD_UNIT=%n
Restart=on-failure
TimeoutStopSec=70
ExecStartPre=/bin/rm -f %t/%n.ctr-id
ExecStart=/usr/bin/podman run --cidfile=%t/%n.ctr-id --sdnotify=conmon --cgroups=no-conmon --rm --replace -d --name httpd -v /opt/httpd:/var/www/html -p 9000:8080/tcp registry.centos.org/centos/httpd-24-centos7:latest
ExecStop=/usr/bin/podman stop --ignore --cidfile=%t/%n.ctr-id
ExecStopPost=/usr/bin/podman rm -f --ignore --cidfile=%t/%n.ctr-id
Type=notify
NotifyAccess=all

[Install]
WantedBy=multi-user.target default.target
EOF

systemctl daemon-reload
systemctl enable podman-httpd --now

systemctl stop firewalld
systemctl disable firewalld

ss -lptn | grep 9000
