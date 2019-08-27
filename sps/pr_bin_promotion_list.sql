-- exec sp_executesql N'EXEC pr_bin_promotion_list @P1, @P2',N'@P1 nvarchar(4000),@P2 nvarchar(4000)',N'2019-07-01 00:00:00',N'2019-07-31 23:59:59'
-- exec sp_executesql N'EXEC pr_bin_promotion_list @P1, @P2',N'@P1 nvarchar(4000),@P2 nvarchar(4000)',N'2019-07-01 00:00:00',N'2019-07-31 23:59:59'
-- exec sp_executesql N'EXEC pr_bin_promotion_list @P1, @P2',N'@P1 nvarchar(4000),@P2 nvarchar(4000)',N'2019-07-01 00:00:00',N'2019-07-31 23:59:59'

ALTER PROCEDURE dbo.pr_bin_promotion_list (@start DATETIME, @end DATETIME)

AS

SET NOCOUNT ON;

-- DECLARE @start DATETIME = '2019-07-01 00:00:00', @end DATETIME = '2019-08-27 23:59:59'

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

CREATE TABLE #result (sellid VARCHAR(1000), created_at VARCHAR(10), dt_pedido_venda DATETIME, buyer VARCHAR(1000), buyer_document VARCHAR(100), bin VARCHAR(100), sellfrom VARCHAR(100), vl_total_pedido_venda DECIMAL(12,2), sellamount VARCHAR(1000), sponsor VARCHAR(1000))


-- Data Venda, Nome Comprador, CPF comprador, Bin do cartão, Web ou Bilheteria, Valor da Venda.

INSERT INTO #result (sellid,created_at,dt_pedido_venda,buyer,buyer_document,bin,sellfrom,vl_total_pedido_venda,sellamount,sponsor)
SELECT DISTINCT
ipv.CodVenda
,CONVERT(VARCHAR(10),pv.dt_pedido_venda,103) created_at
,pv.dt_pedido_venda
,dbo.fn_StripCharacters((c.ds_nome + ' ' + c.ds_sobrenome), '^a-Z,0-9,'' ''') buyer 
,c.cd_cpf buyer_document
,pv.cd_bin_cartao bin
,'web' [sellfrom]
,pv.vl_total_pedido_venda
,FORMAT(CONVERT(DECIMAL(12,2),pv.vl_total_pedido_venda), 'N', 'pt-br') sellamount
,p.ds_NomPatrocinador sponsor
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
INNER JOIN CI_MIDDLEWAY..mw_controle_evento ce ON ap.id_evento=ce.id_evento
INNER JOIN CI_MIDDLEWAY..mw_promocao_controle pc ON ce.id_promocao_controle=pc.id_promocao_controle AND pv.dt_pedido_venda BETWEEN pc.dt_inicio_promocao AND pc.dt_fim_promocao
LEFT JOIN CI_MIDDLEWAY..mw_cartao_patrocinado cp ON pv.cd_bin_cartao=cp.cd_bin AND cp.id_patrocinador=pc.id_patrocinador
LEFT JOIN CI_MIDDLEWAY..mw_patrocinador p ON pc.id_patrocinador=p.id_Patrocinador
LEFT JOIN CI_MIDDLEWAY..mw_bandeira_cartao bc ON cp.id_bandeira_cartao=bc.id_bandeira_cartao
WHERE pv.dt_pedido_venda BETWEEN @start AND @end AND pv.cd_bin_cartao IS NOT NULL
AND pv.in_situacao='F'


SELECT DISTINCT tosh.id_base,0 done
INTO #bases
FROM CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosh
INNER JOIN CI_MIDDLEWAY..ticketoffice_pinpad topp ON tosh.id_ticketoffice_user=topp.id_ticketoffice_user
WHERE tosh.sell_date BETWEEN @start AND @end

-- return;
WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    DECLARE @currentBase INT = 0
            ,@db_name VARCHAR(1000)
            ,@toExec NVARCHAR(MAX)

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    SET @toExec=''
    SET @toExec = @toExec + 'INSERT INTO #result (sellid,created_at,dt_pedido_venda,buyer,buyer_document,bin,sellfrom,vl_total_pedido_venda,sellamount,sponsor) '
    SET @toExec = @toExec + ' SELECT DISTINCT  '
    SET @toExec = @toExec + ' tosh.codVenda '
    SET @toExec = @toExec + ' , CONVERT(VARCHAR(10),tosh.sell_date,103) created_at '
    SET @toExec = @toExec + ' , tosh.sell_date '
    SET @toExec = @toExec + ' , c.Nome buyer '
    SET @toExec = @toExec + ' , c.CPF buyer_document '
    SET @toExec = @toExec + ' , ls.BINCartao bin '
    SET @toExec = @toExec + ' , ''bilheteria'' sellfrom '
    SET @toExec = @toExec + ' , CONVERT(DECIMAL(12,2),tosh.amount_topay)/CONVERT(DECIMAL(12,2),100) vl_total_pedido_venda '
    SET @toExec = @toExec + ' , FORMAT(CONVERT(DECIMAL(12,2),tosh.amount_topay)/CONVERT(DECIMAL(12,2),100), ''N'', ''pt-br'') sellamount '
    SET @toExec = @toExec + ' , p.ds_NomPatrocinador sponsor '
    SET @toExec = @toExec + ' FROM ['+@db_name+'].dbo.tabLugSala ls  '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosh ON tosh.indice=ls.Indice AND tosh.codVenda=ls.CodVenda COLLATE SQL_Latin1_General_CP1_CI_AS'
    SET @toExec = @toExec + ' INNER JOIN ['+@db_name+'].dbo.tabHisCliente hc ON hc.Indice=tosh.indice AND ls.CodApresentacao=hc.CodApresentacao '
    SET @toExec = @toExec + ' INNER JOIN ['+@db_name+'].dbo.tabCliente c ON hc.Codigo=c.Codigo '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON e.CodPeca=tosh.id_event AND e.id_base=tosh.id_base '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_controle_evento ce ON e.id_evento=ce.id_evento '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_promocao_controle pc ON ce.id_promocao_controle=pc.id_promocao_controle AND tosh.created BETWEEN pc.dt_inicio_promocao AND pc.dt_fim_promocao '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_cartao_patrocinado cp ON cp.id_patrocinador=pc.id_patrocinador AND ls.BINCartao=cp.cd_bin  COLLATE SQL_Latin1_General_CP1_CI_AS '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_patrocinador p ON pc.id_patrocinador=p.id_Patrocinador '
    SET @toExec = @toExec + ' WHERE tosh.created BETWEEN @start AND @end AND ls.BINCartao IS NOT NULL '
    -- SET @toExec = @toExec + ' ORDER BY tosh.sell_date desc '

-- print @toExec
    EXEC sp_executesql @toExec, N'@start DATETIME, @end DATETIME',@start,@end
	
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END

SELECT DISTINCT
r.buyer
,r.buyer_document
,r.bin
,r.sellid
,r.created_at
,r.sellfrom
,r.sellamount
,r.sponsor
,r.dt_pedido_venda
,FORMAT(CONVERT(DECIMAL(12,2),(SELECT SUM(sub.vl_total_pedido_venda) FROM #result sub)), 'N', 'pt-br') selltotal
FROM #result r
ORDER BY r.dt_pedido_venda DESC

