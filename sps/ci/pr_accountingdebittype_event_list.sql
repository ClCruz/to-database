CREATE PROCEDURE dbo.pr_accountingdebittype_event_list (@id_evento INT)

AS
-- DECLARE @id_evento INT = 33016

SET NOCOUNT ON;

DECLARE @codPeca INT

SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

SELECT
db.CodPeca
,db.CodTipDebBordero
,CONVERT(VARCHAR(10),db.DatIniDebito,103) DatIniDebito
,CONVERT(VARCHAR(10),db.DatFinDebito,103) DatFinDebito
,tdb.PerDesconto
,FORMAT(CONVERT(DECIMAL(12,2),(tdb.PerDesconto)), 'N', 'pt-br') PerDesconto_formatted
,tdb.TipValor
,tdb.DebBordero
FROM tabDebBordero db
INNER JOIN tabTipDebBordero tdb ON db.CodTipDebBordero=tdb.CodTipDebBordero
WHERE db.CodPeca=@codPeca
AND tdb.StaDebBordero='A'
ORDER BY tdb.DebBordero