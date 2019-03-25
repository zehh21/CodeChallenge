USE RES_CodeChallenge
GO

SELECT Numero_Tel, COUNT(*)
FROM tblAssinatura 
GROUP BY Numero_Tel HAVING COUNT(*)>1

SELECT * FROM tblAssinatura
WHERE Numero_Tel='11012345688'
ORDER BY Dt_Assinatura, ID_Produto
GO

SELECT ID_Assinatura, Dt_Transacao_MaisRecente, DATEDIFF(DAY, Dt_Transacao_MaisRecente, GETDATE()) AS Qtd_Dias_Transacao_MaisRecente
FROM (
	SELECT A.ID_Assinatura AS ID_Assinatura, T.Dt_Transacao AS Dt_Transacao_MaisRecente,
		ROW_NUMBER() OVER(PARTITION BY A.ID_Assinatura ORDER BY T.Dt_Transacao DESC) AS RN
	FROM tblAssinatura A
	LEFT JOIN tblTransacao T ON A.ID_Assinatura = T.ID_Assinatura
	WHERE A.Status_Assinatura = 1
	) SUBQ
WHERE RN=1 
	AND Dt_Transacao_MaisRecente IS NOT NULL -- os casos com data NULL săo registros que apesar de estarem com assinatura ativa, năo possuem transaçăo (removidos)
	AND DATEDIFF(DAY, Dt_Transacao_MaisRecente, GETDATE()) > 30

	SELECT * FROM tblAssinatura WHERE Numero_Tel='11012345688' ORDER BY Dt_Assinatura, Dt_Cancelamento
	SELECT * FROM tblTransacao WHERE ID_Assinatura IN (8170,3468) ORDER BY Numero_Tel, Dt_Transacao, ID_Assinatura, ID_Produto, Step_Tarifacao



SELECT * FROM tblAssinatura ORDER BY Numero_Tel
SELECT * FROM tblProduto
SELECT * FROM tblProdutoPlanoStep
SELECT * FROM tblTransacao

SELECT COUNT(DISTINCT ID_Assinatura) FROM tblAssinatura
SELECT COUNT(DISTINCT ID_Assinatura) FROM tblAssinatura WHERE Status_Assinatura=0
SELECT COUNT(DISTINCT ID_Assinatura) FROM tblAssinatura WHERE Status_Assinatura=1
SELECT COUNT(DISTINCT ID_Assinatura) FROM tblTransacao

SELECT ID_Assinatura, Dt_Transacao_MaisRecente, DATEDIFF(DAY, Dt_Transacao_MaisRecente, GETDATE()) AS Qtd_Dias_Transacao_MaisRecente
FROM (
	SELECT A.ID_Assinatura AS ID_Assinatura, T.Dt_Transacao AS Dt_Transacao_MaisRecente,
		ROW_NUMBER() OVER(PARTITION BY A.ID_Assinatura ORDER BY T.Dt_Transacao DESC) AS RN
	FROM tblAssinatura A
	LEFT JOIN tblTransacao T ON A.ID_Assinatura = T.ID_Assinatura
	WHERE A.Status_Assinatura = 1
	) SUBQ
WHERE RN=1 
	--AND Dt_Transacao_MaisRecente IS NOT NULL -- os casos com data NULL săo registros que apesar de estarem com assinatura ativa, năo possuem transaçăo (removidos)
	AND DATEDIFF(DAY, Dt_Transacao_MaisRecente, GETDATE()) > 30