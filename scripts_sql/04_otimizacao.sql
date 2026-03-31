/*
   PROJETO DIVVY BIKES - ETAPA 04: OTIMIZAÇÃO DE PERFORMANCE
   Objetivo: Criação de índices estruturais para acelerar consultas e 
   atualizações do dashboard no Power BI. */

USE viagens;
GO

CREATE INDEX IDX_Nome_Estacao ON dim_estacoes(nome_estacao);
GO

CREATE INDEX IDX_Tipo_Membro ON dim_usuarios(tipo_membro);
GO

CREATE INDEX IDX_Tipo_Bike ON dim_bikes(tipo_bike);
GO
