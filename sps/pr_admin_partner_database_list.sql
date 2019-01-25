ALTER PROCEDURE dbo.pr_admin_partner_database_list

AS

SELECT p.uniquename 
FROM CI_MIDDLEWAY..[partner] p
WHERE 
(p.dateEnd IS NULL 
OR p.dateEnd>=GETDATE())
AND p.active=1
UNION ALL
SELECT 'ci_model' uniquename
ORDER BY p.uniquename