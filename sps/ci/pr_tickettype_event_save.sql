CREATE PROCEDURE dbo.pr_tickettype_event_save (@id_evento INT
        ,@codTipBilhete INT
        ,@DatIniDesconto DATETIME
        ,@DatFinDesconto DATETIME)

AS

SET NOCOUNT ON;

DECLARE @codPeca INT

SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

DECLARE @has BIT = 0

SELECT @has = 1 FROM tabValBilhete WHERE CodTipBilhete=@codTipBilhete AND CodPeca=@codPeca

IF @has = 1
BEGIN
    UPDATE [dbo].[tabValBilhete]
    SET [DatIniDesconto] = @DatIniDesconto
        ,[DatFinDesconto] = @DatFinDesconto
    WHERE [CodTipBilhete] = @CodTipBilhete
    AND [CodPeca] = @CodPeca
END
ELSE
BEGIN
INSERT INTO [dbo].[tabValBilhete]
           ([CodTipBilhete]
           ,[CodPeca]
           ,[DatIniDesconto]
           ,[DatFinDesconto])
     VALUES
           (@CodTipBilhete
           ,@CodPeca
           ,@DatIniDesconto
           ,@DatFinDesconto)
END

SELECT 1 success
        ,'Salvo com sucesso' msg