ALTER PROCEDURE dbo.pr_ticketoffice_email_ticket_print_setseen (@code VARCHAR(100))

AS


SET NOCOUNT ON;

DECLARE @id UNIQUEIDENTIFIER
        ,@codVenda VARCHAR(100)
        ,@id_base INT
        ,@id_pedido_venda INT

SELECT TOP 1
    @id=etp.id
    ,@codVenda=etp.codVenda
    ,@id_base=etp.id_base
    ,@id_pedido_venda=etp.id_pedido_venda
FROM CI_MIDDLEWAY..email_ticket_print etp
WHERE 
    etp.code=@code
ORDER BY created

UPDATE d
SET d.seen_count=d.seen_count+1
    ,d.seen=1
    ,d.seen_date=GETDATE()
FROM CI_MIDDLEWAY..email_ticket_print d
WHERE d.id=@id

SELECT @id id
        ,@codVenda codVenda
        ,@id_base id_base
        ,@id_pedido_venda id_pedido_venda