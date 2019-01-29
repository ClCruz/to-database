-- use ci_middleway;
ALTER PROCEDURE pr_admin_partner_user_job (@id_partner UNIQUEIDENTIFIER)
AS

SET NOCOUNT ON;

DECLARE @uniquename VARCHAR(500) = NULL
        ,@id UNIQUEIDENTIFIER = NULL

SELECT @uniquename=uniquename, @id=id FROM CI_MIDDLEWAY..whitelabelconf WHERE id_partner=@id_partner;

IF @uniquename IS NOT NULL
BEGIN

    DECLARE @sql_statement nvarchar(4000);

    exec CI_MIDDLEWAY.dbo.pr_admin_partner_wl_status NULL, @uniquename, 'user', 'init'

    SET @sql_statement = N'CREATE LOGIN [api.'+@uniquename+'] WITH PASSWORD = ''!'+@uniquename+'@api#$'', CHECK_POLICY = OFF;';
    SET @sql_statement = @sql_statement + N'ALTER SERVER ROLE [sysadmin] ADD MEMBER [api.'+@uniquename+'];';
    SET @sql_statement = @sql_statement + N'CREATE LOGIN [legacy.'+@uniquename+'] WITH PASSWORD = ''!'+@uniquename+'@legacy#$'', CHECK_POLICY = OFF;';
    SET @sql_statement = @sql_statement + N'ALTER SERVER ROLE [sysadmin] ADD MEMBER [legacy.'+@uniquename+'];';
--print @sql_statement
    EXEC sp_executesql @sql_statement;

    exec CI_MIDDLEWAY.dbo.pr_admin_partner_wl_status NULL, @uniquename, 'user', 'ended'
END