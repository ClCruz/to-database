--pr_event 'comedy_night_teatro_renaissance_22707', 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'

ALTER PROCEDURE dbo.pr_event (@key VARCHAR(100), @api VARCHAR(100))

AS

-- DECLARE @key VARCHAR(100) = 'na_anatomia_oca_dos_passaros_teatro_italia_33202'
--         ,@api VARCHAR(100) = 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'


DECLARE @keyHelper VARCHAR(100) = '/evento/' + @key
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
,(CASE WHEN convert(varchar(5), MIN(ap.dt_apresentacao),103) = convert(varchar(5), MAX(ap.dt_apresentacao),103) THEN convert(varchar(5), MIN(ap.dt_apresentacao),103) ELSE  convert(varchar(5), MIN(ap.dt_apresentacao),103) + ' - ' + convert(varchar(5), max(ap.dt_apresentacao),103) END) dates
,ISNULL(CI_MIDDLEWAY.dbo.fnc_eventonpartner(eei.id_evento, 'tixsme'),0) ontixsme
,dbo.fnc_baserename(b.ds_nome_base_sql) uniquename
,eei.external_uri
FROM CI_MIDDLEWAY..mw_evento_extrainfo eei
INNER JOIN CI_MIDDLEWAY..mw_evento e ON eei.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
LEFT JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.in_ativo=1
WHERE eei.uri=@keyHelper
GROUP BY 
eei.id_evento
,eei.cardimage
,eei.cardbigimage
,eei.uri
,eei.[description]
,eei.ticketsPerPurchase
,eei.minuteBefore
,eei.created
,e.CodPeca
,e.ds_evento
,e.id_base
,b.name_site
,b.ds_nome_base_sql
,eei.external_uri
ORDER BY eei.id_evento DESC