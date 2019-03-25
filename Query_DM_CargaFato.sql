		------------------------
		---CONEXAO COM O DW-----
		------------------------

		USE DM_CodeChallenge
		GO

		------------------------
		--CRIAÇAO DA PROCEDURE--
		------------------------

		CREATE PROC Carga_Fato
		AS

		DECLARE @FINAL DATETIME 
		DECLARE	@INICIAL DATETIME
		
		SELECT  @FINAL = MAX(DATA)
		FROM DM_CodeChallenge.DBO.dimTempo T

		SELECT @INICIAL = MAX(DATA)
			FROM DM_CodeChallenge.DBO.FATO FT
			JOIN DM_CodeChallenge.DBO.DIMTEMPO T ON (FT.Dt_Assinatura=T.IDSK)

		IF @INICIAL IS NULL
		BEGIN
			SELECT @INICIAL = MIN(DATA)
			FROM DM_CodeChallenge.DBO.DIMTEMPO T
		END

		INSERT INTO DM_CodeChallenge.DBO.FATO(
			ID_Produto,
			ID_StepTarifacao,
			ID_Transacao,
			Numero_Tel,
			ID_Assinatura,
			Dt_Assinatura,
			Dt_Cancelamento,
			Dt_Transacao,
			Total_Assinaturas,
			Total_AssinaturasCanceladas,
			Total_AssinaturasAtivas,
			Total_AssinaturasPendentes,
			Total_ReAssinaturas,
			Valor_Transacao )
		SELECT
			P.IDSK AS ID_Produto,
			S.IDSK AS ID_StepTarifacao,
			TR.IDSK AS ID_Transacao,
		   U.IDSK AS Numero_Tel,
		   A.IDSK AS ID_Assinatura,	
			T.IDSK as Dt_Assinatura,
			T.IDSK as Dt_Cancelamento,
			T.IDSK as Dt_Transacao,
			F.Total_Assinaturas,
			F.Total_AssinaturasCanceladas,
			F.Total_AssinaturasAtivas,
			F.Total_AssinaturasPendentes,
			F.Total_ReAssinaturas,
			F.Valor_Transacao
	
		FROM
			DM_CodeChallenge.DBO.STGFATO F

			INNER JOIN DBO.DIMPRODUTO P
			on (F.ID_PRODUTO=P.ID_PRODUTO)	 

			INNER JOIN DBO.DIMPRODUTOPLANOSTEP S
			on (F.ID_PRODUTO=S.ID_PRODUTO AND F.STEP_TRANSACAO=S.STEP_TRANSACAO)

				INNER JOIN DBO.DIMTRANSACAO TR
			on (F.ID_TRANSACAO=TR.ID_TRANSACAO
				-- AND (FN.INICIO <= F.DATA AND (FN.FIM >= F.DATA) or (FN.FIM IS NULL)))

			INNER JOIN DBO.DIMUSUARIO U
			on --(
			F.NUMERO_TEL=U.NUMERO_TEL
				/*AND (C.INICIO <= F.DATA
				AND (C.FIM >= F.DATA) or (C.FIM IS NULL)))*/

				INNER JOIN DBO.DIM_VENDEDOR A
			on --(
			F.ID_ASSINATURA=A.ID_ASSINATURA
			/*	AND (V.INICIO <= F.DATA
				AND (V.FIM >= F.DATA) or (V.FIM IS NULL)))*/

			INNER JOIN DBO.DIMTEMPO T
			ON (CONVERT(VARCHAR, T.Dt_Assinatura,102) = CONVERT(VARCHAR,
			F.DATA,102))
			--WHERE F.DATA > @INICIAL AND F.DATA < @FINAL
			WHERE F.DATA BETWEEN @INICIAL AND @FINAL
GO










