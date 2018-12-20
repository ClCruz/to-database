ALTER PROCEDURE dbo.pr_producer (@loggedId UNIQUEIDENTIFIER, @search VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

SET NOCOUNT ON;

SELECT
    p.id_produtor
    ,p.cd_cpf_cnpj
    ,p.cd_email
    ,p.ds_celular
    ,p.ds_ddd_celular
    ,p.ds_ddd_telefone
    ,p.ds_endereco
    ,p.ds_nome_contato
    ,p.ds_razao_social
    ,p.ds_telefone
    ,p.id_gateway
    ,p.in_ativo
    ,COUNT(*) OVER() totalCount
    ,@currentPage currentPage
FROM CI_MIDDLEWAY..mw_produtor p
INNER JOIN CI_MIDDLEWAY..producer_user pu ON p.id_produtor=pu.id_produtor AND pu.id_admin_user=@loggedId
WHERE 
((@search IS NULL OR p.ds_razao_social LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR p.cd_email LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS)
OR (@search IS NULL OR p.cd_cpf_cnpj LIKE '%'+@search+'%' COLLATE SQL_Latin1_General_Cp1251_CS_AS))
ORDER by p.ds_razao_social
 OFFSET (@currentPage-1)*@perPage ROWS
   FETCH NEXT @perPage ROWS ONLY;