ALTER PROCEDURE dbo.pr_partner_getinfo(@uniquename VARCHAR(1000))

AS

SELECT
p.name
,p.isDemo
,p.isTrial
,p.isDev
,p.fb_appid
,p.recaptchaid
,(CASE WHEN p.fb_appid IS NULL OR p.fb_appid = '' THEN 0 ELSE 1 END) hasfb
,(CASE WHEN p.recaptchaid IS NULL OR p.fb_appid = '' THEN 0 ELSE 1 END) hasrecaptcha
,(CASE WHEN p.show_partner_info IS NULL THEN 0 ELSE p.show_partner_info END) show_partner_info
FROM CI_MIDDLEWAY..[partner] p
WHERE p.uniquename=@uniquename