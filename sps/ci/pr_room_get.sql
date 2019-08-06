ALTER PROCEDURE dbo.pr_room_get (@id INT)

AS

SET NOCOUNT ON;

SELECT 
    s.CodSala
    ,s.DescTitulo
    ,s.id_local_evento
    ,s.IngressoNumerado
    ,s.isLegacy
    ,s.nameonsite
    ,s.NomRedSala
    ,s.NomSala
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
FROM [dbo].tabSala s
WHERE s.CodSala=@id