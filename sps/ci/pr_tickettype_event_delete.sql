CREATE PROCEDURE dbo.pr_tickettype_event_delete (@id_evento INT
        ,@codTipBilhete INT)

AS

SET NOCOUNT ON;

-- DECLARE @codPeca INT

-- SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

-- DECLARE @has BIT = 0

-- SELECT @has = 1 FROM tabValBilhete WHERE CodTipBilhete=@codTipBilhete AND CodPeca=@codPeca

-- IF @has = 1
-- BEGIN
--     DELETE FROM [dbo].[tabValBilhete]
--     WHERE [CodTipBilhete] = @CodTipBilhete
--     AND [CodPeca] = @CodPeca

--     SELECT 1 success
--             ,'Removido com sucesso' msg
-- END
-- ELSE
-- BEGIN
--     SELECT 0 success
--             ,'Não foi possível achar o registro escolhido' msg
-- END

