FROM mcr.microsoft.com/dotnet/sdk:8.0 as build

WORKDIR /app

COPY WebApi.csproj .

RUN dotnet restore "WebApi.csproj"

COPY . .

RUN dotnet publish "WebApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine

WORKDIR /app

COPY --from=build /app/publish .

CMD ["dotnet", "WebApi.dll"]