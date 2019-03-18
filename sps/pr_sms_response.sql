ALTER PROCEDURE dbo.pr_sms_response (@id INT
        ,@status VARCHAR(100)
        ,@data VARCHAR(100))


AS

UPDATE CI_MIDDLEWAY..sms SET hasresponse=1,responsedate=GETDATE(),[status]=@status,dategateway=@data WHERE id=@id