CREATE PROCEDURE dbo.pr_shopping_fail (@id_cliente INT
                                        ,@id_evento INT
                                        ,@id_apresentacao INT
                                        ,@json_shopping VARCHAR(MAX)
                                        ,@json_values VARCHAR(MAX)
                                        ,@json_gateway_response VARCHAR(MAX)
                                        ,@status VARCHAR(100)
                                        ,@refuse_reason VARCHAR(100)
                                        ,@status_reason VARCHAR(100)
                                        ,@uniquename_site VARCHAR(1000))

AS

INSERT INTO [dbo].[shopping_fail]
           ([id_cliente]
           ,[id_evento]
           ,[id_apresentacao]
           ,[json_shopping]
           ,[json_values]
           ,[json_gateway_response]
           ,[status]
           ,[refuse_reason]
           ,[status_reason]
           ,[uniquename_site])
     VALUES
           (@id_cliente
           ,@id_evento
           ,@id_apresentacao
           ,@json_shopping
           ,@json_values
           ,@json_gateway_response
           ,@status
           ,@refuse_reason
           ,@status_reason
           ,@uniquename_site)
GO

