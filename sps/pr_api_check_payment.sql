CREATE PROCEDURE dbo.pr_api_check_payment (@id_payment VARCHAR(100), @id_base INT)

AS

-- DECLARE @id_payment VARCHAR(100) = '601',@id_base INT = 213

SELECT TOP 1 1 has
from CI_MIDDLEWAY..mw_meio_pagamento mp
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento mpfp	on mpfp.id_base = @id_base and mpfp.id_meio_pagamento = mp.id_meio_pagamento
WHERE
	mp.cd_meio_pagamento = @id_payment

