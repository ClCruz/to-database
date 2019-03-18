ALTER PROCEDURE dbo.pr_sms_add (@id_client INT
        ,@id_to_admin_user UNIQUEIDENTIFIER
        ,@type VARCHAR(100)
        ,@cellphone VARCHAR(100)
        ,@status VARCHAR(100)
        ,@hasresponse BIT
        ,@responsedate DATETIME
        ,@content VARCHAR(MAX))


AS


SET NOCOUNT ON;

IF @id_to_admin_user = '00000000-0000-0000-0000-000000000000'
    SET @id_to_admin_user = NULL


INSERT INTO CI_MIDDLEWAY..sms(id_cliente, id_to_admin_user, [type], cellphone, [status], hasresponse, responsedate, content)
SELECT @id_client
        ,@id_to_admin_user
        ,@type
        ,@cellphone
        ,@status
        ,@hasresponse
        ,@responsedate
        ,@content

SELECT SCOPE_IDENTITY() id