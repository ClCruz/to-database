ALTER PROCEDURE dbo.pr_api_refund (
    @codVenda VARCHAR(10)
    ,@all BIT = 0
    ,@indice INT = 0)

AS

-- RETURN;

-- DECLARE    @id_ticketoffice_user UNIQUEIDENTIFIER = '8CC26A74-7E65-411E-B854-F7B281A46E01'
--     ,@all BIT = 0
--     ,@codVenda VARCHAR(10) = 'OH4OBOBBFO'
--     ,@indiceList VARCHAR(MAX) = '518'


SET NOCOUNT ON;

DECLARE @id_base INT
        ,@amount INT
        ,@now DATETIME = GETDATE()

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

IF OBJECT_ID('tempdb.dbo.#indice', 'U') IS NOT NULL
    DROP TABLE #indice; 

IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

CREATE TABLE #indice (indice int);

CREATE TABLE #helper (id_apresentacao INT, id_event INT, CodApresentacao INT, CodPeca INT, CodSala INT, id_evento INT, id_payment_type INT, id_ticket_type INT, amount INT, NumLancamento INT NULL, Indice INT);

IF @all = 1
BEGIN
    INSERT INTO #indice (indice)
        SELECT ls.Indice
        FROM tabLugSala ls
        WHERE ls.CodVenda=@codVenda AND StaCadeira='V'
END

IF @indice != 0
BEGIN
    INSERT INTO #indice (indice)
        SELECT @indice

    DECLARE @totalDB INT
            ,@totalInHands INT

    SELECT @totalDB=COUNT(*)
    FROM tabLugSala ls
    WHERE ls.CodVenda=@codVenda AND StaCadeira='V'

    SELECT @totalInHands=COUNT(*)
    FROM #indice ls

    IF @totalDB<=@totalInHands
        SET @all=1
END

DECLARE @total INT
SELECT @total = COUNT(*) FROM #indice

INSERT INTO #helper (id_apresentacao, id_event, CodApresentacao, CodPeca, CodSala, id_evento, id_payment_type, id_ticket_type, amount, NumLancamento, Indice)
SELECT ap.id_apresentacao, e.id_evento, a.CodApresentacao, a.CodPeca, a.CodSala, e.id_evento, tosch.id_payment_type, tosch.id_ticket_type
, tosch.amount_topay, (SELECT TOP 1 NumLancamento FROM tabLancamento sub WHERE sub.CodApresentacao = ls.CodApresentacao AND sub.Indice = ls.Indice and codtiplancamento NOT IN (4,2) ORDER BY NumLancamento DESC), tosch.indice
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND a.CodApresentacao=ap.CodApresentacao
WHERE
    ls.Indice IN (SELECT indice FROM #indice)
    AND ls.CodVenda=@codVenda

SELECT @amount=SUM(h.amount) FROM #helper h

DECLARE @codCaixa INT, @codUsuario INT, @codMovimento INT
        ,@name VARCHAR(1000), @login VARCHAR(1000)
SELECT
    @codCaixa=codCaixa
    ,@codUsuario=codUsuario
    ,@name=u.name
    ,@login=u.[login]
FROM CI_MIDDLEWAY..ticketoffice_user_base toub
INNER JOIN CI_MIDDLEWAY..ticketoffice_user u ON toub.id_ticketoffice_user=u.id
WHERE id_ticketoffice_user=@id_ticketoffice_user AND toub.id_base=@id_base ORDER BY toub.codCaixa DESC;

SELECT @codMovimento=Codmovimento
FROM tabMovCaixa
WHERE CodCaixa=@codCaixa AND CodUsuario=@codUsuario AND StaMovimento='A'

DECLARE @CodCliente INT
SELECT @CodCliente=c.CodCliente FROM tabComprovante c WHERE c.CodVenda=@codVenda

-- select @total, @CodCliente, @codMovimento,@codCaixa
--select * from #helper
-- return;

IF @total>0
BEGIN
    DECLARE @transactionKey VARCHAR(1000)

    SELECT @transactionKey = pinpad_transactionId FROM CI_MIDDLEWAY..ticketoffice_pinpad WHERE codVenda=@codVenda

    INSERT INTO CI_MIDDLEWAY.[dbo].[ticketoffice_cashregister_moviment] ([id_ticketoffice_user],[id_ticketoffice_cashregister],[isopen],[amount],[type],[id_base],[codForPagto],[id_evento],[codVenda])
    SELECT tosc.id_ticketoffice_user,NULL,1,tosc.amount_topay,'refund',tosc.id_base,tosc.id_payment_type,ap.id_evento,@codVenda
    FROM CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosc
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON tosc.id_apresentacao=ap.id_apresentacao
    INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
    INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND tosc.indice=ls.Indice
    WHERE tosc.codVenda=@codVenda

    UPDATE csv
        SET statusingresso='E'
    FROM tabControleSeqVenda csv 
    INNER JOIN #helper h ON csv.CodApresentacao=h.CodApresentacao
    WHERE
        csv.Indice IN (SELECT indice FROM #indice)

    UPDATE tabMovCaixa 
        SET Saldo = COALESCE(Saldo - (CONVERT(DECIMAL(18,2),@amount)/100),0)
    WHERE CodCaixa = @CodCaixa
    AND StaMovimento = 'A'

    DELETE d
    FROM tabIngressoAgregados d
    INNER JOIN #indice h ON d.Indice=h.indice
    WHERE d.CodVenda=@codVenda

    DELETE d
    -- select *
    FROM tabIngresso d
    INNER JOIN #indice h ON d.Indice=h.indice
    WHERE d.CodVenda=@codVenda

    IF @all = 1
    BEGIN
        DELETE d
        FROM tabcomprovante d
        WHERE d.CodVenda=@codVenda
    END

    DELETE d
    FROM tabLugSala d
    INNER JOIN #helper h ON d.CodApresentacao=h.CodApresentacao AND d.Indice=h.Indice
    WHERE d.CodVenda=@codVenda

    IF @all = 1
    BEGIN
        DELETE d
        FROM CI_MIDDLEWAY..ticketoffice_gateway_result d
        INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosch ON d.id_ticketoffice_shoppingcart=tosch.id
        INNER JOIN #indice i ON tosch.indice=i.indice
        WHERE tosch.codVenda=@codVenda
    END

    DELETE d
    FROM CI_MIDDLEWAY..ticketoffice_shoppingcart_hist d
    INNER JOIN #indice i ON d.indice=i.indice
    WHERE d.codVenda=@codVenda
    
    INSERT INTO tabLancamento (NumLancamento, CodTipBilhete, CodTipLancamento, CodApresentacao, Indice,CodUsuario, CodForPagto, CodCaixa, DatMovimento, QtdBilhete, ValPagto, DatVenda, CodMovimento)
        SELECT NumLancamento, CodTipBilhete, 2, CodApresentacao, l.Indice, @CodUsuario, CodForPagto, @CodCaixa, @now, -1, COALESCE(ValPagto,0)*-1, GETDATE(), @CodMovimento
        FROM tabLancamento l
        INNER JOIN #indice i ON l.Indice=i.indice
        WHERE NumLancamento in (SELECT NumLancamento FROM #helper)

    IF @CodCliente IS NOT NULL
        INSERT INTO tabHisCliente (Codigo, NumLancamento, CodTipBilhete, CodTipLancamento, CodApresentacao, Indice)
            SELECT @CodCliente, l.NumLancamento, l.CodTipBilhete, 2, l.CodApresentacao, l.Indice
            FROM tabLancamento l
            WHERE l.NumLancamento in (SELECT NumLancamento FROM #helper)
            AND l.NumLancamento NOT IN (SELECT sub.NumLancamento FROM tabHisCliente sub WHERE sub.NumLancamento=l.NumLancamento AND sub.Indice=l.Indice AND sub.CodApresentacao=l.CodApresentacao )
    -- VALUES (@CodCliente, @NumLancamento, @CodTipBilhete, 2, @CodApresentacao, @Indice)

    SELECT
        1 success
        ,@transactionKey [key]
        ,@amount amount
    return;
END

SELECT 0 success
