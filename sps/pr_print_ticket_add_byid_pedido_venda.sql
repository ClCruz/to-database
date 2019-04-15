ALTER PROCEDURE dbo.pr_print_ticket_add_byid_pedido_venda (
        @id_pedido_venda INT
        ,@id_admin_user UNIQUEIDENTIFIER = NULL
        ,@ip VARCHAR(1000) = NULL)

AS

SET NOCOUNT ON;

DECLARE @id_evento INT = NULL
      ,@codVenda VARCHAR(50) = NULL
      ,@id_base INT

SELECT @id_base = id_base FROM ci_middleway..mw_base WHERE ds_nome_base_sql = DB_NAME()

SELECT TOP 1 @id_evento=e.id_evento
        ,@codVenda=ipv.CodVenda
FROM CI_MIDDLEWAY..mw_pedido_venda pv
INNER JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON pv.id_pedido_venda=ipv.id_pedido_venda
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ipv.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
WHERE pv.id_pedido_venda=@id_pedido_venda

IF @id_admin_user = '00000000-0000-0000-0000-000000000000'
BEGIN
      SET @id_admin_user = NULL;
END


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