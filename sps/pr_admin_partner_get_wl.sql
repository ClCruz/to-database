ALTER PROCEDURE dbo.pr_admin_partner_get_wl (@id UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

-- DECLARE @id UNIQUEIDENTIFIER = '1a0fdc45-e934-4c9e-bf4c-8fc8c11474a1';

DECLARE @domain VARCHAR(1000)
        ,@uniquename VARCHAR(500)
        ,@name VARCHAR(1000)
        ,@databaseOK BIT = 0
        ,@userOK BIT = 0
        ,@databaseStatus VARCHAR(1000) = 'not_init'
        ,@userStatus VARCHAR(1000) = 'not_init'

SELECT
    @domain = p.domain
    ,@name = p.name
    ,@uniquename = p.uniquename
FROM CI_MIDDLEWAY..[partner] p
WHERE 
p.id=@id

-- SET @uniquename='bringressos'

SELECT @databaseOK = 1 FROM master.sys.databases WHERE [name]=@uniquename
SELECT @userOK = 1 FROM master.sys.server_principals WHERE [name]='api.'+@uniquename

SELECT @databaseStatus=[status] FROM CI_MIDDLEWAY..whitelabelconf WHERE id_partner=@id AND [type]='database'
SELECT @userStatus=[status] FROM CI_MIDDLEWAY..whitelabelconf WHERE id_partner=@id AND [type]='user'

SELECT 
    @id id
    ,@domain domain
    ,@name [name]
    ,@uniquename uniquename
    ,@databaseOK databaseOK
    ,@userOK userOK
    ,@databaseStatus databaseStatus
    ,@userStatus userStatus