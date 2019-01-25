DECLARE @fullobj VARCHAR(MAX)

SET @fullobj = '22695#1#2019-01-24#20:00#123#1#0|22695#1#2019-01-24#21:00#423#1#1|22695#1#2019-01-24#22:00#223#0#1|22695#1#2019-01-15#16:00#22#1#1'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#aux', 'U') IS NOT NULL
    DROP TABLE #aux; 
IF OBJECT_ID('tempdb.dbo.#deeper', 'U') IS NOT NULL
    DROP TABLE #deeper; 
IF OBJECT_ID('tempdb.dbo.#deeper2', 'U') IS NOT NULL
    DROP TABLE #deeper2; 

CREATE TABLE #aux (id UNIQUEIDENTIFIER, id_evento INT, codPeca INT, codSala INT, presentationDate DATETIME, presentationTime VARCHAR(5), amount INT, allowweb BIT, allowticketoffice BIT, hasAnother BIT, numBordero INT, codApresentacaoInsert INT);

CREATE TABLE #deeper (id UNIQUEIDENTIFIER, obj VARCHAR(MAX));
CREATE TABLE #deeper2 (id INT, obj VARCHAR(MAX));

INSERT #deeper(id, obj)
	SELECT
		NEWID()
		,Item
	FROM dbo.splitString(@fullobj, '|');

WHILE (exists (SELECT 1 FROM #deeper))
BEGIN
	DECLARE @id UNIQUEIDENTIFIER
			,@obj VARCHAR(MAX)
	SELECT @id=id
			,@obj=obj
	FROM #deeper

	INSERT INTO #deeper2 (id, obj)
		SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS RowNumber,* FROM dbo.splitString(@obj, '#') ;

			--1                --2              --3                            --4                              --5             --6               --7
	DECLARE @id_evento_loop INT,@codSala_loop INT,@presentationDate_loop DATETIME,@presentationTime_loop VARCHAR(5),@amount_loop INT,@allowweb_loop BIT,@allowticketoffice_loop BIT;

	SELECT @id_evento_loop = obj FROM #deeper2 WHERE id=1
	SELECT @codSala_loop = obj FROM #deeper2 WHERE id=2
	SELECT @presentationDate_loop = obj FROM #deeper2 WHERE id=3
	SELECT @presentationTime_loop = obj FROM #deeper2 WHERE id=4
	SELECT @amount_loop = obj FROM #deeper2 WHERE id=5
	SELECT @allowweb_loop = obj FROM #deeper2 WHERE id=6
	SELECT @allowticketoffice_loop = obj FROM #deeper2 WHERE id=7
	INSERT INTO #aux (id,id_evento,codPeca,codSala,presentationDate,presentationTime,amount,allowweb,allowticketoffice, hasAnother,numBordero,codApresentacaoInsert)
		SELECT 	NEWID()
				,@id_evento_loop
				,0
				,@codSala_loop
				,@presentationDate_loop
				,@presentationTime_loop
				,@amount_loop
				,@allowweb_loop
				,@allowticketoffice_loop
				,0
				,NULL
				,0

	DELETE FROM #deeper WHERE id=@id
END

DECLARE @codPeca INT
SELECT TOP 1 @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=(SELECT TOP 1 id_evento FROM #aux)

UPDATE #aux SET codPeca=@codPeca

UPDATE d
SET 
	d.hasAnother = 1
FROM #aux d
INNER JOIN tabApresentacao a ON d.codSala=a.CodSala AND d.presentationTime=a.HorSessao COLLATE SQL_Latin1_General_CP1_CI_AS AND d.presentationDate=a.DatApresentacao
WHERE a.DatApresentacao>=GETDATE();

DECLARE @hasError BIT = 0
		,@msg VARCHAR(MAX);

SELECT @hasError=1 FROM #aux WHERE hasAnother=1

IF @hasError = 1
BEGIN
	DECLARE @evento VARCHAR(8000)
			,@data VARCHAR(100)

	SELECT TOP 1 
		@evento=p.NomPeca
		,@data=CONVERT(VARCHAR(10), DatApresentacao, 103) + ' as ' + HorSessao
	FROM #aux aux
	INNER JOIN tabApresentacao a ON aux.codSala=a.CodSala AND aux.presentationTime=a.HorSessao COLLATE SQL_Latin1_General_CP1_CI_AS AND aux.presentationDate=a.DatApresentacao
	INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
	WHERE 
		aux.hasAnother=1

	SELECT 0 success
			,'Já existe apresentação ('+@evento+') na data de '+@data
	RETURN;
END

UPDATE d
SET d.numBordero = RowNumber
FROM #aux d
INNER JOIN 
(SELECT 
	ROW_NUMBER() OVER (ORDER BY aux.presentationDate, aux.presentationTime) AS RowNumber
	,aux.id
FROM #aux aux) t ON d.id=t.id

DECLARE @maxNumBordero INT = 0

SELECT @maxNumBordero = MAX(NumBordero)+1 FROM tabApresentacao WHERE CodSala=(SELECT TOP 1 codSala FROM #aux)

UPDATE #aux SET numBordero=numBordero+@maxNumBordero

DECLARE @lastcodApresetancao INT

SELECT @lastcodapresetancao=MAX(codApresentacao) FROM tabApresentacao

-- INSERT INTO tabApresentacao (codApresentacao,DatApresentacao,CodPeca
-- 	,CodSala,HorSessao,ValPeca
-- 	,NumBordero,StaAtivoWeb,StaAtivoBilheteria)

SELECT 
	@lastcodapresetancao+ROW_NUMBER() OVER (ORDER BY a.presentationDate, a.presentationTime) AS RowNumber
	,a.presentationDate
	,a.codPeca
	,a.codSala
	,a.presentationTime
	,(CONVERT(MONEY,a.amount)/CONVERT(MONEY,100))
	,a.numBordero
	,(CASE WHEN a.allowweb = 1 THEN 'S' ELSE 'N' END)
	,(CASE WHEN a.allowticketoffice = 1 THEN 'S' ELSE 'N' END)
FROM #aux a

-- select * from tabApresentacao
-- sp_help tabApresentacao
-- VALUES (
-- 	@CodApresentacao
-- 	,@DatApresentacao
-- 	,@CodPeca
-- 	,@CodSala
-- 	,@HorSessao
-- 	,@ValPeca
-- 	,@NumBordero
-- 	,@StaAtivoWeb
-- 	,@StaAtivoBilheteria
-- 	)

-- SELECT
-- *
-- FROM #aux a


SET NOCOUNT OFF;


return;

-- DECLARE @DatApresentacao DATETIME
-- 	,@CodPeca INT
-- 	,@CodSala INT
-- 	,@HorSessao VARCHAR(5)
-- 	,@ValPeca MONEY 
-- 	,@StaAtivoWeb VARCHAR(1)
-- 	,@StaAtivoBilheteria VARCHAR(1)

-- DECLARE @CodApresentacao INT
-- 	,@NumBordero INT
-- 	,@DatAprCompleta SMALLDATETIME

-- SET NOCOUNT ON

-- SELECT @DatAprCompleta = CONVERT(SMALLDATETIME, (convert(VARCHAR(10), @DatApresentacao, 112) + ' ' + @HorSessao))

-- IF EXISTS (
-- 		SELECT 1
-- 		FROM tabApresentacao
-- 		WHERE (CodSala = @CodSala)
-- 			AND (CONVERT(SMALLDATETIME, (CONVERT(VARCHAR(10), DatApresentacao, 112) + ' ' + HorSessao)) = @DatAprCompleta)
-- 		)
-- BEGIN
-- 	RAISERROR (
-- 			'Ja existe uma apresentacao para esta data/hora'
-- 			,16
-- 			,1
-- 			)

-- 	RETURN
-- END

-- SELECT @NumBordero = ISNULL((MAX(NumBordero) + 1), 1)
-- FROM tabApresentacao
-- WHERE (
-- 		(CodSala = @CodSala)
-- 		AND (CodPeca = @CodPeca)
-- 		AND (CONVERT(SMALLDATETIME, (CONVERT(VARCHAR(10), DatApresentacao, 112) + ' ' + HorSessao)) < @DatAprCompleta)
-- 		)

-- UPDATE tabApresentacao
-- SET NumBordero = (NumBordero + 1)
-- WHERE (@NumBordero IS NOT NULL)
-- 	AND (CodSala = @CodSala)
-- 	AND (CodPeca = @CodPeca)
-- 	AND (CONVERT(SMALLDATETIME, (CONVERT(VARCHAR(10), DatApresentacao, 112) + ' ' + HorSessao)) > @DatAprCompleta)

-- SELECT @CodApresentacao = ISNULL((
-- 			SELECT MAX(CodApresentacao)
-- 			FROM tabApresentacao
-- 			) + 1, 0)

-- SET NOCOUNT OFF

-- INSERT INTO tabApresentacao (
-- 	CodApresentacao
-- 	,DatApresentacao
-- 	,CodPeca
-- 	,CodSala
-- 	,HorSessao
-- 	,ValPeca
-- 	,NumBordero
-- 	,StaAtivoWeb
-- 	,StaAtivoBilheteria
-- 	)
-- VALUES (
-- 	@CodApresentacao
-- 	,@DatApresentacao
-- 	,@CodPeca
-- 	,@CodSala
-- 	,@HorSessao
-- 	,@ValPeca
-- 	,@NumBordero
-- 	,@StaAtivoWeb
-- 	,@StaAtivoBilheteria
-- 	)