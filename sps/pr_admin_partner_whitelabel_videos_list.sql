ALTER PROCEDURE dbo.pr_admin_partner_whitelabel_videos_list (@id_partner UNIQUEIDENTIFIER)
AS

SELECT
fileorder
,filetype
,CONCAT([source],'?',REPLACE(CONVERT(VARCHAR(100),GETDATE(),114),':','')) source
FROM CI_MIDDLEWAY..whitelabelcontentvideo
WHERE id_partner=@id_partner
ORDER BY fileorder