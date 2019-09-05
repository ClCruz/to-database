ALTER PROCEDURE dbo.pr_purchase_summary (@id_session VARCHAR(1000))

AS

-- DECLARE @id_session VARCHAR(1000) = '9qt9kr0nojt7e2619mhi26vvm7'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#aux', 'U') IS NOT NULL
    DROP TABLE #aux; 
IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 
IF OBJECT_ID('tempdb.dbo.#data_bases', 'U') IS NOT NULL
    DROP TABLE #data_bases; 
IF OBJECT_ID('tempdb.dbo.#resultToFinal', 'U') IS NOT NULL
    DROP TABLE #resultToFinal; 


CREATE TABLE #bases (id_base INT, done BIT)

DECLARE @toExec NVARCHAR(MAX)


CREATE TABLE #data_bases (id UNIQUEIDENTIFIER, id_base INT, base_sql VARCHAR(1000), CodApresentacao INT,CodTipBilhete INT
    ,Indice INT,StaCadeira VARCHAR(1000),DatApresentacao DATETIME
    ,HorSessao VARCHAR(1000),ValPeca INT,CodPeca INT
    ,NomPeca VARCHAR(1000), qt_parcelas INT,NomSala VARCHAR(1000),StaSala VARCHAR(1000)
    ,active BIT,allowticketoffice BIT,allowweb BIT
    ,NomObjeto VARCHAR(1000),NomSetor VARCHAR(1000),PerDescontoSetor FLOAT
    ,[Status] VARCHAR(1000),PerDesconto FLOAT,QtdVendaPorLote INT
    ,StaTipBilhMeiaEstudante VARCHAR(1000),StaTipBilhete VARCHAR(1000),TipBilhete VARCHAR(1000),TipBilhete2 VARCHAR(1000), ID_PROMOCAO_CONTROLE INT
    ,id_evento INT, id_apresentacao INT, id_reserva INT, hoursinadvance INT, in_taxa_por_pedido VARCHAR(1), id_apresentacao_bilhete INT, nr_beneficio VARCHAR(32),QT_INGRESSOS_POR_CPF INT, purchasebythiscpf INT, vl_preco_fixo FLOAT)

SELECT e.id_base, e.id_evento, e.CodPeca, a.CodApresentacao,a.id_apresentacao, r.id_reserva, r.id_cadeira
INTO #aux
FROM CI_MIDDLEWAY..MW_EVENTO E
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_EVENTO = E.ID_EVENTO
INNER JOIN CI_MIDDLEWAY..MW_RESERVA R ON R.ID_APRESENTACAO = A.ID_APRESENTACAO
WHERE R.id_session = @id_session

DECLARE @cpf VARCHAR(100)
SELECT @cpf=c.cd_cpf FROM CI_MIDDLEWAY..current_session_client csc
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON csc.id_cliente=c.id_cliente
WHERE csc.id_session=@id_session

INSERT INTO #bases (id_base, done)
SELECT DISTINCT id_base,0
FROM #aux
WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    DECLARE @currentBase INT = 0
            ,@db_name VARCHAR(1000)

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    SET @toExec=''
    SET @toExec = @toExec + 'INSERT INTO #data_bases (id, id_base, base_sql, CodApresentacao,CodTipBilhete '
    SET @toExec = @toExec + ',Indice,StaCadeira,DatApresentacao '
    SET @toExec = @toExec + ',HorSessao,ValPeca,CodPeca '
    SET @toExec = @toExec + ',NomPeca,qt_parcelas,NomSala,StaSala '
    SET @toExec = @toExec + ',active,allowticketoffice,allowweb '
    SET @toExec = @toExec + ',NomObjeto,NomSetor,PerDescontoSetor '
    SET @toExec = @toExec + ',[Status],PerDesconto,QtdVendaPorLote '
    SET @toExec = @toExec + ',StaTipBilhMeiaEstudante,StaTipBilhete,TipBilhete,TipBilhete2, ID_PROMOCAO_CONTROLE'
    SET @toExec = @toExec + ',id_evento, id_apresentacao, id_reserva,hoursinadvance,in_taxa_por_pedido,id_apresentacao_bilhete, nr_beneficio,QT_INGRESSOS_POR_CPF,purchasebythiscpf, vl_preco_fixo) '
    SET @toExec = @toExec + 'SELECT DISTINCT '
    SET @toExec = @toExec + '        NEWID() '
    SET @toExec = @toExec + '        , ' + CONVERT(VARCHAR(10),@currentBase)
    SET @toExec = @toExec + '        , ''' + @db_name + ''''
    SET @toExec = @toExec + '        ,ls.CodApresentacao '
    SET @toExec = @toExec + '        ,ls.CodTipBilhete '
    SET @toExec = @toExec + '        ,ls.Indice '
    SET @toExec = @toExec + '        ,ls.StaCadeira '
    SET @toExec = @toExec + '        ,a.DatApresentacao '
    SET @toExec = @toExec + '        ,a.HorSessao '
    SET @toExec = @toExec + '        ,CONVERT(INT,CONVERT(DECIMAL(18,2),a.ValPeca)*100)'
    SET @toExec = @toExec + '        ,a.CodPeca '
    SET @toExec = @toExec + '        ,p.NomPeca '
    SET @toExec = @toExec + '        ,p.qt_parcelas '
    SET @toExec = @toExec + '        ,s.NomSala '
    SET @toExec = @toExec + '        ,s.StaSala '
    SET @toExec = @toExec + '        ,sd.active '
    SET @toExec = @toExec + '        ,sd.allowticketoffice '
    SET @toExec = @toExec + '        ,sd.allowweb '
    SET @toExec = @toExec + '        ,sd.NomObjeto '
    SET @toExec = @toExec + '        ,se.NomSetor '            
    SET @toExec = @toExec + '        ,se.PerDesconto '
    SET @toExec = @toExec + '        ,se.[Status] '
    SET @toExec = @toExec + '        ,tb.PerDesconto '
    SET @toExec = @toExec + '        ,tb.QtdVendaPorLote '
    SET @toExec = @toExec + '        ,tb.StaTipBilhMeiaEstudante '
    SET @toExec = @toExec + '        ,tb.StaTipBilhete '
    SET @toExec = @toExec + '        ,tb.TipBilhete '
    SET @toExec = @toExec + '        ,tb.ds_nome_site '
    SET @toExec = @toExec + '        ,tb.ID_PROMOCAO_CONTROLE '
    SET @toExec = @toExec + '        ,e.id_evento '
    SET @toExec = @toExec + '        ,ap.id_apresentacao '
    SET @toExec = @toExec + '        ,r.id_reserva '
    SET @toExec = @toExec + '        , DATEDIFF(HOUR, GETDATE(), CONVERT(DATETIME, CONVERT(VARCHAR, ap.dt_apresentacao, 112) + '' '' + LEFT(ap.hr_apresentacao,2) + '':'' + RIGHT(ap.hr_apresentacao,2) + '':00'')) hoursinadvance '
    SET @toExec = @toExec + '        ,(SELECT TOP 1 SUB.IN_TAXA_POR_PEDIDO FROM CI_MIDDLEWAY..MW_TAXA_CONVENIENCIA SUB WHERE SUB.ID_EVENTO = E.ID_EVENTO AND SUB.DT_INICIO_VIGENCIA <= GETDATE() ORDER BY SUB.DT_INICIO_VIGENCIA DESC) in_taxa_por_pedido'
    SET @toExec = @toExec + '        ,apb.id_apresentacao_bilhete '
    SET @toExec = @toExec + '        ,r.nr_beneficio '
    SET @toExec = @toExec + '        ,p.QT_INGRESSOS_POR_CPF '

    SET @toExec = @toExec + '        ,( '
    SET @toExec = @toExec + '        SELECT SUM(CASE subH.CODTIPLANCAMENTO WHEN 1 THEN 1 ELSE -1 END)  '
    SET @toExec = @toExec + '        FROM '+@db_name+'.dbo.tabCliente subC '
    SET @toExec = @toExec + '        INNER JOIN '+@db_name+'.dbo.tabHisCliente subH ON subH.CODIGO = subC.CODIGO '
    SET @toExec = @toExec + '        INNER JOIN '+@db_name+'.dbo.tabApresentacao subA ON subA.CODAPRESENTACAO = subH.CODAPRESENTACAO '
    SET @toExec = @toExec + '        INNER JOIN '+@db_name+'.dbo.tabApresentacao subA2 ON subA2.DATAPRESENTACAO = subA.DATAPRESENTACAO AND subA2.CODPECA = subA.CODPECA AND subA2.HORSESSAO = subA.HORSESSAO '
    SET @toExec = @toExec + '        WHERE subC.CPF = '''+@cpf+''' AND subA2.CODAPRESENTACAO = a.codApresentacao '
    SET @toExec = @toExec + '        ) AS purchasebythiscpf '
    SET @toExec = @toExec + '        , ISNULL(tb.vl_preco_fixo,0) vl_preco_fixo'
    SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabLugSala ls '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON a.CodPeca=p.CodPeca '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON a.CodSala=sd.CodSala AND ls.Indice=sd.Indice '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON a.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON ls.CodTipBilhete=tb.CodTipBilhete '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_EVENTO e ON e.codPeca=p.codPeca AND e.id_base='+CONVERT(VARCHAR(10),@currentBase) + ' '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO AP ON AP.ID_EVENTO = E.ID_EVENTO AND a.codApresentacao=ap.CodApresentacao '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_RESERVA R ON r.id_session=ls.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND R.id_apresentacao = ap.id_apresentacao AND r.id_cadeira=ls.indice '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE APB ON APB.id_apresentacao=ap.id_apresentacao AND apb.codTipBilhete=ls.codTipBilhete AND r.id_apresentacao_bilhete=apb.id_apresentacao_bilhete AND APB.IN_ATIVO = 1 '

    SET @toExec = @toExec + 'WHERE ls.id_session='''+@id_session+''''

    -- select @toExec
    exec sp_executesql @toExec
	
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END

SELECT 
    id
    ,NomSetor
    ,NomObjeto
    ,(CASE WHEN TipBilhete LIKE 'MW%' THEN TipBilhete2 ELSE TipBilhete END) TipBilhete
    ,0 amount
    ,0 amount_service
    ,0 amount_total
    ,Indice
    ,CodApresentacao
    ,id_evento
INTO #resultToFinal    
FROM #data_bases


DECLARE @howmanytickets INT = 0
        ,@onlyOneTicket BIT = 0
        ,@counter INT = 0
        ,@totalService INT
        ,@totalWithoutDiscount INT
        ,@totalWithDiscount INT
        ,@totalWithService INT

IF OBJECT_ID('tempdb.dbo.#current', 'U') IS NOT NULL
    DROP TABLE #current;

IF OBJECT_ID('tempdb.dbo.#loopme', 'U') IS NOT NULL
    DROP TABLE #loopme;

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result;

CREATE TABLE #result (
    id INT
    , indice INT
    , serviceAmount FLOAT
    , serviceAmountINT INT
    , amount INT
    , discountTicket FLOAT
    , discountTicketIsPer BIT
    , discountSector FLOAT
    , discountSectorIsPer BIT
    , discountOther FLOAT
    , discountOtherIsPer BIT
    , amountallWithService INT
    , amountallWithoutService INT
    )

CREATE TABLE #loopme (
    id UNIQUEIDENTIFIER
    , done BIT
    )

CREATE TABLE #current (
    id UNIQUEIDENTIFIER
    , id_base INT
    , basesql VARCHAR(1000)
    , CodApresentacao INT
    , CodTipBilhete INT
    , Indice INT
    , StaCadeira VARCHAR(1000)
    , DatApresentacao DATETIME
    , HorSessao VARCHAR(1000)
    , ValPeca INT
    , CodPeca INT
    , NomPeca VARCHAR(1000)
    , qt_parcelas INT
    , NomSala VARCHAR(1000)
    , StaSala VARCHAR(1000)
    , active BIT
    , allowticketoffice BIT
    , allowweb BIT
    , NomObjeto VARCHAR(1000)
    , NomSetor VARCHAR(1000)
    , PerDescontoSetor FLOAT
    , [Status] VARCHAR(1000)
    , PerDesconto FLOAT
    , QtdVendaPorLote INT
    , StaTipBilhMeiaEstudante VARCHAR(1000)
    , StaTipBilhete VARCHAR(1000)
    , TipBilhete VARCHAR(1000)
    , ID_PROMOCAO_CONTROLE INT
    , id_evento INT
    , id_apresentacao INT
    , id_reserva INT
    , hoursinadvance INT
    , in_taxa_por_pedido VARCHAR(1)
    , id_apresentacao_bilhete INT
    , nr_beneficio VARCHAR(32)
    ,QT_INGRESSOS_POR_CPF INT
    , purchasebythiscpf INT
    )


-- SET @id_session = 'thslkr39i6nhon6qgbgs5bnoc2'
INSERT INTO #current
EXEC pr_purchase_get_current @id_session;

INSERT INTO #loopme (
    id
    , done
    )
SELECT id
    , 0
FROM #current

INSERT INTO #result (
    id
    , indice
    , serviceAmount
    , serviceAmountINT
    , amount
    , discountTicket
    , discountSector
    , discountOther
    , discountOtherIsPer
    , discountSectorIsPer
    , discountTicketIsPer
    , amountallWithoutService
    , amountallWithService
    )
SELECT c.id_reserva
    , c.Indice
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
    , 0
FROM #current c

SELECT @howmanytickets = COUNT(*) FROM #current

IF @howmanytickets = 1
    SET @onlyOneTicket = 1

WHILE (
        EXISTS (
            SELECT 1
            FROM #loopme
            WHERE done = 0
            )
        )
BEGIN
    DECLARE @loopid UNIQUEIDENTIFIER
        , @id_reserva INT
        , @id_evento INT
        , @id_apresentacao_bilhete INT
        , @codTipBilhete INT
        , @ID_PROMOCAO_CONTROLE INT
        , @basesql VARCHAR(1000)
        , @ValPeca FLOAT
        , @PerDescontoSetor FLOAT = 0
        , @PerDesconto FLOAT = 0
        , @PerDescontoOther FLOAT = 0
        , @PerDescontoSetorIsPer BIT = 1
        , @PerDescontoIsPer BIT = 1
        , @PerDescontoOtherIsPer BIT = 1
        , @service_amount FLOAT = 0
        , @service_amountINT INT = 0
    SET @counter = @counter + 1
    SELECT TOP 1 @loopid = id
    FROM #loopme
    WHERE done = 0
    ORDER BY id

    SELECT TOP 1 @id_evento = c.id_evento
                ,@id_reserva = c.id_reserva
                ,@id_apresentacao_bilhete = c.id_apresentacao_bilhete
                ,@codTipBilhete = c.CodTipBilhete
                ,@ID_PROMOCAO_CONTROLE = c.ID_PROMOCAO_CONTROLE
                ,@basesql = c.basesql
                ,@PerDesconto = c.PerDesconto
                ,@PerDescontoSetor = c.PerDescontoSetor
                ,@ValPeca = c.ValPeca
    FROM #current c
    WHERE c.id = @loopid

    DECLARE @VL_LIQUIDO_INGRESSO FLOAT = NULL
            ,@IN_VALOR_SERVICO BIT = 0
            ,@VL_TAXA_CONVENIENCIA NUMERIC(11,2) = NULL
            ,@IN_TAXA_CONVENIENCIA VARCHAR(1) = 'N'
            ,@VL_TAXA_PROMOCIONAL NUMERIC(11,2) = NULL
            ,@IN_TAXA_POR_PEDIDO VARCHAR(1) = 'N'
            ,@VL_TAXA_UM_INGRESSO NUMERIC(11,2) = NULL
            ,@VL_TAXA_UM_INGRESSO_PROMOCIONAL NUMERIC(11,2) = NULL
            ,@IN_COBRAR_PDV VARCHAR(1) = 'N'
            ,@IN_COBRAR_POS VARCHAR(1) = 'N'

    SELECT TOP 1 
          @VL_TAXA_CONVENIENCIA=VL_TAXA_CONVENIENCIA
        , @IN_TAXA_CONVENIENCIA=IN_TAXA_CONVENIENCIA
        , @VL_TAXA_PROMOCIONAL=VL_TAXA_PROMOCIONAL
        , @IN_TAXA_POR_PEDIDO=IN_TAXA_POR_PEDIDO
        , @VL_TAXA_UM_INGRESSO=VL_TAXA_UM_INGRESSO
        , @VL_TAXA_UM_INGRESSO_PROMOCIONAL=VL_TAXA_UM_INGRESSO_PROMOCIONAL
        , @IN_COBRAR_PDV=IN_COBRAR_PDV
        , @IN_COBRAR_POS=IN_COBRAR_POS
    FROM CI_MIDDLEWAY..MW_TAXA_CONVENIENCIA
    WHERE ID_EVENTO = @id_evento
        AND DT_INICIO_VIGENCIA <= GETDATE()
    ORDER BY DT_INICIO_VIGENCIA DESC


    SELECT @VL_LIQUIDO_INGRESSO = AB.VL_LIQUIDO_INGRESSO
    , @ID_PROMOCAO_CONTROLE = PC.ID_PROMOCAO_CONTROLE
    , @IN_VALOR_SERVICO = PC.IN_VALOR_SERVICO
    FROM CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB
    LEFT JOIN CI_MIDDLEWAY..MW_PROMOCAO_CONTROLE PC ON PC.ID_PROMOCAO_CONTROLE = @ID_PROMOCAO_CONTROLE AND PC.IN_ATIVO = 1
    WHERE AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE =@id_apresentacao_bilhete

    -- IF @IN_TAXA_POR_PEDIDO = 'S'
    -- BEGIN
    --     SELECT 0 success
    --             ,'Falha para recuperar a taxa. ERR-1'
    --     RETURN;
    -- END
    
    IF @onlyOneTicket = 1
    BEGIN
        IF @ID_PROMOCAO_CONTROLE IS NULL
        BEGIN
            SET @service_amount = ISNULL(@VL_TAXA_UM_INGRESSO,0)
        END
        ELSE
        BEGIN
            SET @service_amount = ISNULL(@VL_TAXA_UM_INGRESSO_PROMOCIONAL,0)
        END

        IF @IN_TAXA_CONVENIENCIA != 'V'
        BEGIN
            SET @service_amount = (@service_amount/CONVERT(FLOAT,100))*ISNULL(@VL_LIQUIDO_INGRESSO,0)
        END
    END
    ELSE
    BEGIN
        IF @ID_PROMOCAO_CONTROLE IS NULL
        BEGIN
            SET @service_amount = ISNULL(@VL_TAXA_CONVENIENCIA,0)
        END
        ELSE
        BEGIN
            SET @service_amount = ISNULL(@VL_TAXA_PROMOCIONAL,0)
        END

        IF @IN_TAXA_CONVENIENCIA != 'V'
        BEGIN
            SET @service_amount = (@service_amount/CONVERT(FLOAT,100))*ISNULL(@VL_LIQUIDO_INGRESSO,0)
        END
    END

    DECLARE @sumAux INT
            ,@sumAuxWithService INT
            ,@sumService INT

    SET @service_amountINT = ISNULL(ROUND(@service_amount,2),0)*100
    SET @sumAux = ISNULL(@ValPeca,0)*(CASE WHEN ISNULL(@PerDesconto,0)/100 = 0 THEN 1 ELSE ISNULL(@PerDesconto,0)/100 END);
    SET @sumAux = @sumAux*(CASE WHEN ISNULL(@PerDescontoSetor,0)/100 = 0 THEN 1 ELSE ISNULL(@PerDescontoSetor,0)/100 END);
    SET @sumAux = @sumAux*(CASE WHEN ISNULL(@PerDescontoOther,0)/100 = 0 THEN 1 ELSE ISNULL(@PerDescontoOther,0)/100 END);
    -- SET @sumAux = @sumAux+@service_amountINT

    SET @sumAuxWithService = @sumAux+@service_amountINT


    UPDATE #result SET 
            serviceAmount = @service_amount
            ,serviceAmountINT = @service_amountINT
            ,amount = @ValPeca
            ,discountTicket=@PerDesconto
            ,discountSector=@PerDescontoSetor
            ,discountOtherIsPer = 1
            ,discountSectorIsPer = 1
            ,discountTicketIsPer = 1
            ,amountallWithoutService = @sumAux
            ,amountallWithService = @sumAuxWithService
    WHERE id = @id_reserva

    UPDATE #loopme
    SET done = 1
    WHERE id = @loopid
END

SELECT @totalService = SUM(r.serviceAmountINT) FROM #result r
SELECT @totalWithoutDiscount = SUM(r.amount) FROM #result r
SELECT @totalWithDiscount = SUM(r.amountallWithoutService) FROM #result r
SELECT @totalWithService = SUM(r.amountallWithService) FROM #result r




UPDATE d
SET d.amountcalculated = r.amountallWithoutService
    ,d.amountServicecalculeted = r.serviceAmountINT
FROM CI_MIDDLEWAY..mw_reserva d
INNER JOIN #result r ON d.id_reserva=r.id

UPDATE u
SET u.amount=r.amountallWithoutService
    ,u.amount_service=r.serviceAmountINT
    ,u.amount_total=r.amountallWithService
FROM #resultToFinal u
INNER JOIN #result r ON u.Indice=r.indice

SELECT 
    id
    ,NomSetor
    ,NomObjeto
    ,TipBilhete
    ,amount
    ,FORMAT(CONVERT(DECIMAL(12,2),(amount))/100, 'N', 'pt-br') amount_formatted
    ,amount_service
    ,FORMAT(CONVERT(DECIMAL(12,2),(amount_service))/100, 'N', 'pt-br') amount_service_formatted
    ,amount_total
    ,FORMAT(CONVERT(DECIMAL(12,2),(amount_total))/100, 'N', 'pt-br') amount_total_formatted
    ,Indice
    ,CodApresentacao
    ,id_evento
    ,@totalService totalservice
    ,@totalWithoutDiscount totalwithoutdiscount
    ,@totalWithDiscount totalwithdiscount
    ,@totalWithService  totalwithservice
    ,FORMAT(CONVERT(DECIMAL(12,2),(@totalWithService))/100, 'N', 'pt-br') totalWithService_formatted
FROM #resultToFinal    
ORDER BY TipBilhete, NomSetor, NomObjeto