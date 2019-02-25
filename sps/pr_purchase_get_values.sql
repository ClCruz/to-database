-- -- SELECT * FROM CI_MIDDLEWAY..mw_reserva
-- -- EXEC pr_purchase_get_current 'thslkr39i6nhon6qgbgs5bnoc2';
-- -- pr_purchase_get_values 36
-- select * from CI_MIDDLEWAY..mw_reserva
-- select * from CI_MIDDLEWAY..mw_apresentacao_bilhete where id_apresentacao_bilhete=49122198
-- select * from bringressos..tabtipbilhete
-- -- DECLARE @id_client INT = 30

ALTER PROCEDURE dbo.pr_purchase_get_values (@id_client INT)

AS

-- DECLARE @id_client INT = 83

DECLARE @id_session VARCHAR(100)

SET NOCOUNT ON;

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

SELECT @id_session = csc.id_session
FROM CI_MIDDLEWAY..current_session_client csc
WHERE csc.id_cliente = @id_client

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
        , @toExec NVARCHAR(MAX)
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

    IF @IN_TAXA_POR_PEDIDO = 'S'
    BEGIN
        SELECT 0 success
                ,'Falha para recuperar a taxa. ERR-1'
        RETURN;
    END
    
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

SELECT 
r.id
,r.indice
,r.amount
,r.amountallWithoutService
,r.amountallWithService
,r.serviceAmountINT
,r.discountOther
,r.discountOtherIsPer
,r.discountSector
,r.discountSectorIsPer
,r.discountTicket
,r.discountTicketIsPer
,r.serviceAmount
,@totalService totalservice
,@totalWithoutDiscount totalwithoutdiscount
,@totalWithDiscount totalwithdiscount
,@totalWithService  totalwithservice
FROM #result r