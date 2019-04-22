CREATE PROCEDURE dbo.pr_partner_ga (@apikey VARCHAR(1000))

AS
-- DECLARE @apikey VARCHAR(1000) = 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'

SELECT TOP 1
p.ga_id
FROM CI_MIDDLEWAY..[partner] p
WHERE p.[key]=@apikey