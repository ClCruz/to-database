CREATE PROCEDURE dbo.pr_admin_partner_database_list

AS

SELECT p.uniquename 
FROM CI_MIDDLEWAY..[partner] p
WHERE 
(p.dateEnd IS NULL 
OR p.dateEnd>=GETDATE())
AND p.active=1
ORDER BY p.uniquename