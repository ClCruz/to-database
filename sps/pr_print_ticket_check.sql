-- SELECT * FROM CI_MIDDLEWAY..mw_item_pedido_venda where CodVenda='OQGIDCAEEH'
-- select * from CI_MIDDLEWAY..mw_pedido_venda where id_pedido_venda=1558
-- select * from CI_MIDDLEWAY..mw_meio_pagamento where id_meio_pagamento=85

CREATE PROCEDURE dbo.pr_print_ticket_check (@codVenda VARCHAR(100))

AS

-- DECLARE @codVenda VARCHAR(100) = 'I64FBCEBOG'

SET NOCOUNT ON;

DECLARE @in_situacao VARCHAR(100) = NULL
SELECT @in_situacao=pv.in_situacao
FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
WHERE ipv.CodVenda=@codVenda

DECLARE @isok BIT = 0

IF @in_situacao IS NULL
BEGIN
    SET @isok = 1;
END
ELSE
BEGIN
    IF @in_situacao = 'F'
    BEGIN
        SET @isok = 1;
    END
END

SELECT @isok isok