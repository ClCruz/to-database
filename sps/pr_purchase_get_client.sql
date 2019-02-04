CREATE PROCEDURE dbo.pr_purchase_get_client (@id_client INT)

AS

SELECT TOP 1
c.id_cliente
,c.cd_cep
,c.cd_cpf
,c.cd_email_login
,c.cd_rg
,c.ds_bairro
,c.ds_celular
,c.ds_cidade
,c.ds_compl_endereco
,c.ds_ddd_celular
,c.ds_ddd_telefone
,c.ds_endereco
,c.ds_nome
,c.ds_sobrenome
,c.ds_telefone
,c.dt_inclusao
,c.dt_nascimento
,c.id_doc_estrangeiro
,c.id_estado
,c.in_concorda_termos
,c.in_recebe_info
,c.in_recebe_sms
,c.in_sexo
,c.nr_endereco
,c.ds_nome + ' ' + c.ds_sobrenome AS fullname 
FROM CI_MIDDLEWAY..mw_cliente c
WHERE c.id_cliente=@id_client