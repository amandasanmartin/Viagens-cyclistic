/* PROJETO DIVVY BIKES - ETAPA 01: EXPLORAÇÃO E QUALIDADE DE DADOS
   Objetivo: Mapear valores nulos, verificar integridade de chaves 
   e identificar registros de teste/manutenção. */

USE viagens;
GO

-- 1. Mapeamento de Valores Nulos Gerais
SELECT 
    SUM(CASE WHEN ride_id IS NULL THEN 1 ELSE 0 END) AS nulos_id,
    SUM(CASE WHEN started_at IS NULL THEN 1 ELSE 0 END) AS nulos_data_inicio,
    SUM(CASE WHEN start_station_name IS NULL THEN 1 ELSE 0 END) AS nulos_estacao_origem,
    SUM(CASE WHEN start_station_id IS NULL THEN 1 ELSE 0 END) AS id_origem,
    SUM(CASE WHEN end_station_id IS NULL THEN 1 ELSE 0 END) AS id_destino,
    SUM(CASE WHEN end_station_name IS NULL THEN 1 ELSE 0 END) AS nulos_estacao_destino,
    SUM(CASE WHEN end_lat IS NULL OR end_lng IS NULL THEN 1 ELSE 0 END) AS nulos_coordenadas_destino,
    SUM(CASE WHEN start_lat IS NULL OR start_lng IS NULL THEN 1 ELSE 0 END) AS nulos_coordenadas_origem,
    SUM(CASE WHEN member_casual IS NULL THEN 1 ELSE 0 END) AS nulos_tipo_usuario
FROM viagens_cyclistic;
GO

-- 2. Mapeamento de Nulos por Tipo de Bike
SELECT 
    rideable_type,
    SUM(CASE WHEN start_station_name IS NULL AND end_station_name IS NULL THEN 1 ELSE 0 END) AS nulas_na_origem_e_destino,
    SUM(CASE WHEN start_station_name IS NULL AND end_station_name IS NOT NULL THEN 1 ELSE 0 END) AS nulas_apenas_origem,
    SUM(CASE WHEN start_station_name IS NOT NULL AND end_station_name IS NULL THEN 1 ELSE 0 END) AS nulas_apenas_destino,
    COUNT(*) AS total_com_algum_nulo
FROM viagens_cyclistic
WHERE start_station_name IS NULL OR end_station_name IS NULL
GROUP BY rideable_type
ORDER BY total_com_algum_nulo DESC;
GO

-- 3. Verificação de Chaves Primárias Duplicadas
SELECT ride_id, COUNT(*) as qnt_repeticoes
FROM viagens_limpas_v2
GROUP BY ride_id
HAVING COUNT(*) > 1;
GO

-- 4. Identificação de Estações de Teste e Manutenção
SELECT DISTINCT start_station_name 
FROM viagens_limpas_v2
WHERE start_station_name LIKE '%test%' 
   OR start_station_name LIKE '%maintenance%';
GO
