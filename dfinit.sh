#!/bin/bash

# Author : BTLABS, Braintrace, Inc.
# Date : 4/23/2021
# Description : Dragonfly Firstboot, initial connectivity.

# Variables
UUID_REGEX="[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}"
HostName="https://bd.braintrace.com"
Organization="6aaca33b-d4d2-4a25-80b3-b4b1e9b22163"
GUID=$(dmidecode -s system-uuid)
UbuntuVersion=$(lsb_release -r -s)
ConnectionInfo="{
    \"DeviceID\":\"$GUID\",
    \"Host\":\"$HostName\",
    \"OrganizationID\": \"$Organization\",
    \"ServerVerificationToken\":\"\"
}"
ServiceConfig="[Unit]
Description=The Remotely agent used for remote access.
[Service]
WorkingDirectory=/usr/local/bin/Remotely/
ExecStart=/usr/local/bin/Remotely/Remotely_Agent
Restart=always
StartLimitIntervalSec=0
RestartSec=10
[Install]
WantedBy=graphical.target"

# Change Hostname to UUID.
echo "Changing hostname to system id"
echo "$GUID" > /etc/hostname

# Installing packages needed for initial connectivity.
wget -q https://packages.microsoft.com/config/ubuntu/$UbuntuVersion/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
apt-get update
apt-get -y install dotnet-runtime-5.0
apt-get -y install libx11-dev unzip libc6-dev libgdiplus libxtst-dev xclip jq curl wget
wget $HostName/Downloads/Remotely-Linux.zip
mkdir -p /usr/local/bin/Remotely
unzip ./Remotely-Linux.zip -d /usr/local/bin/Remotely
chmod +x /usr/local/bin/Remotely/Remotely_Agent
echo "$ConnectionInfo" > /usr/local/bin/Remotely/ConnectionInfo.json
curl --head $HostName/Downloads/Remotely-Linux.zip | grep -i "etag" | cut -d' ' -f 2 > /usr/local/bin/Remotely/etag.txt
echo "$ServiceConfig" > /etc/systemd/system/remotely-agent.service
systemctl daemon-reload
systemctl enable remotely-agent
systemctl restart remotely-agent

# Cleanup extra files.
rm ./Remotely-Linux.zip
rm -rf /usr/local/bin/Remotely/Desktop
rm -rf /usr/local/bin/Remotely/cs
rm -rf /usr/local/bin/Remotely/de
rm -rf /usr/local/bin/Remotely/fr
rm -rf /usr/local/bin/Remotely/it
rm -rf /usr/local/bin/Remotely/ja
rm -rf /usr/local/bin/Remotely/ko
rm -rf /usr/local/bin/Remotely/pl
rm -rf /usr/local/bin/Remotely/pt-BR/
rm -rf /usr/local/bin/Remotely/ref
rm -rf /usr/local/bin/Remotely/ru
rm -rf /usr/local/bin/Remotely/tr
rm -rf /usr/local/bin/Remotely/zh-Hans
rm -rf /usr/local/bin/Remotely/zh-Hant

reboot
