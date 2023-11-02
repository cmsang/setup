FROM mcr.microsoft.com/dotnet/aspnet:6.0

LABEL author.name="cmsang" \
    author.email="sangcm.research@gmail.com" \
    created-date="25/10/2023" \
    base-image="mcr.microsoft.com/dotnet/aspnet:6.0" \
    dotnet="6.0.24" \
    installed="libgdiplus htop curl telnet iputils-ping netcat nano dnsutils openssh-client fontconfig"

ENV TZ=Asia/Ho_Chi_Minh
ENV APP_PATH /app

WORKDIR $APP_PATH

COPY Fonts /usr/share/fonts/windows

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install -y --force-yes libgdiplus htop curl telnet iputils-ping netcat nano dnsutils openssh-client fontconfig
RUN echo fs.file-max=2097152 > /etc/sysctl.conf
RUN apt-get autoremove
RUN fc-cache -f -v
