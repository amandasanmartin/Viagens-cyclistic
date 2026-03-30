/*  PROJETO DIVVY BIKES - ETAPA 02: LIMPEZA DE DADOS
   Objetivo: Isolar e remover registros perfeitamente duplicados 
   mantendo apenas a primeira ocorrência.*/

USE viagens;
GO

-- 1. Criação da CTE para isolar duplicatas
WITH CTE_Duplicatas AS (
    SELECT 
        ride_id,
        ROW_NUMBER() OVER(
            PARTITION BY ride_id 
            ORDER BY started_at
        ) AS numero_da_linha
    FROM viagens_limpas_v2
)
-- 2. Deleção das cópias
DELETE FROM CTE_Duplicatas
WHERE numero_da_linha > 1;
GO