SELECT
b.id_base
,b.ds_nome_base_sql
,'INSERT INTO CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento (id_base, id_meio_pagamento, CodForPagto, ds_forpagto) SELECT '+CONVERT(VARCHAR(10),b.id_base)+', id_meio_pagamento, CodForPagto, ds_forpagto from CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento where id_base=213'
FROM CI_MIDDLEWAY..mw_base b
LEFT JOIN CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento mpfp ON b.id_base=mpfp.id_base
WHERE mpfp.id_base IS NULL

