CREATE PROCEDURE dbo.pr_web_purchase_list (@uniquename VARCHAR(100) = NULL
        ,@id_pedido_venda INT = NULL
        ,@document VARCHAR(50) = NULL
        ,@name VARCHAR(1000) = NULL
        ,@id_evento INT = NULL
        ,@id_apresentacao INT = NULL
        ,@currentPage INT = 1
        ,@perPage INT = 10)

AS

-- DECLARE @uniquename VARCHAR(100) = 'viveringressos'
--         ,@id_pedido_venda INT = 0
--         ,@document VARCHAR(50) = ''
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

IF @id_pedido_venda = 0
    SET @id_pedido_venda = NULL

IF @id_apresentacao = 0
    SET @id_apresentacao = NULL

SELECT DISTINCT
    ipv.id_pedido_venda
    ,pv.cd_bin_cartao
    ,mp.ds_meio_pagamento
    ,pv.cd_numero_transacao
    ,pv.dt_pedido_venda
    ,CONVERT(VARCHAR(10), pv.dt_pedido_venda, 103) + ' ' + CONVERT(VARCHAR(10), pv.dt_pedido_venda, 108) created_at
    ,pv.id_cliente
    ,e.id_evento
    ,ap.id_apresentacao
    ,pv.in_situacao
    ,c.cd_cpf client_document
    ,c.ds_nome + ' ' + c.ds_sobrenome client_name
    ,e.ds_evento
    ,CONVERT(VARCHAR(10), ap.dt_apresentacao, 103) dt_apresentacao
    ,ap.hr_apresentacao
    ,pv.vl_total_pedido_venda
    ,(SELECT COUNT(*) FROM CI_MIDDLEWAY..mw_item_pedido_venda sub WHERE sub.id_pedido_venda=ipv.id_pedido_venda) tickets_count
    ,@currentPage currentPage
    ,COUNT(*) OVER() totalCount
FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..order_host oh ON pv.id_pedido_venda=oh.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento mp ON pv.id_meio_pagamento=mp.id_meio_pagamento
WHERE pv.in_situacao IN ('F', 'P', 'E')
AND h.host=@uniquename
AND (@id_pedido_venda IS NULL OR ipv.id_pedido_venda=@id_pedido_venda)
AND (@document IS NULL OR c.cd_cpf=@document)
AND (@name IS NULL OR (c.ds_nome + ' ' + c.ds_sobrenome LIKE '%'+@name+'%'))
AND (@id_evento IS NULL OR e.id_evento=@id_evento)
AND (@id_apresentacao IS NULL OR ipv.id_apresentacao=@id_apresentacao)
ORDER BY pv.dt_pedido_venda DESC, client_name
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;