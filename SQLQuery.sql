
USE RES_CodeChallenge
GO

SELECT * FROM [dbo].[tblAssinatura]
--SELECT * FROM [dbo].[tblDDD]
SELECT * FROM [dbo].[tblProduto]
SELECT * FROM [dbo].[tblProdutoPlanoStep]
SELECT * FROM [dbo].[tblTransacao]
GO

-- Raciocínio para definição de termo 'usuário' (utilizado no enunciado do desafio)
	-- Assumi ID_Assinatura = Usuario
SELECT DDD, SUBSTRING(Numero_Tel,1,2), Numero_Tel
FROM tblAssinatura WHERE DDD <> SUBSTRING(Numero_Tel,1,2) -- verificar se existe inconsistencia entre DDD e Numero_Tel

SELECT ID_Assinatura, count(*)
FROM tblAssinatura GROUP BY ID_Assinatura HAVING COUNT(*)>1 -- verificar se ID_Assinatura e Numero_Tel são únicos
SELECT Numero_Tel, count(*) 
FROM tblAssinatura GROUP BY Numero_Tel HAVING COUNT(*)>1

SELECT *
FROM tblAssinatura WHERE Numero_Tel = '11012345688' -- Numero_Tel não é único

SELECT ID_Assinatura AS Usuario
FROM tblAssinatura -- ID_Assinatura será considerado como 'usuário'
GO

-- Usuários ativos
SELECT ID_Assinatura, Status_Assinatura, Dt_Cancelamento
FROM tblAssinatura
WHERE Status_Assinatura = 1 AND Dt_Cancelamento IS NOT NULL -- Verificar se há inconsistência entre Status_Assinatura e Dt_Cancelamento

SELECT ID_Assinatura, Status_Assinatura, Dt_Cancelamento
FROM tblAssinatura
WHERE Status_Assinatura = 1 -- Regra para definição de usuário ativo
GO

-- Usuários ativos que não são tarifados há mais de 30 dias (considerados somente usuários que já foram tarifados/há alguma transação)
SELECT * FROM tblTransacao

SELECT * FROM tblTransacao
WHERE ID_Assinatura NOT IN (SELECT ID_Assinatura FROM tblAssinatura) -- Verificar se há alguma transação de usuário que não está na tblAssinatura

SELECT A.ID_Assinatura, T.Dt_Transacao FROM tblAssinatura A
LEFT JOIN tblTransacao T ON A.ID_Assinatura = T.ID_Assinatura
WHERE A.Status_Assinatura = 1
ORDER BY A.ID_Assinatura ASC, T.Dt_Transacao DESC -- Transações por usuário (utilizado para conferência)

SELECT ID_Assinatura, Dt_Transacao_MaisRecente, DATEDIFF(DAY, Dt_Transacao_MaisRecente, GETDATE()) AS Qtd_Dias_Transacao_MaisRecente
FROM (
	SELECT A.ID_Assinatura AS ID_Assinatura, T.Dt_Transacao AS Dt_Transacao_MaisRecente,
		ROW_NUMBER() OVER(PARTITION BY A.ID_Assinatura ORDER BY T.Dt_Transacao DESC) AS RN
	FROM tblAssinatura A
	LEFT JOIN tblTransacao T ON A.ID_Assinatura = T.ID_Assinatura
	WHERE A.Status_Assinatura = 1
	) SUBQ
WHERE RN=1 
	AND Dt_Transacao_MaisRecente IS NOT NULL -- os casos com data NULL são registros que apesar de estarem com assinatura ativa, não possuem transação (removidos)
	AND DATEDIFF(DAY, Dt_Transacao_MaisRecente, GETDATE()) > 30

GO



SELECT * FROM tblAssinatura
WHERE Status_Assinatura=1