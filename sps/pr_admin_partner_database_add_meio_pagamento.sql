CREATE PROCEDURE dbo.pr_admin_partner_database_add_meio_pagamento (@id_base INT)

AS

DECLARE @id_base_to_copy_from INT = 213

INSERT INTO CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento (id_base, id_meio_pagamento, CodForPagto, ds_forpagto) 
SELECT @id_base, id_meio_pagamento, CodForPagto, ds_forpagto 
from CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento 
WHERE id_base=@id_base_to_copy_from