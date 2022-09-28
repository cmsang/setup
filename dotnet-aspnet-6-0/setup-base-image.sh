docker build -t hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9 .
docker build -t hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9-utils -f Dockerfile-base-utils .
docker images
docker save hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9 | gzip > aspnet_6_0_9.tar.gz
docker save hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9-utils | gzip > aspnet_6_0_9_utils.tar.gz
