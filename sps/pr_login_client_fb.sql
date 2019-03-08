CREATE PROCEDURE dbo.pr_login_client_fb (@fb VARCHAR(1000))

AS

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