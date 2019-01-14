--exec pr_adm_ticketoffice_users @perPage=1, @currentPage=10

ALTER PROCEDURE dbo.pr_adm_ticketoffice_users (@api VARCHAR(100) = NULL, @name VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

-- declare @api VARCHAR(100) = NULL, @name VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 100


SET NOCOUNT ON;

IF @name = ''
    SET @name = NULL

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT
    tou.id
    ,tou.name
    ,tou.[login]
    ,tou.email
    ,tou.active
    ,CONVERT(VARCHAR(10),tou.created,103) + ' ' + CONVERT(VARCHAR(8),tou.created,114) [created]
    ,CONVERT(VARCHAR(10),tou.updated,103) + ' ' + CONVERT(VARCHAR(8),tou.updated,114) [updated]
    ,COUNT(*) OVER() totalCount
    ,@currentPage currentPage
FROM CI_MIDDLEWAY..ticketoffice_user tou
WHERE 
(@name IS NULL OR tou.name LIKE '%'+@name+'%')
OR (@name IS NULL OR tou.[login] LIKE '%'+@name+'%')
OR (@name IS NULL OR tou.email LIKE '%'+@name+'%')
ORDER by tou.name
-- OFFSET (@currentPage-1)*@perPage ROWS
--   FETCH NEXT @perPage ROWS ONLY;