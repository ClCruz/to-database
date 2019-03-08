--exec sp_executesql N'EXEC pr_purchase_get_split @P1',N'@P1 nvarchar(4000)',N'30'

ALTER PROCEDURE dbo.pr_purchase_get_split (@id_client INT)

AS

-- DECLARE @id_client INT = 30

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result;

SELECT DISTINCT
e.id_evento
,re.recipient_id
,rs.nr_percentual_split
,rs.liable
,rs.charge_processing_fee
,rs.percentage_credit_web
,rs.percentage_debit_web
,rs.percentage_boleto_web
,rs.percentage_credit_box_office
,rs.percentage_debit_box_office
INTO #result
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_regra_split rs ON rs.id_evento=e.id_evento AND rs.in_ativo=1
INNER JOIN CI_MIDDLEWAY..mw_produtor p ON p.id_produtor = rs.id_produtor and p.in_ativo=1
INNER JOIN CI_MIDDLEWAY..mw_recebedor re ON rs.id_recebedor = re.id_recebedor and re.in_ativo=1
WHERE csc.id_cliente=@id_client

SELECT DISTINCT
r.id_evento
,r.recipient_id
,r.nr_percentual_split
,r.liable
,r.charge_processing_fee
,r.percentage_credit_web
,r.percentage_debit_web
,r.percentage_boleto_web
,r.percentage_credit_box_office
,r.percentage_debit_box_office
,(SELECT COUNT(1) FROM #result) howmanysplits
FROM #result r

