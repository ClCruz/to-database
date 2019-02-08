--exec pr_generate_email_ticket_print 'G6WDHOBFCO', 0, 0

CREATE PROCEDURE dbo.pr_generate_email_ticket_print (@codVenda VARCHAR(10), @id_base INT, @id_pedido_venda INT)

AS

SET NOCOUNT ON;

IF @codVenda = ''
    SET @codVenda = NULL

IF @id_base = 0
    SET @id_base = NULL

IF @id_pedido_venda = 0
    SET @id_pedido_venda = NULL

DECLARE @code VARCHAR(100)

SET @code = REPLACE(newid(),'-','')+REPLACE(newid(),'-','')+REPLACE(newid(),'-','')

INSERT INTO CI_MIDDLEWAY..email_ticket_print (code, seen_count, seen, seen_date, codVenda, id_base, id_pedido_venda)
SELECT @code, 0, 0, NULL, @codVenda, @id_base, @id_pedido_venda

SELECT @code code