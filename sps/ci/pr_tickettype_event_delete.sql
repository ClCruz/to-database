
-- exec sp_executesql N'EXEC pr_tickettype_event_save @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'43980',N'4',N'2019-08-01',N'2019-08-30'
-- exec sp_executesql N'EXEC pr_tickettype_event_delete @P1,@P2',N'@P1 nvarchar(4000),@P2 nvarchar(4000)',N'32962',N'7'
ALTER PROCEDURE dbo.pr_tickettype_event_delete (@id_evento INT
        ,@codTipBilhete INT)

AS

-- DECLARE @id_evento INT = 439801  
--         ,@codTipBilhete INT = 4


SET NOCOUNT ON;

DECLARE @codPeca INT
        ,@has BIT = 0

SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento
SELECT @has = 1 FROM tabValBilhete WHERE CodTipBilhete=@codTipBilhete AND CodPeca=@codPeca

IF @has = 0
BEGIN
    SELECT 0 success
    ,'Não foi possível encontrar o bilhete escolhido.' msg
    RETURN;

END
ELSE
BEGIN
    DELETE FROM tabValBilhete WHERE CodPeca=@codPeca AND CodTipBilhete=@codTipBilhete
    -- SELECT * FROM tabValBilhete WHERE CodPeca=@codPeca AND CodTipBilhete=@codTipBilhete
    SELECT 1 success
            ,'Removido com sucesso' msg
END