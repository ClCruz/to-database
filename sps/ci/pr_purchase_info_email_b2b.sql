-- pr_purchase_info_email_b2b 283, 'localhost'

ALTER PROCEDURE dbo.pr_purchase_info_email_b2b (@id_pedido_venda INT, @uniquename VARCHAR(100))

AS

-- DECLARE @id_pedido_venda INT = 418, @uniquename VARCHAR(100) = 'localhost'

SET NOCOUNT ON;

DECLARE @id_base INT
        ,@email VARCHAR(1000)
        ,@sendornot BIT = 0


SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT @email=p.sell_email
        ,@sendornot=p.send_sell_email
FROM CI_MIDDLEWAY..[partner] p WHERE p.uniquename=@uniquename

SELECT DISTINCT
pv.id_pedido_venda
,@email sell_email
,@sendornot send_sell_email
,ipv.CodVenda
,cli.ds_nome + ' ' + cli.ds_sobrenome buyer_name
,cli.cd_cpf buyer_document
,cli.cd_email_login buyer_email
,ISNULL(cli.ds_ddd_celular,'') + ISNULL(cli.ds_celular,'-') buyer_cellphone
,ISNULL(cli.ds_ddd_telefone,'') + ISNULL(cli.ds_telefone,'-') buyer_phone
,e.ds_evento [event]
,CONVERT(VARCHAR(10),ap.dt_apresentacao,103) + ' ' + ap.hr_apresentacao event_fulldate
,ISNULL(s.nameonsite,s.NomSala) event_room
,tb.ds_nome_site tickettype
,FORMAT(ipv.vl_unitario,'C', 'pt-br') amount
,FORMAT(ipv.vl_taxa_conveniencia,'C', 'pt-br') service_charge
,FORMAT((ipv.vl_unitario+ipv.vl_taxa_conveniencia),'C', 'pt-br') amount_topay
,FORMAT(pv.vl_total_pedido_venda,'C', 'pt-br') purchase_amount
,mp.nm_cartao_exibicao_site paymenttype
,ipv.Indice
,(CASE WHEN pv.nr_parcelas_pgto = 1 THEN 'à vista' ELSE 'x'+CONVERT(VARCHAR(10),pv.nr_parcelas_pgto) END) installment
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON ipv.id_apresentacao_bilhete=ab.id_apresentacao_bilhete
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_cliente cli ON pv.id_cliente=cli.id_cliente
INNER JOIN tabPeca p ON e.CodPeca=p.CodPeca
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao AND a.CodPeca=p.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabLugSala ls ON ls.CodApresentacao=ap.CodApresentacao AND ls.Indice=ipv.Indice
INNER JOIN tabSalDetalhe sd ON sd.Indice=ipv.Indice AND sd.CodSala=a.CodSala
INNER JOIN tabSetor se ON se.CodSala=s.CodSala AND sd.CodSetor=se.CodSetor
INNER JOIN tabTipBilhete tb ON tb.CodTipBilhete=ab.CodTipBilhete
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento mpfp ON pv.id_meio_pagamento=mpfp.id_meio_pagamento
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento mp ON mpfp.id_meio_pagamento=mp.id_meio_pagamento
INNER JOIN tabForPagamento fp ON mpfp.CodForPagto=fp.CodForPagto
WHERE pv.in_situacao='F' AND pv.id_pedido_venda=@id_pedido_venda
-- WHERE pv.id_cliente=30 AND pv.in_situacao='F' AND pv.id_pedido_venda=283
-- WHERE id_pedido_venda=
