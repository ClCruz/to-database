CREATE PROCEDURE dbo.pr_user_resetpass_validate (@code VARCHAR(1000))

AS

DECLARE @has BIT = 0
        ,@login VARCHAR(100) = ''

SELECT @has=1, @login=cd_email_login FROM CI_MIDDLEWAY..mw_cliente WHERE token_reset=@code

SELECT @has success
        ,'' msg
        ,@login [login]
