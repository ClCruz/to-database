ALTER PROCEDURE dbo.pr_ticketoffice_mobile_selected (@code VARCHAR(100))

AS

SELECT
    tosc.indice
    ,sd.NomObjeto
    ,s.NomSala
    ,se.NomSetor
    ,ls.StaCadeira
    ,CONVERT(VARCHAR(10),tosc.created,103) + ' ' + CONVERT(VARCHAR(8),tosc.created,114)  created
FROM CI_MIDDLEWAY..ticketoffice_shoppingcart tosc
INNER JOIN CI_MIDDLEWAY..ticketoffice_pairdevice topd ON tosc.id_ticketoffice_user=topd.id_ticketoffice_user
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON tosc.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSalDetalhe sd ON sd.CodSala=a.CodSala AND sd.Indice=tosc.indice
INNER JOIN tabSetor se ON sd.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor
INNER JOIN tabSala s ON sd.CodSala=s.CodSala
INNER JOIN tabLugSala ls ON ls.CodApresentacao=ap.CodApresentacao AND ls.Indice=tosc.indice
WHERE
    topd.code=@code
ORDER BY s.NomSala, se.NomSetor, sd.NomObjeto