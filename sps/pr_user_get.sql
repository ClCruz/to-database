ALTER PROCEDURE dbo.pr_user_get (@token VARCHAR(100))

AS

-- DECLARE @token VARCHAR(100) = 'a9e3d94826820fd5e27d780b8b04f0f3d100ea71'

SELECT
cli.ds_nome
,cli.ds_sobrenome
,(CONVERT(VARCHAR(10),cli.dt_nascimento,103)) dt_nascimento
,cli.in_sexo
,cli.cd_email_login
,cli.cd_cpf
,cli.cd_rg
,cli.ds_ddd_celular
,cli.ds_celular
,cli.cd_cep
,cli.id_estado
,cli.ds_cidade
,cli.ds_bairro
,cli.ds_endereco
,cli.nr_endereco
,cli.ds_compl_endereco
,cli.in_recebe_info
,(CASE WHEN cli.token_fb IS NULL OR cli.token_fb = '' THEN 0 ELSE 1 END) isfb
FROM CI_MIDDLEWAY..mw_cliente cli
WHERE cli.token=@token