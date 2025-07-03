FROM --platform=linux/amd64 mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
ENV ASPNETCORE_URLS=http://+:80

FROM --platform=linux/amd64 mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["VibesApp.csproj", "."]
RUN dotnet restore "./VibesApp.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "VibesApp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "VibesApp.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "VibesApp.dll"]