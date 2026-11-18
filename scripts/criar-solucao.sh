#!/usr/bin/env bash
# Cria a solução Validade Certa (Clean Architecture enxuta)
# Executar dentro do container do SDK — veja o README.
set -euo pipefail

NOME="ValidadeCerta"

echo "==> Solução"
dotnet new sln -n "$NOME"

echo "==> Projetos"
dotnet new classlib -n "$NOME.Domain"         -o "src/$NOME.Domain"
dotnet new classlib -n "$NOME.Application"    -o "src/$NOME.Application"
dotnet new classlib -n "$NOME.Infrastructure" -o "src/$NOME.Infrastructure"
dotnet new blazor   -n "$NOME.Web"            -o "src/$NOME.Web" --interactivity Server --empty

dotnet new xunit -n "$NOME.Domain.Tests"      -o "tests/$NOME.Domain.Tests"
dotnet new xunit -n "$NOME.Application.Tests" -o "tests/$NOME.Application.Tests"

rm -f src/*/Class1.cs

echo "==> Adicionando à solução"
dotnet sln add \
  "src/$NOME.Domain/$NOME.Domain.csproj" \
  "src/$NOME.Application/$NOME.Application.csproj" \
  "src/$NOME.Infrastructure/$NOME.Infrastructure.csproj" \
  "src/$NOME.Web/$NOME.Web.csproj" \
  "tests/$NOME.Domain.Tests/$NOME.Domain.Tests.csproj" \
  "tests/$NOME.Application.Tests/$NOME.Application.Tests.csproj"

echo "==> Referências entre camadas"
# Application -> Domain
dotnet add "src/$NOME.Application" reference "src/$NOME.Domain"
# Infrastructure -> Application (e Domain, por transitividade)
dotnet add "src/$NOME.Infrastructure" reference "src/$NOME.Application"
# Web -> Application + Infrastructure (Infrastructure só para registrar a injeção de dependência)
dotnet add "src/$NOME.Web" reference "src/$NOME.Application" "src/$NOME.Infrastructure"
# Testes
dotnet add "tests/$NOME.Domain.Tests" reference "src/$NOME.Domain"
dotnet add "tests/$NOME.Application.Tests" reference "src/$NOME.Application"

echo "==> Pacotes NuGet"
# Domain: tipo Point para a localização das lojas
dotnet add "src/$NOME.Domain" package NetTopologySuite

# Versões fixadas na linha 10.x para combinar com o .NET 10
# (sem isso, o NuGet pode puxar a versão 11, que exige .NET 11)
EF_VERSION="10.*"

# Infrastructure: EF Core + PostgreSQL + PostGIS
dotnet add "src/$NOME.Infrastructure" package Npgsql.EntityFrameworkCore.PostgreSQL --version "$EF_VERSION"
dotnet add "src/$NOME.Infrastructure" package Npgsql.EntityFrameworkCore.PostgreSQL.NetTopologySuite --version "$EF_VERSION"

# Web: necessário para gerar migrations
dotnet add "src/$NOME.Web" package Microsoft.EntityFrameworkCore.Design --version "$EF_VERSION"

echo "==> Ferramenta dotnet-ef (local ao repositório)"
dotnet new tool-manifest
dotnet tool install dotnet-ef --version "$EF_VERSION"

echo "==> Build"
dotnet build

echo "✅ Solução criada com sucesso!"
