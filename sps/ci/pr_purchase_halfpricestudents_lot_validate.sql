-- https://compra.bringressos.com.br/comprar/etapa1.php?apresentacao=167576
-- select * from ci_middleway..mw_reserva
--select * from tabLugSala where Indice=94
-- select * from tabTipBilhete
-- DECLARE @id_session VARCHAR(100) = 'j5pu5q3um4cn4hcmuetsvcf9n0'

CREATE PROCEDURE dbo.pr_purchase_halfpricestudents_lot_validate (@id_session VARCHAR(100))

AS

SET NOCOUNT ON;

DECLARE @id_base INT = 0

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 


SELECT DISTINCT
r.id_reserva
,r.id_cadeira
,r.id_apresentacao
,a.CodApresentacao
,apb.id_apresentacao_bilhete
,apb.CodTipBilhete
,apb.vl_desconto
,apb.Vl_liquido_ingresso
,apb.vl_preco_unitario
,apb.in_ativo
,tb.StaCalculoPorSala
,tb.StaCalculoMeiaEstudante
,tb.StaTipBilhete
,(CASE WHEN tb.StaCalculoPorSala = 'S' THEN 
            (SELECT COALESCE(COUNT(subTLS.indice),0) FROM tabLugSala subtls
            WHERE subtls.CodApresentacao IN (SELECT CodApresentacao FROM CI_MIDDLEWAY..mw_apresentacao WHERE id_apresentacao = ap.id_apresentacao AND in_ativo = 1)
            AND subtls.CodTipBilhete IN (SELECT CODTIPBILHETE FROM CI_MIDDLEWAY..mw_apresentacao_bilhete WHERE id_apresentacao = ap.id_apresentacao AND in_ativo = 1)
            AND tb.StaTipBilhMeiaEstudante = 'S' AND tb.StaTipBilhete = 'A' AND subtls.StaCadeira='V'
            AND subtls.CodApresentacao = a.codApresentacao AND subtls.CodTipBilheteComplMeia IS NULL) 
        ELSE 
            (SELECT COALESCE(COUNT(subTLS.indice),0) FROM tabLugSala subtls
            INNER JOIN CI_MIDDLEWAY..mw_apresentacao suba ON subtls.CodApresentacao=suba.CodApresentacao
            INNER JOIN CI_MIDDLEWAY..mw_evento sube ON suba.id_evento=sube.id_evento AND id_base=@id_base
            WHERE subtls.CodApresentacao IN (SELECT CodApresentacao FROM CI_MIDDLEWAY..mw_apresentacao WHERE id_apresentacao = ap.id_apresentacao AND in_ativo = 1)
            AND subtls.CodTipBilhete IN (SELECT CODTIPBILHETE FROM CI_MIDDLEWAY..mw_apresentacao_bilhete WHERE id_apresentacao = ap.id_apresentacao AND in_ativo = 1)
            AND suba.DT_APRESENTACAO = (SELECT DT_APRESENTACAO FROM CI_MIDDLEWAY..MW_APRESENTACAO WHERE ID_APRESENTACAO = ap.id_apresentacao AND IN_ATIVO = 1)
            AND suba.HR_APRESENTACAO = (SELECT HR_APRESENTACAO FROM CI_MIDDLEWAY..MW_APRESENTACAO WHERE ID_APRESENTACAO = ap.id_apresentacao AND IN_ATIVO = 1)
            AND tb.StaTipBilhMeiaEstudante = 'S' AND tb.StaTipBilhete = 'A' AND subtls.StaCadeira='V'
            AND subtls.CodApresentacao = a.codApresentacao AND subtls.CodTipBilheteComplMeia IS NULL) 
        END) TotalMeiaVendido
,(CASE WHEN tb.StaCalculoPorSala = 'S' THEN 
            (SELECT COALESCE(COUNT(subtsd.Indice), 0) as TOTAL FROM tabSalDetalhe subtsd
                            WHERE subtsd.CodSala=a.CodSala AND subtsd.TipObjeto <> 'I') 
        ELSE 
            (SELECT COALESCE(COUNT(subtsd.Indice), 0) as TOTAL FROM tabSalDetalhe subtsd
                                                            INNER JOIN tabApresentacao subta ON subta.CodSala = subtsd.CodSala
                                                            INNER JOIN CI_MIDDLEWAY..mw_apresentacao suba ON suba.CodApresentacao=subta.CodApresentacao
                                                            INNER JOIN CI_MIDDLEWAY..mw_evento sube ON suba.id_evento=sube.id_evento AND id_base=@id_base
                        WHERE suba.id_apresentacao=ap.id_apresentacao
                        AND subA.DT_APRESENTACAO = (SELECT DT_APRESENTACAO FROM CI_MIDDLEWAY..MW_APRESENTACAO WHERE ID_APRESENTACAO = ap.id_apresentacao AND IN_ATIVO = 1)
                        AND subA.HR_APRESENTACAO = (SELECT HR_APRESENTACAO FROM CI_MIDDLEWAY..MW_APRESENTACAO WHERE ID_APRESENTACAO = ap.id_apresentacao AND IN_ATIVO = 1)
                        AND subtsd.TipObjeto <> 'I') 
        END) TotalMeia
,(SELECT COALESCE(COUNT(subtls.Indice),0) AS TOTAL FROM tabLugSala subtls
                                                    INNER JOIN CI_MIDDLEWAY..mw_apresentacao suba ON suba.CodApresentacao=subtls.CodApresentacao
                                                    INNER JOIN CI_MIDDLEWAY..mw_evento sube ON suba.id_evento=sube.id_evento AND id_base=@id_base
                                                    INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete subab ON subab.id_apresentacao = suba.id_apresentacao AND subtls.CodTipBilhete = subab.CodTipBilhete AND subab.IN_ATIVO = 1
                                                    INNER JOIN tabTipBilhete subtb ON subtb.CodTipBilhete = subab.CodTipBilhete
                WHERE subtls.CodApresentacao=a.codApresentacao
                AND subtls.CodTipBilhete=tb.CodTipBilhete
                AND subtb.QtdVendaPorLote > 0 AND subtb.StaTipBilhMeiaEstudante = 'N' AND subtb.StaTipBilhete = 'A' AND subtls.StaCadeira='V') TotalLoteVendido
,ISNULL((SELECT subtb.QtdVendaPorLote
                FROM tabTipBilhete subtb
                INNER JOIN ci_middleway..mw_apresentacao_bilhete subab ON subab.CodTipBilhete = subtb.CodTipBilhete
                WHERE subtb.QTDVENDAPORLOTE > 0 AND subtb.StaTipBilhMeiaEstudante = 'N' AND subtb.StaTipBilhete = 'A'
                AND subab.id_apresentacao_bilhete = apb.id_apresentacao_bilhete AND subab.IN_ATIVO = 1
),0) TotalLote
,tb.StaTipBilhMeiaEstudante
,ISNULL(tb.QtdVendaPorLote,0) QtdVendaPorLote
,(CASE WHEN (tb.StaTipBilhMeiaEstudante='S' AND tb.QtdVendaPorLote = 0 AND StaTipBilhete='A') THEN 1 ELSE 0 END) isHalfPriceStudents
,(CASE WHEN (tb.StaTipBilhMeiaEstudante='N' AND tb.QtdVendaPorLote>0 AND StaTipBilhete='A') THEN 1 ELSE 0 END) isLot
INTO #result
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_reserva r ON ls.id_session=r.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND ls.Indice=r.id_cadeira AND r.id_apresentacao=ap.id_apresentacao
INNER JOIN tabTipBilhete tb ON tb.CodTipBilhete=ls.CodTipBilhete
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON ls.CodTipBilhete=apb.CodTipBilhete AND ap.id_apresentacao=apb.id_apresentacao AND apb.IN_ATIVO = 1
WHERE ls.id_session=@id_session
AND ((tb.StaTipBilhMeiaEstudante='S' AND tb.QtdVendaPorLote = 0 AND StaTipBilhete='A') OR (tb.StaTipBilhMeiaEstudante='N' AND tb.QtdVendaPorLote>0 AND StaTipBilhete='A'))


DECLARE @totalMeia INT = 0
        ,@totalMeiaVendido INT = 0
        ,@totalMeiaCalculado INT = 0
        ,@totalLote INT = 0
        ,@totalLoteVendido INT = 0
        ,@totalLoteCalculado INT = 0

SELECT TOP 1 @totalLote=r.TotalLote FROM #result r ORDER BY r.TotalLote DESC
SELECT TOP 1 @totalLoteVendido=r.TotalLoteVendido FROM #result r ORDER BY r.TotalLoteVendido DESC
SELECT TOP 1 @totalMeia=r.TotalMeia FROM #result r ORDER BY r.TotalMeia DESC
SELECT TOP 1 @totalMeiaVendido=r.TotalMeiaVendido FROM #result r ORDER BY r.TotalMeiaVendido DESC

SET @totalLoteCalculado=@totalLote-@totalLoteVendido
SET @totalMeiaCalculado=@totalMeia-@totalMeiaVendido

DECLARE @has BIT = 0

SELECT @has=1 FROM #result

IF @has = 0
BEGIN
    SELECT 1 success
            ,'' msg
    RETURN;
END

DECLARE @totalHalfPriceStudentsPurchase INT
        ,@totalLotPurchase INT

SELECT @totalHalfPriceStudentsPurchase=COUNT(*) FROM #result r WHERE r.isHalfPriceStudents=1
SELECT @totalLotPurchase=COUNT(*) FROM #result r WHERE r.isLot=1

IF @totalHalfPriceStudentsPurchase>@totalMeiaCalculado
BEGIN
    SELECT 0 success
            ,'Limite de vendas para meia foi ultrapassado. (Total disponível no momento: ' + CONVERT(VARCHAR(10),@totalMeiaCalculado) + ')' msg
    RETURN;
END

IF @totalLotPurchase>@totalLoteCalculado
BEGIN
    SELECT 0 success
            ,'Limite de vendas para esse lote ultrapassado. (Total disponível no momento: ' + CONVERT(VARCHAR(10),@totalLoteCalculado) + ')' msg
    RETURN;
END

SELECT 1 success
        ,'' msg

