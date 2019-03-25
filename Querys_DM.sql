CREATE DATABASE DM_CodeChallenge
GO

USE DM_CodeChallenge
GO

CREATE TABLE dimProduto( 
    ID_SK INT PRIMARY KEY IDENTITY, 
    ID_Produto INT, 
    Inicio DATE, 
    Fim DATE, 
    Nome_Produto VARCHAR(150), 
    Status_Produto BIT
) 
GO 

CREATE TABLE dimProdutoPlanoStep( 
    ID_SK INT PRIMARY KEY IDENTITY, 
	ID_StepTarifacao BIGINT,
    ID_Produto INT, 
	Step_Tarifacao SMALLINT,
    Inicio DATE, 
    Fim DATE, 
    Plano VARCHAR(30)
) 
GO 

CREATE TABLE dimUsuario( 
    Numero_Tel BIGINT PRIMARY KEY, 
    DDD INT, 
	Cidade VARCHAR(150),
    Estado VARCHAR(2), 
    Regiao VARCHAR(12)
) 
GO 

CREATE TABLE dimAssinatura( 
    ID_SK INT PRIMARY KEY IDENTITY, 
    ID_Assinatura BIGINT, 
    Inicio DATE, 
    Fim DATE, 
    Pendente BIT, 
    Status_Assinatura BIT
) 
GO 

CREATE TABLE dimTransacao( 
    ID_SK INT PRIMARY KEY IDENTITY, 
    ID_Transacao BIGINT, 
    Inicio DATE, 
    Fim DATE, 
    Status_Transacao BIT
) 
GO 

CREATE TABLE Fato( 
    ID_Produto INT REFERENCES dimProduto(ID_SK), 
	ID_StepTarifacao INT REFERENCES dimProdutoPlanoStep(ID_SK),
	ID_Transacao INT REFERENCES dimTransacao(ID_SK),
	Numero_Tel BIGINT REFERENCES dimUsuario(Numero_Tel),
	ID_Assinatura INT REFERENCES dimAssinatura(ID_SK),
	Dt_Assinatura INT REFERENCES dimTempo(IDSK),
	Dt_Cancelamento INT REFERENCES dimTempo(IDSK),
	Dt_Transacao INT REFERENCES dimTempo(IDSK),
	Total_Assinaturas INT,
	Total_AssinaturasCanceladas INT,
	Total_AssinaturasAtivas INT,
	Total_AssinaturasPendentes INT,
	Total_ReAssinaturas INT,
	Valor_Transacao NUMERIC(11, 5)
) 
GO

CREATE TABLE dimTempo( 
    IDSK INT PRIMARY KEY IDENTITY, 
    DATA DATE, 
    DIA CHAR(2), 
    DIASEMANA VARCHAR(10), 
    MES CHAR(2), 
    NOMEMES VARCHAR(10), 
    QUARTO TINYINT, 
    NOMEQUARTO VARCHAR(10), 
    ANO CHAR(4), 
	ESTACAOANO VARCHAR(20),
	FIMSEMANA CHAR(3),
	DATACOMPLETA VARCHAR(10)
) 
GO 
-------------------------------
--CARREGANDO A DIMENSÃO TEMPO--
-------------------------------

--EXIBINDO A DATA ATUAL

PRINT CONVERT(VARCHAR,GETDATE(),113) 

--ALTERANDO O INCREMENTO PARA INÍCIO EM 5000
--PARA A POSSIBILIDADE DE DATAS ANTERIORES

DBCC CHECKIDENT (dimTempo, RESEED, 50000) 

--INSERÇÃO DE DADOS NA DIMENSÃO

DECLARE    @DATAINICIO DATETIME 
		 , @DATAFIM DATETIME 
		 , @DATA DATETIME
 		  
PRINT GETDATE() 

		SELECT @DATAINICIO = '1/1/1950' 
			, @DATAFIM = '1/1/2050'

		SELECT @DATA = @DATAINICIO 

WHILE @DATA < @DATAFIM 
 BEGIN 

	INSERT INTO dimTempo 
	( 
		  DATA, 
		  DIA,
		  DIASEMANA, 
		  MES,
		  NOMEMES, 
		  QUARTO,
		  NOMEQUARTO, 
		  ANO 

	) 
	SELECT @DATA AS DATA, DATEPART(DAY,@DATA) AS DIA, 

		 CASE DATEPART(DW, @DATA) 
          
			WHEN 1 THEN 'Domingo'
			WHEN 2 THEN 'Segunda' 
			WHEN 3 THEN 'Terça' 
			WHEN 4 THEN 'Quarta' 
			WHEN 5 THEN 'Quinta' 
			WHEN 6 THEN 'Sexta' 
			WHEN 7 THEN 'Sábado' 
           
		END AS DIASEMANA,

		 DATEPART(MONTH,@DATA) AS MES, 

		 CASE DATENAME(MONTH,@DATA) 
	
			WHEN 'January' THEN 'Janeiro'
			WHEN 'February' THEN 'Fevereiro'
			WHEN 'March' THEN 'Março'
			WHEN 'April' THEN 'Abril'
			WHEN 'May' THEN 'Maio'
			WHEN 'June' THEN 'Junho'
			WHEN 'July' THEN 'Julho'
			WHEN 'August' THEN 'Agosto'
			WHEN 'September' THEN 'Setembro'
			WHEN 'October' THEN 'Outubro'
			WHEN 'November' THEN 'Novembro'
			WHEN 'December' THEN 'Dezembro'

		END AS NOMEMES,
 
		 DATEPART(qq,@DATA) QUARTO, 

		 CASE DATEPART(qq,@DATA) 
			WHEN 1 THEN 'Primeiro' 
			WHEN 2 THEN 'Segundo' 
			WHEN 3 THEN 'Terceiro' 
			WHEN 4 THEN 'Quarto' 
		END AS NOMEQUARTO 
		, DATEPART(YEAR,@DATA) ANO

	SELECT @DATA = DATEADD(dd,1,@DATA)
END

UPDATE dimTempo 
SET DIA = '0' + DIA 
WHERE LEN(DIA) = 1 

UPDATE dimTempo 
SET MES = '0' + MES 
WHERE LEN(MES) = 1 

UPDATE dimTempo 
SET DATACOMPLETA = ANO + MES + DIA 
GO

select * from dimTempo

----------------------------------------------
----------FINS DE SEMANA E ESTAÇÕES-----------
----------------------------------------------

DECLARE C_TEMPO CURSOR FOR	
	SELECT IDSK, DATACOMPLETA, DIASEMANA, ANO FROM dimTempo
DECLARE			
			@ID INT,
			@DATA varchar(10),
			@DIASEMANA VARCHAR(20),
			@ANO CHAR(4),
			@FIMSEMANA CHAR(3),
			@ESTACAO VARCHAR(15)
			
OPEN C_TEMPO
	FETCH NEXT FROM C_TEMPO
	INTO @ID, @DATA, @DIASEMANA, @ANO
WHILE @@FETCH_STATUS = 0
BEGIN
	
			 IF @DIASEMANA in ('Domingo','Sábado') 
				SET @FIMSEMANA = 'Sim'
			 ELSE 
				SET @FIMSEMANA = 'Não'

			--ATUALIZANDO ESTACOES

			IF @DATA BETWEEN CONVERT(CHAR(4),@ano)+'0923' 
			AND CONVERT(CHAR(4),@ANO)+'1220'
				SET @ESTACAO = 'Primavera'

			ELSE IF @DATA BETWEEN CONVERT(CHAR(4),@ano)+'0321' 
			AND CONVERT(CHAR(4),@ANO)+'0620'
				SET @ESTACAO = 'Outono'

			ELSE IF @DATA BETWEEN CONVERT(CHAR(4),@ano)+'0621' 
			AND CONVERT(CHAR(4),@ANO)+'0922'
				SET @ESTACAO = 'Inverno'

			ELSE -- @data between 21/12 e 20/03
				SET @ESTACAO = 'Verão'

			--ATUALIZANDO FINS DE SEMANA

			UPDATE dimTempo SET FIMSEMANA = @FIMSEMANA
			WHERE IDSK = @ID

			--ATUALIZANDO

			UPDATE dimTempo SET ESTACAOANO = @ESTACAO
			WHERE IDSK = @ID

	FETCH NEXT FROM C_TEMPO
	INTO @ID, @DATA, @DIASEMANA, @ANO	
END
CLOSE C_TEMPO
DEALLOCATE C_TEMPO
GO