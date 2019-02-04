CREATE PROCEDURE dbo.pr_purchase_payment_method (@id_payment_method VARCHAR(100))

AS

SELECT 
mp.id_meio_pagamento
,mp.in_tipo_meio_pagamento
,mp.cd_meio_pagamento
,mp.ds_meio_pagamento
,mp.in_ativo
,mp.nm_cartao_exibicao_site
,mp.in_transacao_pdv
,mp.qt_hr_anteced
,mp.id_gateway
FROM CI_MIDDLEWAY..mw_meio_pagamento mp 
WHERE mp.cd_meio_pagamento=@id_payment_method