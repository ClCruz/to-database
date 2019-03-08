ALTER PROCEDURE dbo.pr_user_alterpass (@code VARCHAR(1000), @pass VARCHAR(100))

AS

-- DECLARE @code VARCHAR(1000)='11DFB324BB47B4D7CAD783BC7A35196324A71D95060B748998CC7B211292E211D813178BA30AE442FA7770A0E3AA7B0817D37D2823E0B4BF8AA7B0970945A7522'
-- , @pass VARCHAR(100) = '123';


SET NOCOUNT ON;

DECLARE @id INT = NULL
        ,@login VARCHAR(1000)
        ,@name VARCHAR(1000)


SELECT @id = id_cliente, @login = cd_email_login, @name = ds_nome + ' ' + ds_sobrenome FROM CI_MIDDLEWAY..mw_cliente WHERE token_reset=@code

IF @id IS NULL
BEGIN
    SELECT 0 success
        ,@login email
        ,@name [name]
        ,@id id
    RETURN;
END

-- select cd_email_login, cd_password, token_reset from CI_MIDDLEWAY..mw_cliente where id_cliente=100
UPDATE CI_MIDDLEWAY..mw_cliente
    SET cd_password=@pass
        ,token_reset=''
WHERE id_cliente=@id

SELECT 1 success
        ,@login email
        ,@name [name]
        ,@id id

