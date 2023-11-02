
docker system prune
docker rmi hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.24.1 --force
docker build -t hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.24.1 .
docker save -o hcsn-aspnet_6_0_24_1.tar hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.24.1

@REM docker save hcsn/mcr.microsoft.com/dotnet/aspnet:6.0.9 | gzip > aspnet_6_0_9.tar.gz

