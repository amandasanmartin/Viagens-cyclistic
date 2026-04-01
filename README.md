# Estudo de Caso: Cyclistic Bike Share (Divvy Bikes)

## Visão Geral
Este projeto é uma análise de dados ponta a ponta baseada no programa de compartilhamento de bicicletas de Chicago (Divvy Bikes). O objetivo principal foi analisar um volume massivo de dados (mais de **17 milhões de viagens** entre 2021 e 2025) para entender como diferentes tipos de clientes utilizam as bicicletas e, a partir disso, gerar insights orientados a dados para estratégias de marketing.

**Ferramentas Utilizadas:**
* **Python (Pandas, Requests):** Extração automatizada de dados via API e consolidação de arquivos CSV em massa.
* **SQL Server (T-SQL):** Armazenamento, limpeza de dados, CTEs, Window Functions e modelagem dimensional.
* **Power BI:** Visualização de dados, modelagem DAX e criação de dashboards interativos.

---

## O Desafio de Negócio
A diretora de marketing da Cyclistic acredita que o sucesso futuro da empresa depende da maximização do número de planos anuais. Portanto, a análise foi guiada pela seguinte pergunta de negócios:
> **"Como os membros anuais e os ciclistas casuais usam as bicicletas da Cyclistic de forma diferente?"**

---

## Arquitetura e Engenharia de Dados
Para suportar o volume de 24 milhões de registros sem perda de performance, uma arquitetura de dados robusta foi desenvolvida:

1. **Extração Automática (Python):** * Scripts desenvolvidos para consumir arquivos `.zip` diretamente do servidor da AWS.
   * Uso da técnica de *chunking* (100.000 linhas por bloco) no Pandas para contornar limitações de memória RAM durante a consolidação de mais de 4 anos de dados.
2. **Transformação e Limpeza (SQL Server):**
   * Importação em massa usando `BULK INSERT`.
   * Remoção de viagens duplicadas e tratamento de valores nulos utilizando `ROW_NUMBER()` e CTEs.
   * **Tratamento de Exceção Geográfica:** Criação de uma regra de negócio que atribui o "Ponto Livre" (ID 0) para bicicletas elétricas estacionadas fora das docas oficiais, garantindo a integridade da análise espacial.
3. **Modelagem de Dados:**
   * Construção de um **Star Schema** (Esquema Estrela), separando os dados em uma Tabela Fato (Viagens) e Tabelas Dimensão (Estações, Usuários, Tempo, Bikes).
   * Aplicação de Índices (`CREATE INDEX`) para otimizar o tempo de carregamento no Power BI.

---

## 📊 Dashboards e Visualização (Power BI)

* ** Devido às limitações da minha máquina foram importados somente 17 milhões de registros para o dashboard

### 1. Dinâmica de Uso
A primeira página do painel foca na volumetria geral e no comportamento temporal dos usuários.

<img width="877" height="488" alt="image" src="https://github.com/user-attachments/assets/612a689a-6fd5-45be-bc80-3fe9ff0f6218" />


**Principais Insights:**
* **Sazonalidade:** O uso de bicicletas atinge o pico durante os meses de verão (junho a setembro), caindo drasticamente no inverno.
* **Dias da Semana:** Membros anuais usam as bicicletas predominantemente em dias úteis (segunda a sexta). Já os usuários casuais têm um salto gigante de uso aos finais de semana (sábados e domingos).
* **Horários de Pico:** A curva de horários dos membros anuais mostra dois picos claros: 8h da manhã e 17h, indicando um comportamento clássico de *comute* (ida e volta do trabalho).

### 2. Análise de Fluxo e Duração
A segunda página mergulha no comportamento geográfico e no tempo gasto nas viagens.

<img width="894" height="483" alt="image" src="https://github.com/user-attachments/assets/df130db0-ce1d-40be-b24b-f96de209926b" />


**Principais Insights:**
* **Duração da Viagem:** Usuários casuais passam quase o dobro do tempo com a bicicleta do que os membros anuais.
* **Rotas Populares:** A estação "Streeter Dr & Grand Ave" é um polo absoluto para usuários casuais, indicando um forte uso voltado para turismo e lazer ao longo da costa.

---

##  Recomendações Estratégicas
Com base nos dados, aqui estão as recomendações para converter usuários casuais em membros anuais:
1. **Campanhas de Verão:** Direcionar o orçamento de marketing pesado para o início da primavera/verão, oferecendo descontos na assinatura anual.
2. **Planos de Fim de Semana:** Criar uma categoria de membro voltada especificamente para uso aos finais de semana, atraindo o grande volume de casuais de sábado e domingo.
3. **Foco Geográfico:** Instalar totens publicitários promovendo a assinatura anual nas estações costeiras e turísticas (como Streeter Dr & Grand Ave).

---

## 📁 Estrutura do Repositório
* `scripts_python/`: Notebooks contendo a rotina de automação e extração via API.
* `scripts_sql/`: Scripts `.sql` organizados em etapas (Exploração, Limpeza, Modelagem Star Schema e Otimização).
* `dashboard/`: Arquivo `.pbit` (Power BI Template) leve para visualização do modelo de dados.

---
*Projeto desenvolvido por Amanda San Martin.*
