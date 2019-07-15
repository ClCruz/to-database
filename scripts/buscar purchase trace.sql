/*
select * from CI_MIDDLEWAY..mw_cliente where cd_email_login='vladimir.queiroz@hotmail.com'
select * from CI_MIDDLEWAY..mw_cliente where cd_cpf='30870283553'
Rselect * from ci_middleway..purchase_trace where title='Request gateway|pagarme|get_transaction'

select top 11 * from CI_MIDDLEWAY..purchase_trace order by created desc

select id_purchase from CI_MIDDLEWAY..purchase_trace where id_purchase like '%-19344-API' group by id_purchase order by id_purchase
select id_purchase from CI_MIDDLEWAY..purchase_trace where id_purchase like '%-3528' and title='buyer gateway' group by id_purchase, created order by created desc
*/
-- 20190703053315-1k0h3mjbrr01fs3q3co725ghi6-3426
-- 20190703053825-1k0h3mjbrr01fs3q3co725ghi6-3426
SELECT TOP 100
pt.created
,pt.id_purchase
,pt.title
,pt.[values]
FROM CI_MIDDLEWAY..purchase_trace pt
-- WHERE pt.id_purchase='20190705045030-E866X573EBC88C8-19344-API'

order by created DESC


-- {"success":false,"object":"payment","msg":"Falha no pagamento do gateway.","gatewayinfo":{"errors":[{"type":"validation_error","parameter_name":"billing","message":"child \"address\" fails because [child \"complementary\" fails because [\"complementary\" is not allowed to be empty]]"}],"url":"\/transactions","method":"post"}}
