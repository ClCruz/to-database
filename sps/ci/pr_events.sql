-- EXEC pr_events

ALTER PROCEDURE dbo.pr_events (@id INT = NULL)

AS

SET NOCOUNT ON;

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT DISTINCT
    p.CodPeca
    ,p.NomPeca
    ,FORMAT(p.ValIngresso,'C', 'pt-br') ValIngresso
    ,p.in_vende_site
    ,(CONVERT(VARCHAR(10),p.DatIniPeca,103) + ' a ' + CONVERT(VARCHAR(10),p.DatFinPeca,103)) [days]
    ,p.TemDurPeca
    ,tp.TipPeca
    ,p.in_obriga_cpf needCPF
    ,p.in_obriga_rg needRG
    ,p.in_obriga_tel needPhone
    ,p.in_obriga_nome needName
    ,eei.ticketoffice_askemail
    ,eei.cardimage
    ,e.id_evento
    ,CI_MIDDLEWAY.dbo.fnc_splitok(e.id_evento) splitok
FROM tabPeca p
INNER JOIN tabApresentacao a ON p.CodPeca=a.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
LEFT JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
LEFT JOIN tabTipPeca tp ON p.CodTipPeca=tp.CodTipPeca
WHERE p.StaPeca='A' AND a.StaAtivoBilheteria='S' 
AND (@id IS NULL OR p.CodPeca=@id)
AND GETDATE() <=  DATEADD(HOUR, 8,(CONVERT(DATETIME,CONVERT(VARCHAR(10),a.DatApresentacao,121) + ' ' + a.HorSessao + ':00.000')))
--AND (@id IS NOT NULL OR CONVERT(DATETIME,CONVERT(VARCHAR(10),a.DatApresentacao,121) + ' ' + a.HorSessao + ':00.000')>=GETDATE())
ORDER BY p.NomPeca