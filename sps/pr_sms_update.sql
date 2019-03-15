CREATE PROCEDURE dbo.pr_sms_update (@id INT
        ,@status VARCHAR(100))


AS

UPDATE CI_MIDDLEWAY..sms SET [status]=@status WHERE id=@id