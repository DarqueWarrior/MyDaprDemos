FROM mcr.microsoft.com/dotnet/sdk:6.0 as SDK

WORKDIR /src
COPY . .
RUN dotnet publish -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:6.0 as RUNTIME

WORKDIR /app
COPY --from=SDK /out /app
ENTRYPOINT ["dotnet", "/app/processor.dll"]