ALTER PROCEDURE dbo.pr_print_ticket_add_bycodvenda (
        @codVenda VARCHAR(50) = NULL
        ,@id_admin_user UNIQUEIDENTIFIER = NULL
        ,@ip VARCHAR(1000) = NULL)

AS

SET NOCOUNT ON;

DECLARE @id_evento INT = NULL
      ,@id_pedido_venda INT = NULL
      ,@id_base INT

SELECT @id_base = id_base FROM ci_middleway..mw_base WHERE ds_nome_base_sql = DB_NAME()

SELECT @id_evento=e.id_evento
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.CodPeca=e.CodPeca AND e.id_base=@id_base
WHERE ls.CodVenda=@codVenda

IF @id_admin_user = '00000000-0000-0000-0000-000000000000'
BEGIN
      SET @id_admin_user = NULL;
END

SELECT @id_pedido_venda=tosch.id_pedido_venda FROM CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosch WHERE tosch.codVenda=@codVenda

INSERT INTO [CI_MIDDLEWAY].dbo.[print_ticket]
           ([id_base]
           ,[id_evento]
           ,[id_pedido_venda]
           ,[codVenda]
           ,[id_admin_user]
           ,[ip])
     VALUES
           (@id_base
           ,@id_evento
           ,@id_pedido_venda
           ,@codVenda
           ,@id_admin_user
           ,@ip)