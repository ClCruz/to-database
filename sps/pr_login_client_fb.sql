ALTER PROCEDURE dbo.pr_login_client_fb (@fb VARCHAR(1000), @email VARCHAR(1000), @uniquename VARCHAR(100))

AS

SET NOCOUNT ON;

DECLARE @hasFB BIT = 0
        ,@hasemail BIT = 0

SELECT @hasFB = 1 FROM CI_MIDDLEWAY..mw_cliente cli WHERE cli.token_fb=@fb AND uniquename_partner=@uniquename

SELECT @hasemail = 1 FROM CI_MIDDLEWAY..mw_cliente cli WHERE cli.cd_email_login=@email AND uniquename_partner=@uniquename

IF @hasFB = 0 AND @hasemail =1
BEGIN
    UPDATE CI_MIDDLEWAY..mw_cliente SET token_fb=@fb WHERE cd_email_login=@email AND uniquename_partner=@uniquename
END


SELECT
cli.cd_cpf
,cli.cd_email_login email
,cli.id_cliente id
,cli.cd_password
,cli.token_fb
,cli.cd_rg
,cli.ds_celular
,cli.ds_nome + ' ' + cli.ds_sobrenome [name]
,cli.dt_nascimento
,0 operator
FROM CI_MIDDLEWAY..mw_cliente cli
WHERE cli.token_fb=@fb
AND cli.uniquename_partner=@uniquename