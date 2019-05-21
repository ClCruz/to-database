-- exec sp_executesql N'EXEC pr_report_partnersale @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'7.89',N'2019-04-01',N'2019-05-20',N'sazarte'

ALTER PROCEDURE dbo.pr_report_partnersale (@comission FLOAT
        ,@dtinit VARCHAR(10)
        ,@dtend VARCHAR(10)
        ,@uniquename VARCHAR(100))

AS

-- relatorio
-- data e hora da venda
-- |evento
-- |data/hora
-- |valor da venda
-- |forma de pagamento
-- |% a ser exibida
-- |valor da venda * %
-- |(comissão)dados do cliente
-- | (clicado)detalhe da compra
-- | (clicado) - tipo de bilhete
-- , parcelado, etc
---total de venda, total de comissão, % a ser exibida

-- SET @uniquename = 'sazarte'
-- DECLARE @comission FLOAT = 7.89
--         ,@dtinit VARCHAR(10) = '2019-01-01'
--         ,@dtend VARCHAR(10) = '2019-05-20'
--         ,@uniquename VARCHAR(100) = 'tixsme'
        -- ,@uniquename VARCHAR(100) = 'localhost'
-- select * from CI_MIDDLEWAY..mw_base order by ds_nome_base_sql

SET @dtinit = @dtinit + ' 00:00:00';
SET @dtend = @dtend + ' 23:59:59';

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
        pv.id_pedido_venda
        ,CONVERT(VARCHAR(10),pv.dt_pedido_venda,103) dt_pedido_venda
        ,e.ds_evento
        ,eei.uri
        ,CONVERT(VARCHAR(10),ap.dt_apresentacao,103) dt_apresentacao
        ,ap.hr_apresentacao
        ,pv.vl_total_pedido_venda
        ,REPLACE(mp.ds_meio_pagamento, 'Pagar.me ','') ds_meio_pagamento
        ,@comission comission
        ,CONVERT(DECIMAL(18,2),(ROUND(CONVERT(DECIMAL(18,4),pv.vl_total_pedido_venda)*(@comission)/100,2))) comission_amount
        ,c.ds_nome + ' ' + c.ds_sobrenome [client_name]
        ,c.cd_cpf
        ,c.cd_email_login
        ,CONVERT(VARCHAR(10),c.dt_nascimento,103) dt_nascimento
        -- ,ab.ds_tipo_bilhete
        ,pv.nr_parcelas_pgto
        ,(CASE WHEN pv.nr_parcelas_pgto > 1 THEN 1 ELSE 0 END) isInstallment
        ,h.host
        ,b.ds_nome_base_sql
        -- ,dbo.fnc_checkdomain(h.host,b.ds_nome_base_sql)
INTO #result
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
-- INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON ipv.id_apresentacao_bilhete=ab.id_apresentacao_bilhete AND ap.id_apresentacao=ab.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento mp ON pv.id_meio_pagamento=mp.id_meio_pagamento
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON pv.id_cliente=c.id_cliente
LEFT JOIN CI_MIDDLEWAY..order_host oh ON oh.id_pedido_venda=pv.id_pedido_venda AND oh.indice=ipv.Indice
LEFT JOIN CI_MIDDLEWAY..host h ON oh.id_host=h.id
WHERE pv.in_situacao='F'
AND pv.dt_pedido_venda BETWEEN @dtinit AND @dtend
AND h.host=@uniquename
AND dbo.fnc_checkdomain(h.host,b.ds_nome_base_sql)=0
ORDER BY pv.id_pedido_venda DESC
-- RETURN;
DECLARE @total DECIMAL(18,2) = 0
        ,@total_comission DECIMAL(18,2) = 0


SELECT @total=SUM(r.vl_total_pedido_venda) FROM #result r
SELECT @total_comission=SUM(r.comission_amount) FROM #result r


SELECT 
r.id_pedido_venda
,@total total
,FORMAT(CONVERT(DECIMAL(18,2),(@total)), 'N', 'pt-br') total_formatted
,@total_comission total_comission
,FORMAT(CONVERT(DECIMAL(18,2),(@total_comission)), 'N', 'pt-br') total_comission_formatted
,r.dt_pedido_venda
,r.ds_evento
,r.uri
,r.dt_apresentacao
,r.hr_apresentacao
,r.vl_total_pedido_venda
,r.ds_meio_pagamento
,r.comission
,r.comission_amount
,FORMAT(CONVERT(DECIMAL(18,2),r.comission_amount), 'N', 'pt-br') comission_amount_formatted
,r.[client_name]
,r.cd_cpf
,r.cd_email_login
,r.dt_nascimento
-- ,r.ds_tipo_bilhete
,r.nr_parcelas_pgto
,r.isInstallment
,r.host
,r.ds_nome_base_sql
FROM #result r
