--exec sp_executesql N'EXEC pr_producer_get @P1,@P2,@P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',N'',N'286.801.350-38'

ALTER PROCEDURE dbo.pr_producer_get (@loggedId UNIQUEIDENTIFIER, @id_produtor INT = NULL, @document VARCHAR(100) = NULL)

AS

-- DECLARE @loggedId UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E', @id_produtor INT = '', @document VARCHAR(100) = '286.801.350-38'
-- DECLARE @loggedId UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E', @id_produtor INT = 30, @document VARCHAR(100) = ''

SET NOCOUNT ON;

DECLARE @setInner BIT = 1

IF @id_produtor = ''
    SET @id_produtor=NULL

IF @document = ''
    SET @document = NULL

IF @document IS NOT NULL
    SET @document = REPLACE(REPLACE(REPLACE(@document, '-', ''), '/', ''), '.', '')

IF @document IS NOT NULL AND @id_produtor IS NULL
    SET @setInner = 0

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
    ,pu.id_admin_user
FROM CI_MIDDLEWAY..mw_produtor p
LEFT JOIN CI_MIDDLEWAY..producer_user pu ON p.id_produtor=pu.id_produtor AND pu.id_admin_user=@loggedId
WHERE 
(@id_produtor IS NULL OR p.id_produtor=@id_produtor)
AND (@document IS NULL OR p.cd_cpf_cnpj=@document)
AND (@setInner = 0 OR pu.id_admin_user IS NOT NULL)