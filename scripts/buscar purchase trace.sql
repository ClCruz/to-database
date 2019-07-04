/*
select * from CI_MIDDLEWAY..mw_cliente where cd_email_login='vladimir.queiroz@hotmail.com'
select * from CI_MIDDLEWAY..mw_cliente where cd_cpf='42643352807'
select * from ci_middleway..purchase_trace where title='Request gateway|pagarme|get_transaction'

select id_purchase from CI_MIDDLEWAY..purchase_trace where id_purchase like '%-3562' group by id_purchase order by id_purchase
select id_purchase from CI_MIDDLEWAY..purchase_trace where id_purchase like '%-3528' and title='buyer gateway' group by id_purchase, created order by created desc
*/
-- 20190703053315-1k0h3mjbrr01fs3q3co725ghi6-3426
-- 20190703053825-1k0h3mjbrr01fs3q3co725ghi6-3426
SELECT
pt.created
,pt.id_purchase
,pt.title
,pt.[values]
FROM CI_MIDDLEWAY..purchase_trace pt
WHERE pt.id_purchase='20190704093922-oke169brbnp9fa04kltumhm413-3528'

order by created


-- {"success":false,"object":"payment","msg":"Falha no pagamento do gateway.","gatewayinfo":{"errors":[{"type":"validation_error","parameter_name":"billing","message":"child \"address\" fails because [child \"complementary\" fails because [\"complementary\" is not allowed to be empty]]"}],"url":"\/transactions","method":"post"}}