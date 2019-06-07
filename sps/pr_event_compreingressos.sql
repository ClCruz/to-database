--pr_event 'comedy_night_teatro_renaissance_22707', 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'

ALTER PROCEDURE dbo.pr_event_compreingressos (@key VARCHAR(100), @api VARCHAR(100))

AS

-- DECLARE @key VARCHAR(100) = 'inner_circle_cota_de_ingressos_22678'
--         ,@api VARCHAR(100) = 'live_keykeykey'


DECLARE @keyHelper VARCHAR(100) = '/espetaculos/' + @key
        ,@id_partner UNIQUEIDENTIFIER
        ,@show_partner_info BIT

SELECT TOP 1 @id_partner=p.id,@show_partner_info=p.show_partner_info FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT TOP 1
eei.id_evento
,eei.cardimage
,eei.cardbigimage
,eei.uri
,eei.[description] COLLATE SQL_Latin1_General_CP1_CI_AS AS [description]
,eei.ticketsPerPurchase
,eei.minuteBefore
,eei.created
,e.CodPeca
,e.ds_evento
,e.id_base
,b.name_site
,@show_partner_info show_partner_info

FROM CI_MIDDLEWAY..mw_evento_extrainfo eei
INNER JOIN CI_MIDDLEWAY..mw_evento e ON eei.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
WHERE eei.uri=@keyHelper
ORDER BY eei.id_evento DESC