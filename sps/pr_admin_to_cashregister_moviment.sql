ALTER PROCEDURE dbo.pr_admin_to_cashregister_moviment (@id_ticketoffice_user uniqueidentifier
           ,@amount int
           ,@type varchar(100)
           ,@id_base int
           ,@codForPagto int
           ,@id_evento int
           ,@codVenda VARCHAR(10))


AS

INSERT INTO [dbo].[ticketoffice_cashregister_moviment]
           ([id_ticketoffice_user]
           ,[id_ticketoffice_cashregister]
           ,[isopen]
           ,[amount]
           ,[type]
           ,[id_base]
           ,[codForPagto]
           ,[id_evento]
           ,[codVenda])
     VALUES
           (@id_ticketoffice_user
           ,NULL
           ,1
           ,@amount
           ,@type
           ,@id_base
           ,@codForPagto
           ,@id_evento
           ,@codVenda)