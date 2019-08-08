ALTER PROCEDURE dbo.pr_room_sectors_list (@codSala INT)

AS

SELECT 
s.CodSetor
,s.NomSetor
,s.PerDesconto
,s.CorSetor
,s.[Status]
,s.CodSala
FROM tabSetor s
WHERE s.CodSala=@codSala
AND s.[Status]='A'
ORDER BY s.NomSetor