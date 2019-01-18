ALTER PROCEDURE pr_admin_partner_database_job

AS

SET NOCOUNT ON;

DECLARE @uniquename VARCHAR(500) = NULL
        ,@id UNIQUEIDENTIFIER = NULL

SELECT @uniquename=uniquename, @id=id FROM CI_MIDDLEWAY..whitelabeljob ORDER BY created;

IF @uniquename IS NOT NULL
BEGIN

    DECLARE @sql_statement nvarchar(4000);
    SET @sql_statement = N'RESTORE DATABASE ['+@uniquename+'] FROM  DISK = N''D:\ticketoffice_system\CI_MODEL.bak'' WITH  FILE = 1, '
    SET @sql_statement = @sql_statement + N'MOVE N''TMSMultiEventos33_Data'' TO N''D:\MSSQLSERVER\tixsme_databases\data\'+@uniquename+'.mdf'', '
    SET @sql_statement = @sql_statement + N'MOVE N''TMSMultiEventos33_Log'' TO N''D:\MSSQLSERVER\tixsme_databases\log\'+@uniquename+'_1.ldf'',  NOUNLOAD, STATS = 5'

    EXEC sp_executesql @sql_statement;

    DELETE FROM CI_MIDDLEWAY..whitelabeljob WHERE id=@id;

    exec CI_MIDDLEWAY.dbo.pr_admin_partner_wl_status NULL, @uniquename, 'database', 'ended'

    exec CI_MIDDLEWAY.dbo.pr_admin_partner_database_mw_base @uniquename, 0
END