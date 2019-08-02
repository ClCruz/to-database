
CREATE PROCEDURE dbo.pr_accountingdebittype_event_delete (@id_evento INT
        ,@CodTipDebBordero INT)

AS

-- DECLARE @id_evento INT = 439801  
--         ,@CodTipDebBordero INT = 4


SET NOCOUNT ON;

DECLARE @codPeca INT
        ,@has BIT = 0

SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento
SELECT @has = 1 FROM tabDebBordero WHERE CodTipDebBordero=@CodTipDebBordero AND CodPeca=@codPeca

IF @has = 0
BEGIN
    SELECT 0 success
    ,'Não foi possível encontrar o tipo escolhido.' msg
    RETURN;

END
ELSE
BEGIN
    DELETE FROM tabDebBordero WHERE CodPeca=@codPeca AND CodTipDebBordero=@CodTipDebBordero
    SELECT 1 success
            ,'Removido com sucesso' msg
END