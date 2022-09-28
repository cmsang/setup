FROM mcr.microsoft.com/dotnet/aspnet:6.0

LABEL author.name="cmsang" \
    author.email="sangcm.research@gmail.com" \
    created-date="28/09/2022" \
    base-image="mcr.microsoft.com/dotnet/aspnet:6.0" \
    installed="libgdiplus"

ENV TZ=Asia/Ho_Chi_Minh
ENV APP_PATH /app

WORKDIR $APP_PATH
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
RUN echo $TZ > /etc/timezone
RUN apt-get update
RUN apt-get install -y --force-yes libgdiplus
RUN echo fs.file-max=2097152 > /etc/sysctl.conf
RUN apt-get autoremove
