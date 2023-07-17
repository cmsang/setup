docker build -t hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9 .
docker images
docker save hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9 | gzip > aspnet_6_0_9.tar.gz
