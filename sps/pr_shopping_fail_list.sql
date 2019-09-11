ALTER PROCEDURE dbo.pr_shopping_fail_list (@uniquename VARCHAR(100)
        ,@document VARCHAR(50) = NULL
        ,@name VARCHAR(1000) = NULL
        ,@id_evento INT
        ,@id_apresentacao INT
        ,@currentPage INT = 1
        ,@perPage INT = 10)

AS

-- DECLARE @uniquename VARCHAR(100) = 'viveringressos'
--         ,@document VARCHAR(50) = '39042273860'
--         ,@name VARCHAR(1000) = NULL
--         ,@id_evento INT = NULL
--         ,@id_apresentacao INT = NULL
--         ,@currentPage INT = 1
--         ,@perPage INT = 1000

IF @document = ''
    SET @document = NULL

IF @name = ''
    SET @name = NULL

IF @id_evento = 0
    SET @id_evento = NULL

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

SELECT
    sf.id
    ,sf.created
    ,CONVERT(VARCHAR(10), sf.created, 103) + ' ' + CONVERT(VARCHAR(10), sf.created, 108) created_at
    ,sf.id_cliente
    ,sf.id_evento
    ,sf.id_apresentacao
    ,sf.json_shopping
    ,sf.json_values
    ,sf.json_gateway_response
    ,sf.[status]
    ,sf.refuse_reason
    ,c.cd_cpf client_document
    ,c.ds_nome + ' ' + c.ds_sobrenome client_name
    ,e.ds_evento
    ,CONVERT(VARCHAR(10), ap.dt_apresentacao, 103) dt_apresentacao
    ,ap.hr_apresentacao
    ,@currentPage currentPage
    ,COUNT(*) OVER() totalCount
FROM CI_MIDDLEWAY..shopping_fail sf
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON sf.id_cliente=c.id_cliente
INNER JOIN CI_MIDDLEWAY..mw_evento e ON sf.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON sf.id_apresentacao=ap.id_apresentacao
WHERE sf.uniquename_site=@uniquename
AND (@document IS NULL OR c.cd_cpf=@document)
AND (@name IS NULL OR (c.ds_nome + ' ' + c.ds_sobrenome LIKE '%'+@name+'%'))
AND (@id_evento IS NULL OR sf.id_evento=@id_evento)
AND (@id_apresentacao IS NULL OR sf.id_apresentacao=@id_apresentacao)
ORDER BY sf.created DESC, (c.ds_nome + ' ' + c.ds_sobrenome)
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;