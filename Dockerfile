# Imagem de produção (Render ou qualquer host de containers)

# ---- build ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copia só os .csproj primeiro para aproveitar o cache do restore
COPY src/ValidadeCerta.Domain/*.csproj         src/ValidadeCerta.Domain/
COPY src/ValidadeCerta.Application/*.csproj    src/ValidadeCerta.Application/
COPY src/ValidadeCerta.Infrastructure/*.csproj src/ValidadeCerta.Infrastructure/
COPY src/ValidadeCerta.Web/*.csproj            src/ValidadeCerta.Web/
RUN dotnet restore src/ValidadeCerta.Web/ValidadeCerta.Web.csproj

COPY . .
RUN dotnet publish src/ValidadeCerta.Web/ValidadeCerta.Web.csproj \
    -c Release -o /app/publish --no-restore

# ---- runtime ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
COPY --from=build /app/publish .

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
USER $APP_UID

# O Render informa a porta pela variável PORT; localmente usa 8080
CMD ASPNETCORE_URLS=http://+:${PORT:-8080} dotnet ValidadeCerta.Web.dll
