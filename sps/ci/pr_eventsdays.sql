CREATE PROCEDURE dbo.pr_eventsdays (@codPeca INT)

AS

SET NOCOUNT ON;

SELECT DISTINCT
    CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao
    ,a.DatApresentacao [date]
FROM tabPeca p
INNER JOIN tabApresentacao a ON p.CodPeca=a.CodPeca
WHERE p.CodPeca=@codPeca
AND GETDATE() <=  DATEADD(HOUR, 8,(CONVERT(DATETIME,CONVERT(VARCHAR(10),a.DatApresentacao,121) + ' ' + a.HorSessao + ':00.000')))
ORDER BY [date] --DESC