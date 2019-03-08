
ALTER PROCEDURE dbo.pr_purchase_check_split (@id_client INT)

AS

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#events', 'U') IS NOT NULL
    DROP TABLE #events; 

IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

SELECT DISTINCT e.id_evento
    ,(SELECT 
        SUM(sub.percentage_boleto_web)
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1) percentage_boleto_web
    ,(SELECT 
        SUM(sub.percentage_credit_web)
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1) percentage_credit_web
    ,(SELECT 
        SUM(sub.percentage_debit_web) 
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1) percentage_debit_web
    ,(SELECT 
        SUM(sub.percentage_credit_box_office) 
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1) percentage_credit_box_office
    ,(SELECT 
        SUM(sub.percentage_debit_box_office) 
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1) percentage_debit_box_office
    ,ISNULL((SELECT TOP 1 1
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1 AND sub.charge_processing_fee=1),0) charge_processing_fee
    ,ISNULL((SELECT TOP 1 1
    FROM CI_MIDDLEWAY..mw_regra_split sub WHERE sub.id_evento=e.id_evento AND sub.in_ativo=1 AND sub.liable=1),0) liable
INTO #events
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE csc.id_cliente=@id_client


SELECT 
(CASE WHEN e.percentage_boleto_web!=100 THEN 0 ELSE 1 END) percentage_boleto_web
,(CASE WHEN e.percentage_credit_web!=100 THEN 0 ELSE 1 END) percentage_credit_web
,(CASE WHEN e.percentage_debit_web!=100 THEN 0 ELSE 1 END) percentage_debit_web
,(CASE WHEN e.percentage_credit_box_office!=100 THEN 0 ELSE 1 END) percentage_credit_box_office
,(CASE WHEN e.percentage_debit_box_office!=100 THEN 0 ELSE 1 END) percentage_debit_box_office
,(CASE WHEN e.charge_processing_fee!=1 THEN 0 ELSE 1 END) charge_processing_fee
,(CASE WHEN e.liable!=1 THEN 0 ELSE 1 END) liable
INTO #helper
FROM #events e


DECLARE @percentageOK BIT = 1
        ,@charge_processing_feeOK BIT = 0
        ,@liableOK BIT = 0

SELECT @percentageOK = 0 FROM #helper h WHERE (h.percentage_boleto_web = 0 
                                                OR h.percentage_credit_web = 0
                                                OR h.percentage_debit_web = 0
                                                OR h.percentage_credit_box_office = 0
                                                OR h.percentage_debit_box_office = 0)

SELECT @charge_processing_feeOK=h.charge_processing_fee
        ,@liableOK = h.liable
FROM #helper h


IF @percentageOK = 0
BEGIN
    SELECT 0 success
            ,'Esse evento não está configurado para venda, por favor entrar em contato com a central de atendimento. (SP.ERR.1)' msg
    RETURN;
END
IF @charge_processing_feeOK = 0
BEGIN
    SELECT 0 success
            ,'Esse evento não está configurado para venda, por favor entrar em contato com a central de atendimento. (SP.ERR.2)' msg
    RETURN;
END
IF @liableOK = 0
BEGIN
    SELECT 0 success
            ,'Esse evento não está configurado para venda, por favor entrar em contato com a central de atendimento. (SP.ERR.3)' msg
    RETURN;
END


SELECT 1 success
        ,'' msg
