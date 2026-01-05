# data-raw/create_series_database.R
#' Create br_available_series dataset
#'
#' This script creates the comprehensive dataset of Brazilian economic series
#' that is included in the brfinance package.

# Dataset completo com 31 séries principais do BCB

br_available_series <- NULL

br_available_series <- tibble::tibble(
  series_id = c(
    # Inflação (6)
    "433",      # IPCA
    "4389",     # INPC
    "4390",     # IGP-M
    "4391",     # IGP-DI
    "188",      # IPCA-15
    "4448",     # IPCA-E (especial)

    # Juros e Monetário (6)
    "1178",     # SELIC Meta
    "11",       # SELIC Efetiva
    "189",      # CDI
    "4392",     # TJLP
    "4393",     # TR
    "7812",     # TLP

    # Câmbio (4)
    "1",        # USD Compra
    "10813",    # USD Venda
    "21619",    # EUR Compra
    "21620",    # EUR Venda

    # PIB e Contas Nacionais (3)
    "22099",    # PIB Trimestral (volume)
    "22100",    # PIB Trimestral (corrente)
    "22109",    # PIB Mensal (estimativa)

    # Fiscal (4)
    "4536",     # Dívida Bruta do Governo Geral
    "4537",     # Dívida Líquida do Governo Geral
    "4649",     # Resultado Primário
    "4650",     # Resultado Nominal

    # Setor Externo (5)
    "22701",    # Reservas Internacionais
    "13621",    # Balança Comercial (exportação)
    "13622",    # Balança Comercial (importação)
    "13623",    # Balança Comercial (saldo)
    "24363",    # Conta Corrente

    # Emprego e Atividade (3)
    "24369",    # Taxa de Desocupação (PNAD Contínua)
    "28770",    # Nível da Atividade (IBC-Br)
    "28771"     # IBC-Br Dessazonalizado
  ),

  source = rep("BCB", 31),
  source_system = rep("SGS", 31),

  short_name = c(
    "IPCA", "INPC", "IGP-M", "IGP-DI", "IPCA15", "IPCA-E",
    "SELIC_Meta", "SELIC_Efetiva", "CDI", "TJLP", "TR", "TLP",
    "USD_Compra", "USD_Venda", "EUR_Compra", "EUR_Venda",
    "PIB_Volume", "PIB_Corrente", "PIB_Mensal",
    "Divida_Bruta_GG", "Divida_Liquida_GG", "Resultado_Primario", "Resultado_Nominal",
    "Reservas_Int", "Exportacoes", "Importacoes", "Saldo_Comercial", "Conta_Corrente",
    "Taxa_Desocupacao", "IBC_Br", "IBC_Br_Dessaz"
  ),

  long_name_pt = c(
    "Índice Nacional de Preços ao Consumidor Amplo",
    "Índice Nacional de Preços ao Consumidor",
    "Índice Geral de Preços - Mercado",
    "Índice Geral de Preços - Disponibilidade Interna",
    "Índice Nacional de Preços ao Consumidor Amplo 15",
    "Índice Nacional de Preços ao Consumidor Amplo Especial",
    "Taxa Selic - Meta definida pelo COPOM",
    "Taxa Selic - Efetiva",
    "Taxa de Juros - CDI (Certificado de Depósito Interbancário)",
    "Taxa de Juros de Longo Prazo",
    "Taxa Referencial de Juros",
    "Taxa de Longo Prazo",
    "Taxa de câmbio - Livre - Dólar americano (compra)",
    "Taxa de câmbio - Livre - Dólar americano (venda)",
    "Taxa de câmbio - Livre - Euro (compra)",
    "Taxa de câmbio - Livre - Euro (venda)",
    "Produto Interno Bruto - Índice de Volume Trimestral",
    "Produto Interno Bruto a preços de mercado - Valores correntes",
    "Produto Interno Bruto Mensal - Estimativa",
    "Dívida Bruta do Governo Geral",
    "Dívida Líquida do Governo Geral",
    "Resultado Primário do Governo Geral",
    "Resultado Nominal do Governo Geral",
    "Reservas Internacionais",
    "Balança Comercial - Exportação FOB",
    "Balança Comercial - Importação FOB",
    "Balança Comercial - Saldo",
    "Conta Corrente - Transações Correntes",
    "Taxa de desocupação - PNAD Contínua",
    "Índice de Atividade Econômica do Banco Central (IBC-Br)",
    "Índice de Atividade Econômica do Banco Central dessazonalizado"
  ),

  long_name_en = c(
    "Broad National Consumer Price Index",
    "National Consumer Price Index",
    "General Price Index - Market",
    "General Price Index - Domestic Availability",
    "Broad National Consumer Price Index 15",
    "Broad National Consumer Price Index Special",
    "SELIC Rate - Target set by COPOM",
    "SELIC Rate - Effective",
    "Interest Rate - CDI (Interbank Deposit Certificate)",
    "Long-Term Interest Rate",
    "Referential Interest Rate",
    "Long-Term Rate",
    "Exchange rate - Free Market - US Dollar (buy)",
    "Exchange rate - Free Market - US Dollar (sell)",
    "Exchange rate - Free Market - Euro (buy)",
    "Exchange rate - Free Market - Euro (sell)",
    "Gross Domestic Product - Volume Quarterly Index",
    "Gross Domestic Product at market prices - Current values",
    "Monthly Gross Domestic Product - Estimate",
    "Gross General Government Debt",
    "Net General Government Debt",
    "Primary Result of General Government",
    "Nominal Result of General Government",
    "International Reserves",
    "Trade Balance - FOB Exports",
    "Trade Balance - FOB Imports",
    "Trade Balance - Net Balance",
    "Current Account - Current Transactions",
    "Unemployment rate - Continuous PNAD",
    "Central Bank Economic Activity Index (IBC-Br)",
    "Central Bank Economic Activity Index seasonally adjusted"
  ),

  description_pt = c(
    "Principal índice de inflação ao consumidor no Brasil, usado para metas de inflação",
    "Índice de preços ao consumidor com abrangência familiar mais restrita",
    "Índice geral de preços calculado pela FGV, inclui matérias-primas",
    "Índice geral de preços com foco na disponibilidade interna",
    "IPCA com coleta na primeira quinzena do mês",
    "IPCA acumulado em trimestre para reajustes contratuais",
    "Taxa básica de juros definida pelo Comitê de Política Monetária (COPOM)",
    "Taxa SELIC efetivamente praticada no mercado",
    "Taxa média de juros dos empréstimos interbancários",
    "Taxa de juros de longo prazo para financiamentos oficiais",
    "Taxa referencial para indexação de contratos",
    "Taxa de longo prazo que substituiu a TJLP",
    "Cotação para compra de dólar americano",
    "Cotação para venda de dólar americano",
    "Cotação para compra de euro",
    "Cotação para venda de euro",
    "Volume do PIB ajustado sazonalmente, em índices",
    "PIB em valores correntes, não ajustado",
    "Estimativa mensal do PIB calculada pelo BCB",
    "Dívida bruta total do governo geral (União, Estados, Municípios)",
    "Dívida líquida do governo geral (bruta menos ativos)",
    "Resultado primário (receitas menos despesas, excluindo juros)",
    "Resultado nominal (incluindo pagamento de juros)",
    "Reservas internacionais em moeda estrangeira",
    "Valor FOB das exportações brasileiras",
    "Valor FOB das importações brasileiras",
    "Saldo da balança comercial (exportações menos importações)",
    "Saldo das transações correntes (comércio, serviços, rendas)",
    "Taxa de desemprego calculada pelo IBGE (PNAD Contínua)",
    "Indicador mensal de atividade econômica do BCB",
    "IBC-Br ajustado sazonalmente"
  ),

  description_en = c(
    "Main consumer inflation index in Brazil, used for inflation targeting",
    "Consumer price index with more restricted family coverage",
    "General price index calculated by FGV, includes raw materials",
    "General price index focused on domestic availability",
    "IPCA with data collection in the first half of the month",
    "IPCA accumulated over a quarter for contractual adjustments",
    "Base interest rate defined by the Monetary Policy Committee (COPOM)",
    "SELIC rate effectively practiced in the market",
    "Average interest rate of interbank loans",
    "Long-term interest rate for official financing",
    "Referential rate for contract indexing",
    "Long-term rate that replaced TJLP",
    "Quote for buying US dollars",
    "Quote for selling US dollars",
    "Quote for buying euros",
    "Quote for selling euros",
    "GDP volume seasonally adjusted, in indices",
    "GDP in current values, not adjusted",
    "Monthly GDP estimate calculated by BCB",
    "Total gross debt of general government (Union, States, Municipalities)",
    "Net debt of general government (gross minus assets)",
    "Primary result (revenues minus expenses, excluding interest)",
    "Nominal result (including interest payments)",
    "International reserves in foreign currency",
    "FOB value of Brazilian exports",
    "FOB value of Brazilian imports",
    "Trade balance (exports minus imports)",
    "Current account balance (trade, services, income)",
    "Unemployment rate calculated by IBGE (Continuous PNAD)",
    "Monthly economic activity indicator from BCB",
    "IBC-Br seasonally adjusted"
  ),

  category_pt = c(
    rep("Inflação", 6),
    rep("Juros e Monetário", 6),
    rep("Câmbio", 4),
    rep("Contas Nacionais", 3),
    rep("Fiscal", 4),
    rep("Setor Externo", 5),
    rep("Emprego e Atividade", 3)
  ),

  category_en = c(
    rep("Inflation", 6),
    rep("Interest Rates and Monetary", 6),
    rep("Exchange Rate", 4),
    rep("National Accounts", 3),
    rep("Fiscal", 4),
    rep("External Sector", 5),
    rep("Employment and Activity", 3)
  ),

  sub_category_pt = c(
    "IPCA", "INPC", "IGP", "IGP", "IPCA", "IPCA",
    "SELIC", "SELIC", "CDI", "Taxas Longas", "Taxas Referenciais", "Taxas Longas",
    "Dólar", "Dólar", "Euro", "Euro",
    "PIB Volume", "PIB Valor", "PIB Mensal",
    "Dívida Pública", "Dívida Pública", "Resultado Fiscal", "Resultado Fiscal",
    "Reservas", "Balança Comercial", "Balança Comercial", "Balança Comercial", "Conta Corrente",
    "Desemprego", "Atividade Econômica", "Atividade Econômica"
  ),

  sub_category_en = c(
    "IPCA", "INPC", "IGP", "IGP", "IPCA", "IPCA",
    "SELIC", "SELIC", "CDI", "Long-Term Rates", "Referential Rates", "Long-Term Rates",
    "US Dollar", "US Dollar", "Euro", "Euro",
    "GDP Volume", "GDP Value", "Monthly GDP",
    "Public Debt", "Public Debt", "Fiscal Result", "Fiscal Result",
    "Reserves", "Trade Balance", "Trade Balance", "Trade Balance", "Current Account",
    "Unemployment", "Economic Activity", "Economic Activity"
  ),

  frequency = c(
    rep("monthly", 6),   # Inflação
    rep("daily", 6),     # Juros
    rep("daily", 4),     # Câmbio
    "quarterly", "quarterly", "monthly",  # PIB
    rep("monthly", 4),   # Fiscal
    "daily", rep("monthly", 4),  # Setor Externo
    rep("monthly", 3)    # Emprego e Atividade
  ),

  unit = c(
    rep("percent", 6),   # Inflação
    rep("percent", 6),   # Juros
    rep("BRL", 4),       # Câmbio
    "index", "BRL", "index",  # PIB
    rep("BRL", 4),       # Fiscal
    "USD", rep("USD", 4), # Setor Externo
    rep("percent", 3)    # Emprego e Atividade
  ),

  seasonally_adjusted = c(
    rep(FALSE, 6),  # Inflação
    rep(FALSE, 6),  # Juros
    rep(FALSE, 4),  # Câmbio
    TRUE, FALSE, TRUE,  # PIB
    rep(FALSE, 4),  # Fiscal
    rep(FALSE, 5),  # Setor Externo
    FALSE, FALSE, TRUE  # Emprego e Atividade
  ),

  start_date = as.Date(c(
    # Inflação
    "1979-12-01", "1979-01-01", "1944-01-01", "1944-01-01", "1991-08-01", "1991-08-01",
    # Juros
    "1986-07-04", "1986-07-04", "1986-07-04", "1995-07-03", "1991-03-01", "2018-01-01",
    # Câmbio
    "1994-07-01", "1994-07-01", "1999-01-01", "1999-01-01",
    # PIB
    "1996-01-01", "1996-01-01", "2003-01-01",
    # Fiscal
    "2006-12-01", "2006-12-01", "2001-12-01", "2001-12-01",
    # Setor Externo
    "1970-01-01", "1989-01-01", "1989-01-01", "1989-01-01", "1995-01-01",
    # Emprego e Atividade
    "2012-03-01", "2003-01-01", "2003-01-01"
  )),

  end_date = as.Date(rep(NA, 31)),

  default_transform = c(
    rep("pct_change", 6),   # Inflação
    rep("none", 6),         # Juros
    rep("log", 4),          # Câmbio
    "pct_change", "pct_change", "pct_change",  # PIB
    rep("pct_change", 4),   # Fiscal
    "log", rep("pct_change", 4),  # Setor Externo
    "none", "pct_change", "pct_change"  # Emprego e Atividade
  ),

  suggested_scale = c(
    rep("linear", 6),   # Inflação
    rep("linear", 6),   # Juros
    rep("log", 4),      # Câmbio
    rep("linear", 3),   # PIB
    rep("linear", 4),   # Fiscal
    "log", rep("linear", 4),  # Setor Externo
    rep("linear", 3)    # Emprego e Atividade
  ),

  notes_pt = c(
    # Inflação
    "Usado para regime de metas de inflação",
    "Abrangência familiar mais restrita que IPCA",
    "Inclui preços de matérias-primas e atacado",
    "Versão com foco interno do IGP",
    "Coleta na primeira quinzena",
    "Para reajustes trimestrais",

    # Juros
    "Meta definida pelo COPOM a cada 45 dias",
    "Taxa efetiva do mercado interbancário",
    "Média das taxas de empréstimos entre bancos",
    "Para financiamentos de longo prazo do BNDES",
    "Indexação de poupança e contratos",
    "Substituiu TJLP em 2018",

    # Câmbio
    "Taxa para compra de dólar",
    "Taxa para venda de dólar",
    "Taxa para compra de euro",
    "Taxa para venda de euro",

    # PIB
    "Volume ajustado sazonalmente",
    "Valores correntes",
    "Estimativa mensal do BCB",

    # Fiscal
    "Inclui União, Estados e Municípios",
    "Dívida bruta menos ativos financeiros",
    "Exclui pagamento de juros",
    "Inclui pagamento de juros",

    # Setor Externo
    "Inclui ouro e direitos especiais de giro",
    "Valor Free On Board",
    "Valor Free On Board",
    "Exportações menos importações",
    "Inclui balança comercial, serviços e rendas",

    # Emprego e Atividade
    "Dados do IBGE via BCB SGS",
    "Indicador antecedente do PIB",
    "Versão dessazonalizada do IBC-Br"
  ),

  notes_en = c(
    # Inflation
    "Used for inflation targeting regime",
    "More restricted family coverage than IPCA",
    "Includes raw material and wholesale prices",
    "Internal focus version of IGP",
    "Data collection in first half of month",
    "For quarterly adjustments",

    # Interest Rates
    "Target set by COPOM every 45 days",
    "Effective interbank market rate",
    "Average of interbank loan rates",
    "For long-term financing by BNDES",
    "Indexing for savings and contracts",
    "Replaced TJLP in 2018",

    # Exchange Rate
    "Rate for buying dollars",
    "Rate for selling dollars",
    "Rate for buying euros",
    "Rate for selling euros",

    # GDP
    "Volume seasonally adjusted",
    "Current values",
    "Monthly estimate by BCB",

    # Fiscal
    "Includes Union, States and Municipalities",
    "Gross debt minus financial assets",
    "Excludes interest payments",
    "Includes interest payments",

    # External Sector
    "Includes gold and special drawing rights",
    "Free On Board value",
    "Free On Board value",
    "Exports minus imports",
    "Includes trade balance, services and income",

    # Employment and Activity
    "Data from IBGE via BCB SGS",
    "Leading indicator of GDP",
    "Seasonally adjusted version of IBC-Br"
  )
)

# Verificar que todos os vetores têm o mesmo comprimento
cat("Verificando comprimentos (deve ser 31 para todos):\n")
for(col in names(br_available_series)) {
  cat(sprintf("%-20s: %d\n", col, length(br_available_series[[col]])))
}

# Salvar como RDA na pasta data/
usethis::use_data(br_available_series, overwrite = TRUE)

# Criar também como CSV para referência
readr::write_csv(br_available_series, "data-raw/series_data.csv")
