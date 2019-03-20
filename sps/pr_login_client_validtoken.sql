-- pr_login_client_validtoken 'e8ea00153bef48b51d98188a65c5a01433ac659b'

CREATE PROCEDURE dbo.pr_login_client_validtoken (@token VARCHAR(1000))

AS

-- DECLARE @token VARCHAR(1000) = ''

SET NOCOUNT ON;

DECLARE @isvalid BIT = 0

SELECT TOP 1 @isvalid = 1 
FROM CI_MIDDLEWAY..mw_cliente 
WHERE token = @token AND dt_token_valid>=GETDATE()

SELECT @isvalid isvalid