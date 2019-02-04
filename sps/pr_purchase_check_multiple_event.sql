
ALTER PROCEDURE dbo.pr_purchase_check_multiple_event (@id_client INT)

AS

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#events', 'U') IS NOT NULL
    DROP TABLE #events; 

SELECT DISTINCT e.id_evento
INTO #events
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE csc.id_cliente=@id_client

DECLARE @howmany INT = 0

SELECT @howmany = COUNT(1) FROM #events

IF @howmany > 1
BEGIN
    SELECT 0 success
            ,'A compra deve ser realizada para apenas 1 evento.' msg
END
ELSE
BEGIN
    SELECT 1 success
            ,'' msg
END