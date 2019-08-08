ALTER PROCEDURE dbo.pr_room_get (@id INT)

AS

SET NOCOUNT ON;

SELECT 
    s.CodSala
    ,s.DescTitulo
    ,s.id_local_evento
    ,le.id_municipio
    ,m.id_estado
    ,s.IngressoNumerado
    ,s.isLegacy
    ,s.nameonsite
    ,s.NomRedSala
    ,s.NomSala
    ,s.StaSala
    ,(SELECT COUNT(*) FROM tabSetor sub WHERE sub.CodSala=s.CodSala) seattypes_count
    ,SUBSTRING(
        (
            SELECT ',' + sub.NomSetor + '|' + CONVERT(VARCHAR(100),CONVERT(BIGINT, PerDesconto*100)) + '|' + CONVERT(VARCHAR(1000),CodSetor)  AS [text()]
            FROM tabSetor sub
            WHERE sub.CodSala=s.CodSala
            AND sub.[Status]='A'
            ORDER BY sub.NomSetor
            FOR XML PATH ('')
        ), 2, 4000) [seattypes]
FROM [dbo].tabSala s
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON s.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio=m.id_municipio

WHERE s.CodSala=@id