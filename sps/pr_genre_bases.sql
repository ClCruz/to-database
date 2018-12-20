--dbo.pr_genre_base_list 'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5'

ALTER PROCEDURE dbo.pr_genre_bases (@id_user UNIQUEIDENTIFIER)

AS

SET NOCOUNT ON;

DECLARE @lastId INT
SELECT @lastId = MAX(id) FROM CI_MIDDLEWAY..genre;

SELECT
b.id_base
,b.ds_nome_base_sql
,b.ds_nome_teatro
,(CASE WHEN gs.id_base IS NULL THEN 0 ELSE ( CASE WHEN gs.last_id <> @lastId THEN 0 ELSE 1 END ) END) active
FROM CI_MIDDLEWAY..mw_base b
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON b.id_base=taub.id_base AND taub.id_to_admin_user=@id_user
LEFT JOIN CI_MIDDLEWAY..genre_sync gs ON b.id_base=gs.id_base
WHERE b.in_ativo=1