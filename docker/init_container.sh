#!/usr/bin/env bash

cat >/etc/motd <<EOL
Azure Docker Test
Distribution: `. /etc/os-release; echo $PRETTY_NAME`
   .NET Core: `dotnet --info 2> /dev/null | sed -n '/^Host/!b;n;s/\s*Version:\s*//g;p'`
---------------------------------
EOL
cat /etc/motd

echo "Starting SSH."
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
/usr/sbin/sshd

echo "Starting site."
exec dotnet "$DOTNET_DLL"
