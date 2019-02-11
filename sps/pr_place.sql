--exec sp_executesql N'EXEC pr_place @P1, @P2, @P3, @P4, @P5, @P6',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000)',N'anzu',N'',N'',N'',N'1',N'10'

ALTER PROCEDURE dbo.pr_place (@api VARCHAR(100), @search VARCHAR(100) = NULL, @id_state INT, @id_city INT, @in_ativo BIT, @currentPage INT = 1, @perPage INT = 10)

AS

SET NOCOUNT ON;
--DECLARE @search VARCHAR(100) = 'adeg', @id_state INT = '', @id_city INT = '', @in_ativo BIT = '', @currentPage INT = 1, @perPage INT = 10
DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api


IF (@search = '') SET @search = NULL 
IF (@id_state = '') SET @id_state = NULL 
IF (@id_city = '') SET @id_city = NULL 
IF (@in_ativo = '') SET @in_ativo = NULL 

SELECT
le.id_local_evento
,le.ds_local_evento
,le.ds_googlemaps
,le.in_ativo
,m.ds_municipio
,e.sg_estado
,e.ds_estado
,tl.ds_tipo_local
,(CASE WHEN ple.id IS NULL THEN 0 ELSE 1 END) linked
,COUNT(*) OVER() totalCount
,@currentPage currentPage
FROM CI_MIDDLEWAY..mw_local_evento le
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio=m.id_municipio
INNER JOIN CI_MIDDLEWAY..mw_estado e ON m.id_estado=e.id_estado
INNER JOIN CI_MIDDLEWAY..mw_tipo_local tl ON le.id_tipo_local=tl.id_tipo_local
LEFT JOIN CI_MIDDLEWAY..partner_local_evento ple ON le.id_local_evento=ple.id_local_evento AND ple.id_partner=@id_partner
WHERE --1=1 
((@search IS NULL OR lower(le.ds_local_evento) LIKE '%'+lower(@search)+'%' COLLATE SQL_Latin1_General_Cp1251_CI_AS)
OR (@search IS NULL OR lower(m.ds_municipio) LIKE '%'+lower(@search)+'%' COLLATE SQL_Latin1_General_Cp1251_CI_AS)
OR (@search IS NULL OR lower(e.ds_estado) LIKE '%'+lower(@search)+'%' COLLATE SQL_Latin1_General_Cp1251_CI_AS)
OR (@search IS NULL OR lower(e.sg_estado) LIKE '%'+lower(@search)+'%' COLLATE SQL_Latin1_General_Cp1251_CI_AS))
AND (@id_city IS NULL OR le.id_municipio=@id_city)
AND (@id_state IS NULL OR m.id_estado=@id_city)
AND (@in_ativo IS NULL OR le.in_ativo=1)
ORDER BY le.ds_local_evento
--  OFFSET (@currentPage-1)*@perPage ROWS
--    FETCH NEXT @perPage ROWS ONLY;