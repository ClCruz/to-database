ALTER PROCEDURE dbo.pr_accounting_key_add (@id_to_admin_user UNIQUEIDENTIFIER
                                            ,@id_evento INT
                                            ,@date VARCHAR(10)
                                            ,@hour VARCHAR(10))

AS

SET NOCOUNT ON;
DECLARE @id UNIQUEIDENTIFIER = NEWID()

INSERT INTO CI_MIDDLEWAY.[dbo].[accounting_key]
           ([id]
           ,[created]
           ,[id_to_admin_user]
           ,[id_evento]
           ,[id_apresentacao]
           ,[date]
           ,[hour]
           ,[used]
           ,[used_date])
     VALUES
           (@id
           ,GETDATE()
           ,@id_to_admin_user
           ,@id_evento
           ,NULL
           ,@date
           ,@hour
           ,0
           ,NULL)

SELECT @id id