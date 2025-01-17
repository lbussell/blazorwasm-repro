﻿FROM mcr.microsoft.com/dotnet/nightly/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["BlazorApp1.csproj", "./"]
RUN dotnet workload install wasm-tools --skip-manifest-update
RUN dotnet restore "BlazorApp1.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "BlazorApp1.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN apt-get update -y
RUN apt-get install -y python3
RUN dotnet publish "BlazorApp1.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM httpd:2.4
EXPOSE 80
COPY --from=publish /app/publish/wwwroot /usr/local/apache2/htdocs
