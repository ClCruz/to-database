CREATE PROCEDURE dbo.pr_ticketoffice_shoppingcart_clear (@id_ticketoffice_user UNIQUEIDENTIFIER, @api_code VARCHAR(1000) = NULL)

AS

DELETE FROM dbo.ticketoffice_shoppingcart WHERE id_ticketoffice_user=@id_ticketoffice_user 
AND (@api_code IS NULL OR api_code=@api_code)