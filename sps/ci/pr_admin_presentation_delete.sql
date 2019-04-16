CREATE PROCEDURE dbo.pr_admin_presentation_delete (@codApresentacao INT)

AS

SET NOCOUNT ON;

DECLARE @hasT BIT = 0
        ,@hasV BIT = 0
        ,@hasR BIT = 0

SELECT @hasT = 1 FROM tabLugSala WHERE CodApresentacao=@codApresentacao AND StaCadeira='T'
SELECT @hasR = 1 FROM tabLugSala WHERE CodApresentacao=@codApresentacao AND StaCadeira='R'
SELECT @hasV = 1 FROM tabLugSala WHERE CodApresentacao=@codApresentacao AND StaCadeira='V'

IF @hasV = 1
BEGIN
	SELECT 0 success
			,'Já existem vendas para essa apresentação.' msg
	RETURN;
END
IF @hasR = 1
BEGIN
	SELECT 0 success
			,'Já existem reservas para essa apresentação.' msg
	RETURN;
END
IF @hasT = 1
BEGIN
	SELECT 0 success
			,'Existem pessoas interagindo com essa apresentação.' msg
	RETURN;
END

DECLARE @codPeca INT
        ,@id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT @codPeca=CodPeca FROM tabApresentacao WHERE CodApresentacao=@codApresentacao

BEGIN TRY

  BEGIN TRANSACTION aremove


    DELETE d
    FROM CI_MIDDLEWAY..mw_apresentacao a
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete d ON a.id_apresentacao=d.id_apresentacao
    INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.id_evento=e.id_evento
    WHERE e.id_base=@id_base
    AND a.CodApresentacao=@codApresentacao
    AND e.CodPeca=@codPeca

    DELETE d
    FROM CI_MIDDLEWAY..mw_apresentacao d
    INNER JOIN CI_MIDDLEWAY..mw_evento e ON d.id_evento=e.id_evento
    WHERE e.id_base=@id_base
    AND d.CodApresentacao=@codApresentacao
    AND e.CodPeca=@codPeca

    DELETE FROM tabApresentacao WHERE CodApresentacao=@codApresentacao

    DECLARE @dateStart DATETIME
            ,@dateEnd DATETIME
            ,@uniqueValPeca DECIMAL(12,2)

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
    ,'Removido com sucesso.' msg

  COMMIT TRANSACTION aremove
END TRY
BEGIN CATCH 
  IF (@@TRANCOUNT > 0)
   BEGIN
      ROLLBACK TRANSACTION aremove
   END 
    SELECT
        0 success,
        ERROR_MESSAGE() msg,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH