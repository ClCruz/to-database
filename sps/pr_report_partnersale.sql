-- exec sp_executesql N'EXEC pr_report_partnersale @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'7.89',N'2019-04-01',N'2019-05-20',N'sazarte'


ALTER PROCEDURE dbo.pr_report_partnersale (@comission FLOAT
        ,@dtinit VARCHAR(10)
        ,@dtend VARCHAR(10)
        ,@id_quotapartner UNIQUEIDENTIFIER)

AS

-- DECLARE @comission FLOAT = 7.89
--         ,@dtinit VARCHAR(10) = '2019-01-01'
--         ,@dtend VARCHAR(10) = '2019-07-31'
--         ,@id_quotapartner UNIQUEIDENTIFIER = 'bfbf240a-a026-4ce4-945b-575098046c98'

SET @dtinit = @dtinit + ' 00:00:00';
SET @dtend = @dtend + ' 23:59:59';

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT DISTINCT
        ls.CodVenda
        ,p.NomPeca
        ,CONVERT(VARCHAR(10),l.DatVenda,103) DatVenda
        ,CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao
        ,a.HorSessao
        ,SUM(l.ValPagto) vl_total_pedido_venda
        ,tfp.TipForPagto
        ,CONVERT(DECIMAL(18,2),(ROUND(CONVERT(DECIMAL(18,4),SUM(l.ValPagto))*(@comission)/100,2))) comission_amount
        ,@comission comission
        ,cli.Nome
        ,cli.EMail
        ,cli.CPF
INTO #result
FROM ci_localhost..tabLugSala ls
INNER JOIN ci_localhost..tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN ci_localhost..tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN ci_localhost..tabLancamento l ON ls.CodApresentacao=l.CodApresentacao AND ls.Indice=l.Indice
INNER JOIN ci_localhost..tabHisCliente hc ON hc.CodApresentacao=ls.CodApresentacao AND hc.Indice=ls.Indice AND l.NumLancamento=hc.NumLancamento
INNER JOIN ci_localhost..tabCliente cli ON hc.Codigo=cli.Codigo
INNER JOIN ci_localhost..tabForPagamento fp ON l.CodForPagto=fp.CodForPagto
INNER JOIN ci_localhost..tabTipForPagamento tfp ON fp.CodTipForPagto=tfp.CodTipForPagto
WHERE ls.id_quotapartner=@id_quotapartner
AND ls.StaCadeira='V'
GROUP BY 
        ls.CodVenda
        ,p.NomPeca
        ,CONVERT(VARCHAR(10),l.DatVenda,103)
        ,CONVERT(VARCHAR(10),a.DatApresentacao,103)
        ,a.HorSessao
        ,tfp.TipForPagto
        ,cli.Nome
        ,cli.EMail
        ,cli.CPF

DECLARE @total DECIMAL(18,2) = 0
        ,@total_comission DECIMAL(18,2) = 0


SELECT @total=SUM(r.vl_total_pedido_venda) FROM #result r
SELECT @total_comission=SUM(r.comission_amount) FROM #result r


SELECT 
r.CodVenda
,r.NomPeca
,r.DatVenda
,r.DatApresentacao
,r.HorSessao
,r.vl_total_pedido_venda
,r.TipForPagto
,r.comission_amount
,r.comission
,r.Nome
,r.EMail
,r.CPF
,FORMAT(CONVERT(DECIMAL(18,2),(@total)), 'N', 'pt-br') total_formatted
,FORMAT(CONVERT(DECIMAL(18,2),(@total_comission)), 'N', 'pt-br') total_comission_formatted
,@total total
,@total_comission total_comission
,FORMAT(CONVERT(DECIMAL(18,2),r.comission_amount), 'N', 'pt-br') comission_amount_formatted
FROM #result r
