CREATE FUNCTION dbo.fnc_splitok (@id_evento INT)

RETURNS BIT

AS
BEGIN
    DECLARE @RET BIT = 1;

    DECLARE @events TABLE (id_evento INT
                          ,percentage_boleto_web DECIMAL(21,3)
                          ,percentage_credit_web DECIMAL(21,3)
                          ,percentage_debit_web DECIMAL(21,3)
                          ,percentage_credit_box_office DECIMAL(21,3)
                          ,percentage_debit_box_office DECIMAL(21,3)
                          ,charge_processing_fee BIT
                          ,liable BIT);

    DECLARE @helper TABLE (id_evento INT
    ,percentage_boleto_web BIT
    ,percentage_credit_web BIT
    ,percentage_debit_web BIT
    ,percentage_credit_box_office BIT
    ,percentage_debit_box_office BIT
    ,charge_processing_fee BIT
    ,liable BIT)


    INSERT INTO @events (id_evento, percentage_boleto_web, percentage_credit_web, percentage_debit_web, percentage_credit_box_office, percentage_debit_box_office, charge_processing_fee, liable)
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
    FROM CI_MIDDLEWAY..mw_evento e
    WHERE e.id_evento=@id_evento


    INSERT INTO @helper (id_evento, percentage_boleto_web, percentage_credit_web, percentage_debit_web, percentage_credit_box_office, percentage_debit_box_office, charge_processing_fee, liable)
    SELECT 
    e.id_evento
    ,(CASE WHEN e.percentage_boleto_web!=100 THEN 0 ELSE 1 END) percentage_boleto_web
    ,(CASE WHEN e.percentage_credit_web!=100 THEN 0 ELSE 1 END) percentage_credit_web
    ,(CASE WHEN e.percentage_debit_web!=100 THEN 0 ELSE 1 END) percentage_debit_web
    ,(CASE WHEN e.percentage_credit_box_office!=100 THEN 0 ELSE 1 END) percentage_credit_box_office
    ,(CASE WHEN e.percentage_debit_box_office!=100 THEN 0 ELSE 1 END) percentage_debit_box_office
    ,(CASE WHEN e.charge_processing_fee!=1 THEN 0 ELSE 1 END) charge_processing_fee
    ,(CASE WHEN e.liable!=1 THEN 0 ELSE 1 END) liable
    FROM @events e


    DECLARE @percentageOK BIT = 1
            ,@charge_processing_feeOK BIT = 0
            ,@liableOK BIT = 0

    SELECT @percentageOK = 0 FROM @helper h WHERE (h.percentage_boleto_web = 0 
                                                    OR h.percentage_credit_web = 0
                                                    OR h.percentage_debit_web = 0
                                                    OR h.percentage_credit_box_office = 0
                                                    OR h.percentage_debit_box_office = 0)

    SELECT @charge_processing_feeOK=h.charge_processing_fee
            ,@liableOK = h.liable
    FROM @helper h


    IF @percentageOK = 0
    BEGIN
        SET @RET = 0;
    END
    IF @charge_processing_feeOK = 0
    BEGIN
        SET @RET = 0;
    END
    IF @liableOK = 0
    BEGIN
        SET @RET = 0;
    END


    RETURN @RET;
END