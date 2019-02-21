CREATE PROCEDURE dbo.pr_admin_to_cashregister_moviment_update (@id_ticketoffice_user uniqueidentifier
           ,@id_ticketoffice_cashregister UNIQUEIDENTIFIER)


AS


UPDATE [dbo].[ticketoffice_cashregister_moviment]
SET [id_ticketoffice_cashregister]=@id_ticketoffice_cashregister
    ,[isopen]=0
WHERE id_ticketoffice_user=@id_ticketoffice_user