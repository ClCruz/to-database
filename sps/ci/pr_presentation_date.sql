ALTER PROCEDURE dbo.pr_presentation_date (@codPeca INT)

AS

-- DECLARE @codPeca INT = 1

SET NOCOUNT ON;

DECLARE @id_base INT
SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
    a.DatApresentacao
INTO #result
FROM tabApresentacao a
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON e.id_base=@id_base AND e.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON a.CodSala=se.codSala
WHERE a.CodPeca=@codPeca
AND a.StaAtivoWeb='S'
AND ap.in_ativo=1
AND DATEADD(MINUTE, 100,(CONVERT(DATETIME,CONVERT(VARCHAR(10),a.DatApresentacao,121) + ' ' + a.HorSessao + ':00.000')))>=GETDATE()
GROUP BY a.DatApresentacao
ORDER BY a.DatApresentacao


SELECT
    CONVERT(VARCHAR(10),DatApresentacao,103) [date]
FROM #result
ORDER BY DatApresentacao