CREATE PROCEDURE dbo.pr_tickettype_save_old (@id INT
,@id_base INT
,@allpartner BIT)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0


IF @id != 0
BEGIN
    SELECT @has = 1 FROM tabTipBilhete WHERE CodTipBilhete=@id;
END

IF @has = 1
BEGIN
    UPDATE [dbo].[tabTipBilhete]
    SET [allpartner] = @allpartner
    WHERE CodTipBilhete=@id
END

IF @allpartner = 1
BEGIN
    UPDATE CI_MIDDLEWAY..tickettype_partner SET active=0 WHERE CodTipBilhete=@id AND id_base=@id_base
END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,DB_NAME() directoryname
        ,@id id
