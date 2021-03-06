ALTER PROCEDURE dbo.pr_admin_partner_get (@id UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

SELECT
    p.id
    ,p.active
    ,CONVERT(VARCHAR(10),p.created,103) created
    ,(CASE WHEN p.dateEnd IS NULL THEN '' ELSE CONVERT(VARCHAR(10),p.dateEnd,121) END) dateEnd
    ,CONVERT(VARCHAR(10),p.dateStart,121) dateStart
    ,p.domain
    ,p.[key]
    ,p.key_test
    ,p.name
    ,p.uniquename
    ,p.isDemo
    ,p.isTrial
    ,p.isDev
    ,(CASE WHEN p.isDemo = 1 THEN 'demo'
            WHEN p.isTrial = 1 THEN 'trial'
            WHEN p.isDev = 1 THEN 'dev'
            WHEN p.isDemo = 0 AND p.isTrial = 0 AND p.isDev = 0 THEN 'prod' END) [type]
    ,ISNULL(p.fb_appid,'') fb_appid
    ,ISNULL(p.ga_id,'') ga_id
    ,ISNULL(p.recaptchaid,'') recaptchaid
    ,ISNULL(p.sell_email,'') sell_email
    ,p.send_sell_email
    ,(CASE WHEN p.show_partner_info IS NULL THEN 0 ELSE p.show_partner_info END) show_partner_info
FROM CI_MIDDLEWAY..[partner] p
WHERE 
p.id=@id