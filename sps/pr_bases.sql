ALTER PROCEDURE pr_bases (@id_ticketoffice_user UNIQUEIDENTIFIER = NULL)
AS

SELECT
b.id_base
,b.ds_nome_base_sql
,b.ds_nome_teatro
FROM CI_MIDDLEWAY..mw_base b
INNER JOIN CI_MIDDLEWAY..ticketoffice_user_base toub ON b.id_base=toub.id_base
WHERE b.in_ativo=1
AND toub.id_ticketoffice_user=@id_ticketoffice_user
AND toub.active=1
ORDER BY b.ds_nome_teatro