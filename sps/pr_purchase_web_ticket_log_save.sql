CREATE PROCEDURE dbo.pr_purchase_web_ticket_log_save(@type VARCHAR(100)
                                                    ,@id_to_admin_user uniqueidentifier
                                                    ,@id_pedido_venda INT)

AS 

INSERT INTO [dbo].[purchase_web_ticket_log]
           ([id]
           ,[created]
           ,[type]
           ,[id_to_admin_user]
           ,[id_pedido_venda])
     VALUES
           (NEWID()
           ,GETDATE()
           ,@type
           ,@id_to_admin_user
           ,@id_pedido_venda)
GO

