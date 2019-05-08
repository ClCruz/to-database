ALTER PROCEDURE dbo.pr_admin_event_hour_select (@id_evento INT, @datePresentation VARCHAR(10))

AS

-- SET NOCOUNT ON;

-- DECLARE @id_evento INT = 32950,
--         @datePresentation VARCHAR(10) = '13/04/2019'

SELECT DISTINCT
    -- a.codApresentacao
    -- ,ap.id_apresentacao
    -- ,CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao
    ap.hr_apresentacao
    -- ,s.NomSala
    -- ,s.NomRedSala
    -- ,s.IngressoNumerado
    -- ,FORMAT(a.ValPeca,'C', 'pt-br') ValPeca
    -- ,se.PerDesconto
    -- ,CONVERT(DECIMAL(19,2),(CONVERT(DECIMAL(19,4),a.ValPeca)-(CONVERT(DECIMAL(19,4),a.ValPeca)*(CONVERT(DECIMAL(19,4),se.PerDesconto/100))))) cost
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON s.CodSala=se.CodSala
WHERE ap.id_evento=@id_evento
AND CONVERT(VARCHAR(10),a.DatApresentacao,103)=@datePresentation
ORDER BY ap.hr_apresentacao
