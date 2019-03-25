
CREATE DATABASE ST_CodeChallenge
GO

USE ST_CodeChallenge
GO

CREATE TABLE stgAssinatura(
	ID_Assinatura BIGINT DEFAULT NULL,
	DDD INT DEFAULT NULL,
	Numero_Tel BIGINT DEFAULT NULL,
	ID_Produto INT DEFAULT NULL,
	Dt_Assinatura DATETIME DEFAULT NULL,
	Pendente BIT DEFAULT NULL,
	Status_Assinatura BIT DEFAULT NULL,
	Dt_Cancelamento DATETIME DEFAULT NULL
)
GO

CREATE TABLE stgDDD(
	DDD INT DEFAULT NULL,
	Cidade VARCHAR(150) DEFAULT NULL,
	Estado VARCHAR(2) DEFAULT NULL,
	Regiao VARCHAR(12) DEFAULT NULL
)
GO

CREATE TABLE stgProduto(
	ID_Produto INT DEFAULT NULL,
	Nome_Produto VARCHAR(150) DEFAULT NULL,
	Status_Produto BIT DEFAULT NULL
)
GO

CREATE TABLE stgProdutoPlanoStep(
	ID_StepTarifacao BIGINT DEFAULT NULL,
	ID_Produto INT DEFAULT NULL,
	Step_Tarifacao SMALLINT DEFAULT NULL,
	Plano VARCHAR(30) DEFAULT NULL,
	Valor_Step NUMERIC(11, 5) DEFAULT NULL
)
GO

CREATE TABLE stgTransacao(
	ID_Transacao BIGINT DEFAULT NULL,
	ID_Assinatura BIGINT DEFAULT NULL,
	DDD INT DEFAULT NULL,
	Numero_Tel BIGINT DEFAULT NULL,
	ID_Produto INT DEFAULT NULL,
	Step_Tarifacao SMALLINT DEFAULT NULL,
	Dt_Transacao DATETIME DEFAULT NULL,
	Status_Transacao BIT DEFAULT NULL,
	Valor NUMERIC(11, 5) DEFAULT NULL
)
GO

CREATE TABLE stgFato(
	Numero_Tel BIGINT DEFAULT NULL,
	ID_Assinatura BIGINT DEFAULT NULL,
	ID_Transacao BIGINT DEFAULT NULL,
	ID_Produto INT DEFAULT NULL,
	Step_Tarifacao SMALLINT DEFAULT NULL,
	Dt_Assinatura DATE DEFAULT NULL,
	Dt_Cancelamento DATE DEFAULT NULL,
	Dt_Transacao DATE DEFAULT NULL,
	Total_Assinaturas INT DEFAULT NULL,
	Total_AssinaturasCanceladas INT DEFAULT NULL,
	Total_AssinaturasAtivas INT DEFAULT NULL,
	Total_AssinaturasPendentes INT DEFAULT NULL,
	Total_ReAssinaturas INT DEFAULT NULL,
	Valor_Transacao NUMERIC(11, 5) DEFAULT NULL
)
GO

USE RS_CodeChallenge
GO

CREATE VIEW VW_stgFato AS
	SELECT
		A.Numero_Tel AS Numero_Tel,
		A.ID_Assinatura AS ID_Assinatura,
		T.ID_Transacao AS ID_Transacao,
		P.ID_Produto AS ID_Produto,
		S.Step_Tarifacao AS Step_Tarifacao,
		A.Dt_Assinatura AS Dt_Assinatura,
		A.Dt_Cancelamento AS Dt_Cancelamento,
		T.Dt_Transacao AS Dt_Transacao,
		A.Status_Assinatura AS Total_Assinaturas,
		CASE A.Status_Assinatura WHEN 0 THEN 1 ELSE 0 END AS Total_AssinaturasCanceladas,
		NULL AS Total_AssinaturasAtivas,
		A.Pendente AS Total_AssinaturasPendentes,
		NULL AS Total_ReAssinaturas,
		T.Valor AS Valor_Transacao
	FROM tblAssinatura A
	INNER JOIN tblDDD D ON D.DDD = A.DDD
	INNER JOIN tblProduto P ON P.ID_Produto = A.ID_Produto
	LEFT JOIN tblTransacao T ON T.ID_Assinatura = A.ID_Assinatura
	LEFT JOIN tblProdutoPlanoStep S ON S.ID_Produto = T.ID_Assinatura AND S.Step_Tarifacao = T.Step_Tarifacao
GO
