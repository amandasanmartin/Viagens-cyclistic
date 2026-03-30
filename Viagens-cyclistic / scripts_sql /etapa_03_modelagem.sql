/* 
   PROJETO DIVVY BIKES - ETAPA 03: MODELAGEM E STAR SCHEMA
   Objetivo: Criação das dimensões, tratamento de regras de negócio (Ponto Livre)
   e consolidação da Tabela Fato usando processamento em lotes. */

USE viagens;
GO


-- 1. CRIAÇÃO DAS TABELAS DIMENSÃO


-- Dimensão Bikes
DROP TABLE IF EXISTS dim_bikes;
CREATE TABLE dim_bikes(
    id_bike INT IDENTITY(1,1) PRIMARY KEY,
    tipo_bike VARCHAR(50)
);

INSERT INTO dim_bikes(tipo_bike)
SELECT DISTINCT rideable_type
FROM dbo.viagens_limpas_v2;
GO

-- Dimensão Usuários
DROP TABLE IF EXISTS dim_usuarios;
CREATE TABLE dim_usuarios(
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,
    tipo_membro VARCHAR(50)
);

INSERT INTO dim_usuarios(tipo_membro)
SELECT DISTINCT member_casual
FROM dbo.viagens_limpas_v2;
GO

-- Dimensão Estações
DROP TABLE IF EXISTS dim_estacoes;
CREATE TABLE dim_estacoes(
    id_estacao INT IDENTITY(1,1) PRIMARY KEY,
    nome_estacao VARCHAR(255), 
    latitude DECIMAL(9,6), 
    longitude DECIMAL(9,6)
);
GO

-- Empilha origens e destinos e consolida coordenadas
WITH TodasAsEstacoes AS (
    SELECT start_station_name AS nome_estacao, start_lat AS lat, start_lng AS lng
    FROM dbo.viagens_limpas_v2
    WHERE start_station_name IS NOT NULL
    
    UNION ALL
    
    SELECT end_station_name AS nome_estacao, end_lat AS lat, end_lng AS lng
    FROM dbo.viagens_limpas_v2
    WHERE end_station_name IS NOT NULL
)
INSERT INTO dim_estacoes (nome_estacao, latitude, longitude)
SELECT 
    nome_estacao, 
    AVG(lat) AS latitude, 
    AVG(lng) AS longitude
FROM TodasAsEstacoes
GROUP BY nome_estacao;
GO

-- 2. CRIAÇÃO DA ESTAÇÃO DE PONTO LIVRE
SET IDENTITY_INSERT dim_estacoes ON;
GO

INSERT INTO dim_estacoes (id_estacao, nome_estacao, latitude, longitude)
VALUES (0, 'Fora de Estação (Ponto Livre)', NULL, NULL);
GO

SET IDENTITY_INSERT dim_estacoes OFF;
GO


-- 3. CRIAÇÃO E CARGA DA TABELA FATO (COM LOOP DE PROCESSAMENTO)
DROP TABLE IF EXISTS fato_viagens;
GO

CREATE TABLE fato_viagens (
    ride_id VARCHAR(255),
    started_at DATETIME,
    ended_at DATETIME,
    id_usuario INT,
    id_bike INT,
    id_estacao_origem INT,
    id_estacao_destino INT
);
GO

-- Loop Mês a Mês 
DECLARE @DataAtual DATETIME = '2021-01-01';
DECLARE @DataProximoMes DATETIME;
DECLARE @DataFinal DATETIME = '2026-01-01'; 
DECLARE @DataTexto VARCHAR(20); 

WHILE @DataAtual < @DataFinal
BEGIN
    SET @DataProximoMes = DATEADD(MONTH, 1, @DataAtual);
    SET @DataTexto = CONVERT(VARCHAR, @DataAtual, 120);
    RAISERROR('Processando viagens do mês: %s', 10, 1, @DataTexto) WITH NOWAIT;

    INSERT INTO fato_viagens (ride_id, started_at, ended_at, id_usuario, id_bike, id_estacao_origem, id_estacao_destino)
    SELECT 
        v.ride_id,
        v.started_at,
        v.ended_at,
        u.id_usuario,
        b.id_bike,
        origem.id_estacao AS id_estacao_origem,
        destino.id_estacao AS id_estacao_destino
    FROM dbo.viagens_limpas_v2 AS v
    LEFT JOIN dim_usuarios AS u 
        ON v.member_casual = u.tipo_membro
    LEFT JOIN dim_bikes AS b 
        ON v.rideable_type = b.tipo_bike
    LEFT JOIN dim_estacoes AS origem 
        ON v.start_station_name = origem.nome_estacao 
    LEFT JOIN dim_estacoes AS destino 
        ON v.end_station_name = destino.nome_estacao
    WHERE v.started_at >= @DataAtual AND v.started_at < @DataProximoMes;

    SET @DataAtual = @DataProximoMes;
END;
GO

-- 4. Atualização de nulos
-- Origem
UPDATE f
SET f.id_estacao_origem = 0
FROM fato_viagens f
INNER JOIN dim_bikes b ON f.id_bike = b.id_bike
WHERE f.id_estacao_origem IS NULL
  AND b.tipo_bike IN ('electric_bike', 'electric_scooter', 'scooter');
GO

-- Destino
UPDATE f
SET f.id_estacao_destino = 0
FROM fato_viagens f
INNER JOIN dim_bikes b ON f.id_bike = b.id_bike
WHERE f.id_estacao_destino IS NULL
  AND b.tipo_bike IN ('electric_bike', 'electric_scooter', 'scooter');
GO
