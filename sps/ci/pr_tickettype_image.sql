CREATE PROCEDURE dbo.pr_tickettype_image (@id INT
,@hasImage BIT)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @id != 0
BEGIN
    SELECT @has = 1 FROM tabTipBilhete WHERE CodTipBilhete=@id;
END

IF @has = 1
BEGIN
    UPDATE [dbo].[tabTipBilhete]
    SET [hasImage] = @hasImage
    WHERE CodTipBilhete=@id
END

SELECT 1 success
        ,'Salvo com sucesso' msg