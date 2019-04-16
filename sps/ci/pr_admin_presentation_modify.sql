-- exec sp_executesql N'EXEC pr_admin_presentation_modify @P1,@P2,@P3,@P4,@P5',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000)',N'286',N'02:00',N'125',N'0',N'1'

ALTER PROCEDURE dbo.pr_admin_presentation_modify (@codApresentacao INT
                                                ,@HorSessao VARCHAR(50)
                                                ,@amount INT
                                                ,@allowweb BIT
                                                ,@allowticketoffice BIT)

AS
-- '286',N'02:00',N'125',N'0',N'1'
-- DECLARE @codApresentacao INT = 286
--                                                 ,@HorSessao VARCHAR(50) = '02:00'
--                                                 ,@amount INT = 125
--                                                 ,@allowweb BIT = 0
--                                                 ,@allowticketoffice BIT = 1

SET NOCOUNT ON;

DECLARE @dateStart DATETIME
        ,@dateEnd DATETIME
        ,@date DATETIME
        ,@uniqueValPeca DECIMAL(12,2)
        ,@codPeca INT
        ,@codSala INT

SELECT @codPeca=codPeca,@codSala=CodSala,@date=DatApresentacao FROM tabApresentacao WHERE CodApresentacao=@codApresentacao

DECLARE @has BIT = 0
        ,@codPecaHAS INT

SELECT @has = 1, @codPecaHAS=CodPeca FROM tabApresentacao WHERE DatApresentacao=@date AND CodSala=@codSala AND HorSessao=@HorSessao AND CodApresentacao!=@codApresentacao

IF @has = 1
BEGIN
	DECLARE @evento_error VARCHAR(8000)
			,@data_error VARCHAR(100)

	SELECT TOP 1 
		@evento_error=p.NomPeca
		,@data_error=CONVERT(VARCHAR(10), DatApresentacao, 103) + ' as ' + a.HorSessao
	FROM tabApresentacao a
	INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
	WHERE 
		a.CodSala=@codSala AND a.HorSessao = @HorSessao AND a.DatApresentacao=@date
        AND a.CodApresentacao!=@codApresentacao

	SELECT 0 success
			,'Já existe apresentação ('+@evento_error+') na data de '+@data_error msg
	RETURN;
END

UPDATE tabApresentacao
SET HorSessao=@HorSessao
    ,ValPeca=(CAST (@amount AS DECIMAL(19,4)))/100
    ,StaAtivoBilheteria=(CASE WHEN @allowticketoffice = 1 THEN 'S' ELSE 'N' END)
    ,StaAtivoWeb=(CASE WHEN @allowweb = 1 THEN 'S' ELSE 'N' END)
WHERE CodApresentacao=@codApresentacao

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
		,'Alterado com sucesso.' msg