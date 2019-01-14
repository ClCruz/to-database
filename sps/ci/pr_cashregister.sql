ALTER PROCEDURE pr_cashregister (@id UNIQUEIDENTIFIER)
 AS

SET NOCOUNT ON;

DECLARE @codCaixa INT, @codUsuario INT

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()


SELECT TOP 1
    @codCaixa=codCaixa
    ,@codUsuario=codUsuario
FROM CI_MIDDLEWAY..ticketoffice_user_base
WHERE id_ticketoffice_user=@id AND id_base=@id_base
ORDER BY codCaixa DESC;

IF @codCaixa IS NULL
BEGIN
    EXEC pr_ticketoffice_user_add_base @id

    SELECT
        @codCaixa=codCaixa
        ,@codUsuario=codUsuario
    FROM CI_MIDDLEWAY..ticketoffice_user_base
    WHERE id_ticketoffice_user=@id;
END
EXEC SP_MOV_UPD001 @codCaixa, @codUsuario

