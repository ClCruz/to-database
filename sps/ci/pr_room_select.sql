ALTER PROCEDURE dbo.pr_room_select (@id_local_evento INT)

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
FROM [dbo].tabSala s
WHERE s.StaSala='A'
AND s.id_local_evento=@id_local_evento
ORDER BY s.NomSala
