-- pr_apresentacao_list 22696

ALTER PROCEDURE dbo.pr_apresentacao_list (@id_evento INT)

AS

SELECT 
a.id_apresentacao
,a.dt_apresentacao
,a.hr_apresentacao
,CONVERT(VARCHAR(10), a.dt_apresentacao, 103) + ' ' + REPLACE(a.hr_apresentacao,'h',':') AS [date]
FROM CI_MIDDLEWAY..mw_apresentacao a
WHERE a.id_evento=@id_evento
AND a.in_ativo=1
ORDER BY a.dt_apresentacao, a.hr_apresentacao