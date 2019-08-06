ALTER PROCEDURE dbo.pr_room_list (@id_local_evento INT, @text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS

-- DECLARE @id_local_evento INT = NULL, @text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10

SET NOCOUNT ON;

SELECT 
    s.CodSala
    ,s.NomSala
    ,s.NomRedSala
    ,s.id_local_evento
    ,s.IngressoNumerado
    ,s.in_venda_mesa
    ,s.isLegacy
    ,s.nameonsite
    ,s.StaSala
    ,(SELECT COUNT(*) FROM tabSetor sub WHERE sub.CodSala=s.CodSala) seattypes_count
    ,SUBSTRING(
        (
            SELECT ',' + sub.NomSetor + '|' + CONVERT(VARCHAR(100),CONVERT(BIGINT, PerDesconto*100))  AS [text()]
            FROM tabSetor sub
            WHERE sub.CodSala=s.CodSala
            ORDER BY sub.NomSetor
            FOR XML PATH ('')
        ), 2, 4000) [seattypes]
  ,@currentPage currentPage
  ,COUNT(*) OVER() totalCount
FROM [dbo].tabSala s
WHERE 
s.id_local_evento=@id_local_evento
AND ((@text IS NULL OR s.NomSala like '%'+@text+'%')
        OR @text IS NULL OR s.NomSala like '%'+@text+'%'
        OR @text IS NULL OR s.NomRedSala like '%'+@text+'%')
ORDER BY s.NomSala
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;