FROM mcr.microsoft.com/dotnet/core/sdk:3.1-alpine as builder

WORKDIR /src

COPY *.csproj ./

RUN dotnet restore
COPY . .

RUN dotnet publish -c Release -o /src/out

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-alpine

RUN apk add --no-cache openssh openrc vim curl wget tcptraceroute bash icu-libs

# dotnet env variables

ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8

# dotnet image/skia dependencies
RUN apk add --no-cache fontconfig \
    && apk add --no-cache libgdiplus --repository http://dl-3.alpinelinux.org/alpine/edge/testing --allow-untrusted

# app service setup

RUN mkdir -p /home/LogFiles \
    && echo "root:Docker!" | chpasswd \
    && echo "cd /home" >> /etc/bash.bashrc

COPY docker/sshd_config /etc/ssh/
COPY docker/ssh_setup.sh /tmp/
RUN mkdir -p /opt/startup \
    && chmod -R +x /opt/startup \
    && chmod -R +x /tmp/ssh_setup.sh \
    && (sleep 1; /tmp/ssh_setup.sh 2>&1 > /dev/null) \
    && rm -rf /tmp/*

COPY docker/init_container.sh /bin/
RUN chmod 755 /bin/init_container.sh

ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true \
    WEBSITE_ROLE_INSTANCE_ID=localRoleInstance \
    WEBSITE_INSTANCE_ID=localInstance \
    SSH_PORT=2222
RUN unset ASPNETCORE_URLS

EXPOSE 2222

# copy and set up project files

COPY --from=builder /src/out /home/site/wwwroot

WORKDIR /home/site/wwwroot

ENV ASPNETCORE_URLS="http://*:80"
EXPOSE 80

ENV DOTNET_DLL "AzureDockerTest.dll"
ENTRYPOINT ["/bin/init_container.sh"]
