CREATE PROCEDURE dbo.pr_purchase_setinproc (@cd_meio_pagamento INT
                                            ,@id_pedido_venda INT)

AS

SET NOCOUNT ON;

DECLARE @id_meio_pagamento INT

SELECT @id_meio_pagamento=id_meio_pagamento FROM CI_MIDDLEWAY..mw_meio_pagamento WHERE cd_meio_pagamento=@cd_meio_pagamento

UPDATE CI_MIDDLEWAY..mw_pedido_venda
SET id_meio_pagamento=@id_meio_pagamento
    ,in_situacao='P'
WHERE id_pedido_venda=@id_pedido_venda