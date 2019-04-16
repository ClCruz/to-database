/*
exec sp_executesql N'EXEC pr_admin_presentation_add @P1',N'@P1 nvarchar(4000)',N'<?xml version="1.0"?>
<root><item codSala="1" codApresentacao="" id_evento="33016" id_base="213" weekdayName="Ter&#xE7;a" weekday="2" ValPeca="1.05" amount="105" HorSessao="22:00" dateStart="2019-04-22" dateEnd="2019-04-26" allowweb="true" allowwebBIT="1" allowticketoffice="true" allowticketofficeBIT="1"/><item codSala="1" codApresentacao="" id_evento="33016" id_base="213" weekdayName="Quarta" weekday="3" ValPeca="1.05" amount="105" HorSessao="22:00" dateStart="2019-04-22" dateEnd="2019-04-26" allowweb="true" allowwebBIT="1" allowticketoffice="true" allowticketofficeBIT="1"/><item codSala="1" codApresentacao="" id_evento="33016" id_base="213" weekdayName="Quinta" weekday="4" ValPeca="1.05" amount="105" HorSessao="22:00" dateStart="2019-04-22" dateEnd="2019-04-26" allowweb="true" allowwebBIT="1" allowticketoffice="true" allowticketofficeBIT="1"/></root>
'
*/

ALTER PROCEDURE dbo.pr_admin_presentation_add (@data XML)

AS


-- DECLARE @data XML = N'<?xml version="1.0"?>
-- <root><item codSala="1" codApresentacao="" id_evento="33016" id_base="213" weekdayName="Ter&#xE7;a" weekday="2" ValPeca="1.05" amount="105" HorSessao="07:00" dateStart="2019-04-16" dateEnd="2019-04-19" allowweb="true" allowwebBIT="1" allowticketoffice="true" allowticketofficeBIT="1"/><item codSala="1" codApresentacao="" id_evento="33016" id_base="213" weekdayName="Quarta" weekday="3" ValPeca="1.05" amount="105" HorSessao="07:00" dateStart="2019-04-16" dateEnd="2019-04-19" allowweb="true" allowwebBIT="1" allowticketoffice="true" allowticketofficeBIT="1"/><item codSala="1" codApresentacao="" id_evento="33016" id_base="213" weekdayName="Quinta" weekday="4" ValPeca="1.05" amount="105" HorSessao="07:00" dateStart="2019-04-16" dateEnd="2019-04-19" allowweb="true" allowwebBIT="1" allowticketoffice="true" allowticketofficeBIT="1"/></root>
-- '

SET NOCOUNT ON;

SET DATEFIRST 1;

IF OBJECT_ID('tempdb.dbo.#request', 'U') IS NOT NULL
	DROP TABLE #request; 

IF OBJECT_ID('tempdb.dbo.#toadd', 'U') IS NOT NULL
	DROP TABLE #toadd; 

CREATE TABLE #request (codSala int
	,codApresentacao int
	,id_evento int
	,id_base int
	,weekdayName varchar(1000)
	,[weekday] int
	,ValPeca decimal(18,3)
	,amount int
	,HorSessao varchar(1000)
	,dateStart varchar(1000)
	,dateEnd varchar(1000)
	,allowweb varchar(100)
	,allowwebBIT bit
	,allowticketoffice varchar(100)
	,allowticketofficeBIT bit
	,hasAnother BIT
	,codPeca INT);

CREATE TABLE #toadd (codSala int
	,id_evento int
	,id_base int
	,amount int
	,HorSessao varchar(1000)
	,[date] datetime
	,allowweb bit
	,allowticketoffice bit
	,hasAnother BIT
	,isSelected BIT
	,codPeca INT
	,numBordero INT
	,id UNIQUEIDENTIFIER
	,idint INT);


INSERT INTO #request (codSala, codApresentacao, id_evento, id_base, weekdayName, [weekday], ValPeca, amount, HorSessao, dateStart, dateEnd, allowweb, allowwebBIT, allowticketoffice, allowticketofficeBIT, hasAnother, codPeca)
SELECT
	c.value('@codSala','int') codSala
	,c.value('@codApresentacao','int') codApresentacao
	,c.value('@id_evento','int') id_evento
	,c.value('@id_base','int') id_base
	,c.value('@weekdayName','varchar(1000)') weekdayName
	,c.value('@weekday','int') weekday
	,c.value('@ValPeca','decimal(18,3)') ValPeca
	,c.value('@amount','int') amount
	,c.value('@HorSessao','varchar(1000)') HorSessao
	,c.value('@dateStart','varchar(1000)') dateStart
	,c.value('@dateEnd','varchar(1000)') dateEnd
	,c.value('@allowweb','varchar(100)') allowweb
	,c.value('@allowwebBIT','bit') allowwebBIT
	,c.value('@allowticketoffice','varchar(100)') allowticketoffice
	,c.value('@allowticketofficeBIT','bit') allowticketofficeBIT
	,0
	,0
FROM @data.nodes('root/item/.') T(c)


DECLARE @codPeca INT
		,@uniqueValPeca DECIMAL(12,2)
SELECT TOP 1 @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=(SELECT TOP 1 id_evento FROM #request)

UPDATE #request SET codPeca=@codPeca

DECLARE @dateStart DATETIME
		,@dateEnd DATETIME
		,@howmany INT = 0

SELECT TOP 1 @dateStart = datestart, @dateEnd = dateEnd FROM #request

SET @howmany = DATEDIFF(DAY, @dateStart, @dateEnd)+1


INSERT INTO #toadd (codSala
	,id_evento
	,id_base
	,amount
	,HorSessao
	,[date]
	,allowweb
	,allowticketoffice
	,hasAnother
	,isSelected
	,codPeca
	,id
	,idint)
SELECT r.codSala, r.id_evento, r.id_base, r.amount, r.HorSessao, t.[date], r.allowwebBIT, r.allowticketofficeBIT, r.hasAnother, 0, r.codPeca, NEWID(), ROW_NUMBER() OVER(ORDER BY (Select 0))
FROM (SELECT TOP (@howmany) DATEADD(day, n-1, CONVERT(DATETIME,@dateStart)) [date],DATEPART(weekday,DATEADD(day, n-1, CONVERT(DATETIME,@dateStart))) [weekday]
FROM CI_MIDDLEWAY..loop_numbers 
ORDER BY n) as t
LEFT JOIN #request r ON t.weekday=r.weekday
WHERE r.codSala IS NOT NULL


UPDATE d
SET 
	d.hasAnother = 1
FROM #toadd d
INNER JOIN tabApresentacao a ON d.codSala=a.CodSala AND d.HorSessao=a.HorSessao COLLATE SQL_Latin1_General_CP1_CI_AS AND d.[date]=a.DatApresentacao
WHERE a.DatApresentacao>=GETDATE();



DECLARE @hasError BIT = 0
		,@msg VARCHAR(MAX);

SELECT @hasError=1 FROM #toadd WHERE hasAnother=1

IF @hasError = 1
BEGIN
	DECLARE @evento_error VARCHAR(8000)
			,@data_error VARCHAR(100)

	SELECT TOP 1 
		@evento_error=p.NomPeca
		,@data_error=CONVERT(VARCHAR(10), DatApresentacao, 103) + ' as ' + a.HorSessao
	FROM #toadd aux
	INNER JOIN tabApresentacao a ON aux.codSala=a.CodSala AND aux.HorSessao=a.HorSessao COLLATE SQL_Latin1_General_CP1_CI_AS AND aux.[date]=a.DatApresentacao
	INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
	WHERE 
		aux.hasAnother=1

	SELECT 0 success
			,'Já existe apresentação ('+@evento_error+') na data de '+@data_error
	RETURN;
END

UPDATE d
SET d.numBordero = RowNumber
FROM #toadd d
INNER JOIN 
(SELECT 
	ROW_NUMBER() OVER (ORDER BY aux.date, aux.HorSessao) AS RowNumber
	,aux.id
FROM #toadd aux) t ON d.id=t.id


DECLARE @maxNumBordero INT = 0

SELECT @maxNumBordero = MAX(a.NumBordero)+1 
FROM tabApresentacao a
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN #toadd ta ON ta.id_base=e.id_base AND e.id_evento=ta.id_evento AND a.CodSala=ta.codSala
-- WHERE CodSala=(SELECT TOP 1 codSala FROM #toadd)

IF @maxNumBordero IS NULL
	SET @maxNumBordero = 0

UPDATE #toadd SET numBordero=numBordero+@maxNumBordero


DECLARE @codApresentacaoCurrent INT

SELECT @codApresentacaoCurrent=MAX(codApresentacao) FROM tabApresentacao

INSERT INTO tabApresentacao (codApresentacao,DatApresentacao,CodPeca,CodSala,HorSessao,ValPeca,NumBordero,StaAtivoWeb,StaAtivoBilheteria)
SELECT 
	@codApresentacaoCurrent+idint
	,a.[date]
	,a.codPeca
	,a.codSala
	,a.HorSessao
	,(CONVERT(MONEY,a.amount)/CONVERT(MONEY,100)) amount
	,a.numBordero
	,(CASE WHEN a.allowweb = 1 THEN 'S' ELSE 'N' END) allowweb
	,(CASE WHEN a.allowticketoffice = 1 THEN 'S' ELSE 'N' END) allowticketoffice
FROM #toadd a

SELECT @dateStart = MIN(a.DatApresentacao)
FROM tabApresentacao a
WHERE a.CodPeca=@codPeca
SELECT @dateEnd = MAX(a.DatApresentacao)
FROM tabApresentacao a
WHERE a.CodPeca=@codPeca

SELECT @uniqueValPeca = MIN(a.ValPeca)
FROM tabApresentacao a
WHERE a.CodPeca=@codPeca

UPDATE tabPeca SET DatIniPeca = @dateStart, DatFinPeca=@dateEnd,ValIngresso=@uniqueValPeca WHERE CodPeca=@codPeca

SELECT 1 success
		,'Cadastrado com sucesso.' msg