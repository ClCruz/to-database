ALTER PROCEDURE dbo.pr_ticketoffice_cashregister_open (@id_ticketoffice_user UNIQUEIDENTIFIER, @id_base INT)

AS

-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--         , @id_base INT = 213

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@canOpen BIT = 0

SELECT @has=1 FROM CI_MIDDLEWAY..ticketoffice_cashregister WHERE id_ticketoffice_user=@id_ticketoffice_user AND id_base=@id_base AND isopen=1


IF @has = 1
BEGIN
    SELECT 0 success
            ,1 alreadyopened
            ,'Caixa já aberto' msg
    RETURN;
END

SELECT @canOpen=1 FROM CI_MIDDLEWAY..to_admin_user_base WHERE id_base=@id_base AND id_to_admin_user=@id_ticketoffice_user

IF @canOpen=0
BEGIN
    SELECT 0 success
            ,0 alreadyopened
            ,'Você não tem permissão de abrir caixa.' msg
    RETURN;
END

INSERT INTO CI_MIDDLEWAY..ticketoffice_cashregister(id_base,id_ticketoffice_user,isopen)
SELECT @id_base, @id_ticketoffice_user, 1

SELECT 1 success
        ,0 alreadyopened
        ,'Caixa aberto com sucesso.' msg