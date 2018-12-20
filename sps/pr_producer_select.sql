ALTER PROCEDURE dbo.pr_producer_select (@loggedId UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

SELECT
    p.id_produtor
    ,p.cd_cpf_cnpj
    ,p.ds_razao_social
    ,p.in_ativo
FROM CI_MIDDLEWAY..mw_produtor p
INNER JOIN CI_MIDDLEWAY..producer_user pu ON p.id_produtor=pu.id_produtor AND pu.id_admin_user=@loggedId
WHERE p.in_ativo=1