/*
select * from CI_MIDDLEWAY..mw_cliente where cd_email_login='vladimir.queiroz@hotmail.com'
select * from CI_MIDDLEWAY..mw_cliente where cd_cpf='36527297572'

select top 100 * from CI_MIDDLEWAY..purchase_trace order by created desc

select id_purchase from CI_MIDDLEWAY..purchase_trace where id_purchase like '%-30' group by id_purchase order by id_purchase
select top 11 id_purchase from CI_MIDDLEWAY..purchase_trace where id_purchase like '%-30' order by created desc
*/
SELECT
pt.created
,pt.id_purchase
,pt.title
,pt.[values]
FROM CI_MIDDLEWAY..purchase_trace pt
-- WHERE pt.id_purchase='20190606063500-o1oabi8j4f2mhtoukvu5hu59j6-2253'
-- WHERE pt.id_purchase='20190606063652-o1oabi8j4f2mhtoukvu5hu59j6-2253'
-- WHERE pt.id_purchase='20190606063801-o1oabi8j4f2mhtoukvu5hu59j6-2253'

WHERE pt.id_purchase='20190619034331-mtevpu41s24rio8fpf2mcvr417-30'
-- WHERE pt.id_purchase='20190607104354-kbtcj1bum6c92r3gl8rfr853i3-2267'
-- WHERE pt.id_purchase='20190607104500-kbtcj1bum6c92r3gl8rfr853i3-2267'
order by created