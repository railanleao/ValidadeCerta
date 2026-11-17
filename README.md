# 🥬 Validade Certa

> Plataforma que conecta comércios locais a consumidores para vender, com desconto, produtos próximos da data de validade — e doar o que não for vendido.

![status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)
![.NET](https://img.shields.io/badge/.NET-11-512BD4)
![Blazor](https://img.shields.io/badge/Blazor-Web%20App-512BD4)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-PostGIS-336791)
![licença](https://img.shields.io/badge/licença-a%20definir-lightgrey)

Projeto nascido em **Parauapebas (PA)**, pensado para a realidade de cidades médias do interior: mercadinhos de bairro, padarias, hortifrútis e supermercados que perdem mercadoria todos os dias.

---

## 📌 Sumário

- [O problema](#-o-problema)
- [A solução](#-a-solução)
- [Princípio: custo zero](#-princípio-custo-zero)
- [Como funciona](#-como-funciona)
- [Reservas e controle de retirada](#-reservas-e-controle-de-retirada)
- [Páginas](#-páginas)
- [Funcionalidades](#-funcionalidades)
- [Regras de negócio](#-regras-de-negócio)
- [Design system](#-design-system)
- [Arquitetura e stack](#-arquitetura-e-stack)
- [Infraestrutura (gratuita)](#-infraestrutura-gratuita)
- [Modelo de dados (resumo)](#-modelo-de-dados-resumo)
- [Roadmap](#-roadmap)
- [Como rodar localmente](#-como-rodar-localmente)
- [Base legal](#-base-legal)
- [Contribuindo](#-contribuindo)
- [Licença](#-licença)

---

## 🎯 O problema

- Comércios jogam fora produtos que ainda estão bons (tomate maduro demais, pão do dia anterior, iogurte a 2 dias da validade).
- O prejuízo é duplo: perde-se o produto e paga-se pelo descarte.
- O consumidor, do outro lado, procura economizar e não sabe onde há promoção.

## 💡 A solução

Uma vitrine local de **produtos específicos** (não "sacolas surpresa"), com foto, preço, desconto e data de validade, onde:

- o **comerciante** anuncia em poucos segundos;
- o **consumidor** encontra ofertas perto de casa, **reserva** e **retira na loja**, pagando no balcão;
- o que não vender pode ser **doado** a instituições parceiras, com registro e relatório.

---

## 💰 Princípio: custo zero

O projeto segue uma regra simples: **só gastar quando não houver alternativa gratuita viável.**

| Decisão | Alternativa paga evitada |
|---|---|
| Pagamento no balcão (Pix/dinheiro) na fase inicial | Taxas de gateway de pagamento |
| Login com e-mail/senha e Google (ASP.NET Core Identity) | SMS para código de verificação |
| Mapas com **Leaflet + OpenStreetMap**; lojista marca a loja no mapa | Google Maps API |
| Alertas por **Web Push** e e-mail | Mensagens de WhatsApp iniciadas pela plataforma |
| CSS próprio com tokens + ícones Lucide + Google Fonts | Bibliotecas de UI/temas pagos |
| Bibliotecas open source (QRCoder, NetTopologySuite, SkiaSharp) | Componentes comerciais |
| Painel web para cadastro de produtos no MVP | Bot de WhatsApp (cobrado por mensagem desde out/2026) |

Custos que podem se tornar **necessários** mais adiante: domínio próprio (.com.br), hospedagem sem hibernação quando houver usuários reais e mensagens de WhatsApp acima da franquia gratuita.

---

## ⚙️ Como funciona

### Para o consumidor
1. Acessa o site (PWA — sem instalar nada) e vê ofertas próximas.
2. Filtra por categoria, bairro ou distância.
3. Reserva o produto e recebe um **código + QR Code**.
4. Retira na loja dentro do prazo e paga no balcão (Pix ou dinheiro).
5. Confirma a retirada e avalia a loja.

### Para o estabelecimento
1. Cadastra a loja (nome, endereço, WhatsApp) e marca a localização no mapa.
2. Anuncia produtos pelo painel web (foto, preço, unidade, validade).
3. Valida o código/QR do cliente na retirada.
4. Acompanha relatório: itens vendidos, valor recuperado, clientes novos, kg salvos e doados.

### Cadastro via WhatsApp (fase futura)

```
Dono:  [foto] tomate 3,50 kg vence sexta
Bot:   Tomate — R$ 3,50/kg — validade 07/11.
       Publicar? 1-Sim  2-Corrigir
Dono:  1
Bot:   ✅ Publicado! Desconto progressivo está DESLIGADO.
```

> Desde 01/10/2026, a Meta cobra por mensagem de serviço após uma franquia mensal gratuita. O bot só entra quando o volume e a receita justificarem.

---

## 🧾 Reservas e controle de retirada

Sem pagamento no site, o controle da venda é feito pelo **código de reserva**.

### Fluxo

```
Consumidor reserva ──▶ PENDENTE (código 6 dígitos + QR, prazo de retirada)
        │
        ├── Lojista valida código/QR no painel ──▶ RETIRADA ✅ (data/hora registradas)
        ├── Prazo acaba sem validação          ──▶ EXPIRADA (estoque volta à vitrine)
        └── Consumidor ou lojista cancela      ──▶ CANCELADA
```

### Garantias
- **A validação é a prova da venda:** registra produto, quantidade, preço, loja, consumidor e horário.
- **Dupla confirmação:** após a validação (ou a expiração), o consumidor recebe "Você retirou? Avalie a loja". Se o consumidor confirma e a loja não validou, a reserva é marcada como **divergente** para análise.
- **Incentivo para o lojista validar:** o estoque só é baixado com a validação; reservas presas bloqueiam a vitrine e lojas com boa taxa de validação ganham o selo "Loja confiável".
- **Anti-faltas:** limite de reservas ativas por consumidor e suspensão temporária após faltas repetidas.

### Métricas por loja (base para negociação)
- Reservas criadas, retiradas e taxa de retirada
- Valor recuperado (preço reservado × quantidade)
- Clientes únicos e **clientes novos** trazidos pela plataforma
- Kg salvos e kg doados

> Como o pagamento acontece no balcão, o valor registrado é o preço anunciado no momento da reserva.

---

## 🗺️ Páginas

### Consumidor (público)
| # | Página | MVP |
|---|---|---|
| 1 | Início / vitrine (ofertas próximas + filtros) | ✅ |
| 2 | Detalhe do produto | ✅ |
| 3 | Página da loja | ✅ |
| 4 | Entrar / criar conta | ✅ |
| 5 | Minhas reservas (código + QR) | ✅ |
| 6 | Como funciona | ✅ |
| 7 | Para comerciantes (captação de lojas) | ✅ |
| 8 | Termos de uso e privacidade (LGPD) | ✅ |
| 9 | Alertas e perfil | ⏳ |

### Estabelecimento (painel)
| # | Página | MVP |
|---|---|---|
| 10 | Cadastro da loja | ✅ |
| 11 | Painel — resumo do dia | ✅ |
| 12 | Produtos (lista) | ✅ |
| 13 | Novo / editar produto | ✅ |
| 14 | Reservas + validar código/QR | ✅ |
| 15 | Relatórios | ⏳ |
| 16 | Configurações (desconto progressivo, prazo de reserva) | ✅ |

### Administração
| # | Página | MVP |
|---|---|---|
| 17 | Aprovação de lojas | ✅ |
| 18 | Métricas por loja | ⏳ |

---

## ✨ Funcionalidades

### MVP
- [ ] Cadastro e login de estabelecimentos e consumidores
- [ ] Cadastro de produtos com foto, preço, unidade e validade
- [ ] Vitrine pública com busca por raio, categoria e bairro
- [ ] Reserva com código, QR Code e prazo de retirada
- [ ] Validação da retirada pelo estabelecimento
- [ ] Remoção automática de produtos vencidos
- [ ] Desconto progressivo opcional (por produto)

### Próximas versões
- [ ] Relatórios e métricas por loja
- [ ] Alertas por interesse e localização (Web Push / e-mail)
- [ ] Fluxo de doação para instituições parceiras
- [ ] Bot de WhatsApp para cadastro de produtos
- [ ] Pagamento via Pix no site
- [ ] Controle de validade do estoque (alertas internos para o comerciante)

---

## 📏 Regras de negócio

### Validade
- Só é permitido anunciar produtos **dentro do prazo de validade**.
- Ao passar da validade, o produto é **despublicado automaticamente**.
- A responsabilidade sanitária pelo produto é do estabelecimento (declarada nos termos de uso).

### Desconto progressivo
Cada produto tem a opção `DescontoProgressivoAtivo`:

| Situação | Comportamento |
|---|---|
| **Desligado** (padrão) | O preço informado fica fixo até o dono alterar. |
| **Ligado** | Um job diário recalcula o preço conforme a validade se aproxima. |

Faixas padrão (configuráveis por loja):

| Dias até a validade | Desconto sobre o preço original |
|---|---|
| 3 dias | 20% |
| 2 dias | 35% |
| Último dia | 50% |

- O preço **nunca** fica abaixo do `PrecoMinimo` definido pelo dono.
- O dono pode desligar o progressivo ou editar o preço a qualquer momento.

### Reservas
- A reserva expira se não for retirada no prazo (padrão: 2 horas, configurável pela loja).
- A quantidade reservada sai do estoque disponível até expirar, ser cancelada ou retirada.

### Doação
- Produto não vendido até o ponto de corte definido pela loja pode ser marcado como **"Doar"**.
- A instituição parceira é notificada para retirada.
- A doação é registrada para compor o relatório do estabelecimento.

---

## 🎨 Design system

### Conceito
**Fresco, acessível e confiável.** Verde comunica alimento fresco e sustentabilidade; laranja comunica apetite e oportunidade. O fundo creme remete a papel kraft e sacola de feira.

### Cores

| Token | Hex | Uso |
|---|---|---|
| `--cor-primaria` | `#15803D` | Marca, cabeçalho, links, confirmações |
| `--cor-primaria-clara` | `#DCFCE7` | Fundos de destaque verde |
| `--cor-acao` | `#C2410C` | Botão "Reservar", badge de desconto |
| `--cor-acao-clara` | `#FFEDD5` | Fundos de destaque laranja |
| `--cor-fundo` | `#FAF7F2` | Fundo da página (creme) |
| `--cor-superficie` | `#FFFFFF` | Cards |
| `--cor-texto` | `#1C1917` | Texto principal |
| `--cor-texto-suave` | `#57534E` | Texto secundário |
| `--cor-borda` | `#E7E5E4` | Bordas e divisores |

### Semáforo de validade

| Estado | Fundo | Texto | Regra |
|---|---|---|---|
| Tranquilo | `#DCFCE7` | `#166534` | 4+ dias |
| Atenção | `#FEF3C7` | `#92400E` | 2–3 dias |
| Vence hoje | `#FEE2E2` | `#B91C1C` | último dia |

> Vermelho é usado **somente** para "vence hoje" e erros — em alimentos, vermelho em excesso sugere perigo.
> Todas as combinações de texto atendem ao contraste mínimo **WCAG AA (4,5:1)**.

### Tipografia (Google Fonts, gratuitas)
- **Nunito** — títulos (arredondada, amigável)
- **Inter** — textos e preços (use `font-variant-numeric: tabular-nums` nos valores)

### Fundamentos
- Mobile first; área mínima de toque de **44px**
- Espaçamento em múltiplos de **4px** (4, 8, 12, 16, 24, 32)
- Raio de borda: **12px** em cards, **999px** em chips e badges
- Ícones: **Lucide** (open source)
- Estilos em CSS próprio com variáveis (tokens), sem biblioteca de UI pesada na vitrine

### Componentes principais
- **Card de oferta:** foto, badge de desconto, nome, preço original riscado, preço atual, badge de validade, loja e distância, botão "Reservar"
- Botões: primário (laranja), secundário (verde contorno), texto
- Chips de filtro (categoria, distância)
- Badges (desconto, validade, "Loja confiável")
- Código de reserva com QR Code
- Barra de navegação inferior (mobile): Ofertas · Reservas · Conta

---

## 🏗️ Arquitetura e stack

| Camada | Tecnologia |
|---|---|
| Plataforma | **.NET 11** / C# 15 |
| Web | **Blazor Web App** — SSR estático na vitrine pública; interatividade no painel do lojista |
| API | ASP.NET Core |
| Banco de dados | **PostgreSQL + PostGIS** (busca por raio e ordenação por distância) |
| ORM | Entity Framework Core + Npgsql + NetTopologySuite |
| Jobs agendados | `BackgroundService` (preço progressivo, expiração de reservas e produtos) |
| Autenticação | ASP.NET Core Identity + login com Google |
| Mapas | Leaflet + OpenStreetMap |
| QR Code | QRCoder |
| Imagens | Redimensionadas e convertidas para WebP no upload; armazenamento S3 compatível |
| Notificações | Web Push + e-mail |

### Por que SSR na vitrine?
- Abre rápido em 4G instável (HTML pronto, sem baixar runtime)
- Indexável pelo Google ("promoção mercado Parauapebas")
- Não mantém conexão aberta por visitante (menor custo de servidor)

```
[Consumidor - SSR/PWA] ──▶ [ASP.NET Core / Blazor Web App] ◀── [Painel do Lojista - interativo]
                                   │
                    ┌──────────────┼──────────────┐
                    ▼              ▼              ▼
          [PostgreSQL+PostGIS]  [Storage S3]  [Jobs em background]
```

---

## ☁️ Infraestrutura (gratuita)

| Necessidade | Opção gratuita | Observação |
|---|---|---|
| Código e CI/CD | GitHub + GitHub Actions | — |
| Banco de dados | Neon (Free) | Postgres serverless, sem cartão; hiberna sem uso |
| Imagens | Object Storage do Neon (Free) | S3 compatível |
| Aplicação | Render (Free) ou similar | Hiberna após inatividade (primeiro acesso lento) |
| E-mail transacional | Plano gratuito de um provedor (ex.: Brevo, Resend) | Verificar franquia |
| Domínio | Subdomínio gratuito do provedor | Domínio .com.br só quando lançar |

> Os limites dos planos gratuitos mudam com frequência — confira no momento da criação.
> Quando houver usuários reais, a hibernação da aplicação passa a ser o primeiro custo que vale a pena pagar.

---

## 🗂️ Modelo de dados (resumo)

```
Estabelecimento
  Id, Nome, Tipo, Endereco, Localizacao (geography), TelefoneWhatsApp,
  PrazoReservaMinutos, Aprovado, Ativo

Produto
  Id, EstabelecimentoId, Nome, Categoria, Unidade, FotoUrl,
  PrecoOriginal, PrecoAtual, PrecoMinimo,
  DataValidade, Quantidade,
  DescontoProgressivoAtivo, Status (Ativo | Esgotado | Vencido | Doado)

Reserva
  Id, ProdutoId, ConsumidorId, Quantidade, PrecoUnitario, Codigo,
  CriadaEm, ExpiraEm, ValidadaEm,
  Status (Pendente | Retirada | Expirada | Cancelada | Divergente),
  ConfirmacaoConsumidor (bool?), Avaliacao (1–5)

Consumidor
  Id, Nome, Email, Faltas, SuspensoAte

InstituicaoParceira
  Id, Nome, Contato, Endereco

Doacao
  Id, ProdutoId, InstituicaoId, Quantidade, PesoKg, Data
```

---

## 🛣️ Roadmap

- **Fase 0 – Validação:** conversar com 10+ comerciantes locais; fechar 10–15 parceiros piloto.
- **Fase 1 – MVP:** vitrine, cadastro web, reservas com código/QR, desconto progressivo, expiração automática.
- **Fase 2 – Piloto (30 dias):** medir taxa de retirada, tempo médio até a venda e recompra.
- **Fase 3 – Relatórios e alertas:** métricas por loja, Web Push e e-mail.
- **Fase 4 – Doação:** parcerias com instituições, relatório de impacto.
- **Fase 5 – Monetização:** assinatura para estabelecimentos → Pix integrado e comissão.
- **Fase 6 – WhatsApp:** bot de cadastro quando o volume justificar o custo.

---

## 🚀 Como rodar localmente

O ambiente roda inteiro em **Docker** — não é preciso instalar .NET SDK nem PostgreSQL na máquina.

### Pré-requisito
- Docker (com Docker Compose)

### Estrutura de arquivos Docker

```
.
├── docker-compose.yml          # banco (PostGIS) + app em modo watch + Adminer opcional
├── Dockerfile                  # imagem de produção (Render)
├── .dockerignore
├── .env.example                # copie para .env
├── docker/db/init/01-extensions.sql
└── src/ValidadeCerta.Web/      # projeto Blazor Web App
```

### Primeira vez

```bash
# 1. Variáveis de ambiente
cp .env.example .env

# 2. Criar o projeto Blazor usando o SDK do container (sem instalar nada)
docker run --rm -v "${PWD}:/src" -w /src mcr.microsoft.com/dotnet/sdk:11.0 \
  dotnet new blazor -n ValidadeCerta.Web -o src/ValidadeCerta.Web --interactivity Server

# 3. Subir banco + aplicação
docker compose up -d
```

> No Linux, adicione `--user $(id -u):$(id -g)` ao `docker run` para os arquivos não ficarem com dono root.

Acesse: **http://localhost:8080**

### Comandos do dia a dia

| Ação | Comando |
|---|---|
| Subir tudo | `docker compose up -d` |
| Ver logs da aplicação | `docker compose logs -f app` |
| Parar tudo (libera memória) | `docker compose stop` |
| Só o banco | `docker compose up -d db` |
| Abrir o Adminer (admin do banco) | `docker compose --profile tools up -d adminer` → http://localhost:8081 |
| Rodar comando `dotnet` | `docker compose exec app dotnet <comando>` |
| Adicionar pacote NuGet | `docker compose exec app dotnet add src/ValidadeCerta.Web package <Pacote>` |
| Criar migration | `docker compose exec app dotnet ef migrations add <Nome> --project src/ValidadeCerta.Web` |
| Apagar banco e começar do zero | `docker compose down -v` |

### Consumo de memória

| Container | Limite |
|---|---|
| `db` (PostGIS) | 512 MB |
| `app` (SDK + dotnet watch) | 1,5 GB |
| `adminer` (opcional) | 128 MB |

> O próprio Docker também reserva memória. No Windows (WSL2), defina um teto no arquivo `%UserProfile%\.wslconfig`.

---

## ⚖️ Base legal

- **Lei nº 15.224/2025** — Política Nacional de Combate à Perda e ao Desperdício de Alimentos. Protege doadores e intermediários (responsabilidade civil apenas em caso de dolo), cria o **Selo Doador de Alimentos** e prevê o uso de aplicativos e sites para aproximar quem doa de quem recebe.
- **Código de Defesa do Consumidor** — é proibido comercializar produtos com validade vencida; a plataforma impede esse cenário por regra de sistema.
- **LGPD** — dados pessoais de consumidores e lojistas tratados conforme a Lei nº 13.709/2018.

> Este projeto não presta assessoria jurídica. Estabelecimentos devem seguir as normas sanitárias vigentes.

---

## 🤝 Contribuindo

Sugestões e contribuições são bem-vindas! Abra uma *issue* para discutir a ideia antes de enviar um *pull request*.

---

## 📄 Licença

A definir.

---

Feito com 💚 em Parauapebas – PA.
