ALTER PROCEDURE dbo.partner_sitemap_list 

AS

SELECT
p.uniquename
,p.id
,(CASE WHEN ps.id IS NULL THEN 999 ELSE DATEDIFF(hour, ps.lastgenerated, GETDATE()) END) hourafterlastgenerated
FROM CI_MIDDLEWAY..[partner] p
LEFT JOIN CI_MIDDLEWAY..partner_sitemap ps ON p.id=ps.id_partner
WHERE 
-- p.uniquename='ci_localhost'
p.isDemo=0
AND p.isDev=0
AND p.isTrial=0
AND (p.dateStart<=GETDATE() AND (p.dateEnd IS NULL OR p.dateEnd >= GETDATE() ))
ORDER BY uniquename