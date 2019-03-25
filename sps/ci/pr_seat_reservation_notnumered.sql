-- exec sp_executesql N'EXEC pr_seat_reservation_notnumered @P1, @P2, @P3, @P4, @P5, @P6, @P7, @P8',N'@P1 int,@P2 nvarchar(4000),@P3 int,@P4 nvarchar(4000),@P5 int,@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000)',167779,N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',1,N'',15,N'',N'',N'0'
--exec sp_executesql N'EXEC pr_seat_reservation_notnumered @P1, @P2, @P3, @P4, @P5, @P6, @P7, @P8',N'@P1 int,@P2 nvarchar(4000),@P3 int,@P4 nvarchar(4000),@P5 int,@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000)',167779,N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',1,N'',15,N'RY64CCICBD',N'',N'1'

ALTER PROCEDURE dbo.pr_seat_reservation_notnumered (@id_apresentacao INT, @id VARCHAR(100), @qtd INT, @NIN VARCHAR(10), @minutesToExpire INT, @codReserva VARCHAR(100), @codCliente INT = NULL, @sellreservation BIT = 0)

AS

-- DECLARE @id_apresentacao INT = 167779
--         , @id VARCHAR(100) = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'
--         , @qtd INT = 1
--         , @NIN VARCHAR(10) = ''
--         , @minutesToExpire INT = 15
--         , @codReserva VARCHAR(100) = 'RY64CCICBD'
--         , @codCliente INT = ''
--         , @sellreservation BIT = 1

-- SELECT @id_apresentacao=166826
--         ,@id='8cc26a74-7e65-411e-b854-f7b281a46e01'
--         ,@qtd=6
--         ,@NIN=''
--         ,@minutesToExpire=5

SET NOCOUNT ON;
-- DECLARE @codPeca INT, @id_apresentacao INT, @indice INT, @id VARCHAR(100), @NIN VARCHAR(10), @minutesToExpire INT

-- SELECT
--     @codPeca=145
--     ,@id_apresentacao=166789
--     ,@indice=80847
--     ,@id='teste'


DECLARE @seatTaken BIT = 0
        ,@seatTakenByPackage BIT = 0
        ,@seatTakenTemp BIT = 0
        ,@seatTakenReserved BIT = 0
        ,@seatTakenBySite BIT = 0
        ,@seatqtdNotOk BIT = 0
        ,@limitedByPurchase BIT = 0
        ,@limitedByNIN BIT = 0
        ,@seatsTotal INT = 0
        ,@seatsTaken INT = 0
        ,@available INT = 0

DECLARE @codError_seatTaken INT = 1
        ,@codError_seatTakenByPackage INT = 2
        ,@codError_seatTakenByReservation INT = 3
        ,@codError_seatTakenByTemp INT = 4
        ,@codError_seatTakenBySite INT = 5
        ,@codError_limitedByPurchase INT = 6
        ,@codError_limitedByNIN INT = 7
        ,@codError_qtdNotOk INT = 8
        ,@codError_Fail INT = 10

IF @codCliente = 0 
    SET @codCliente=NULL

IF @codReserva = ''
    SET @codReserva = NULL

DECLARE @id_base INT
        ,@id_session VARCHAR(32) = replace(@id,'-','')
    

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

CREATE TABLE #result (indice INT, CodApresentacao INT, CodSala INT, ds_setor VARCHAR(100), ds_cadeira VARCHAR(100), codPeca INT)

IF (@sellreservation = 1 AND @codReserva IS NOT NULL)
BEGIN
    DECLARE @countavail INT

    SELECT @countavail = COUNT(*)
    FROM CI_MIDDLEWAY..mw_apresentacao ap
    INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
    INNER JOIN tabSala s ON a.CodSala=s.CodSala
    INNER JOIN tabSalDetalhe sd ON sd.CodSala=a.CodSala
    INNER JOIN tabSetor se ON a.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor
    INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND sd.Indice=ls.Indice
    WHERE sd.TipObjeto = 'C'
    AND ls.StaCadeira = 'R'
    AND ls.CodReserva = @codReserva
    AND ap.id_apresentacao=@id_apresentacao
    AND sd.Indice NOT IN (SELECT indice FROM CI_MIDDLEWAY..ticketoffice_indice_waiting sub WHERE sub.id_apresentacao=@id_apresentacao)

    IF (@countavail<@qtd)
    BEGIN
        SELECT
            1 as error
            ,'limit' info
            ,@codError_qtdNotOk code
        RETURN;
    END


    IF OBJECT_ID('tempdb.dbo.#indiceRemove', 'U') IS NOT NULL
        DROP TABLE #indiceRemove; 

    CREATE TABLE #indiceRemove (indice int, codApresentacao INT NULL);

    INSERT INTO #indiceRemove (indice, codApresentacao)
    SELECT TOP (@qtd)
    sd.Indice
    ,ap.CodApresentacao
    FROM CI_MIDDLEWAY..mw_apresentacao ap
    INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
    INNER JOIN tabSala s ON a.CodSala=s.CodSala
    INNER JOIN tabSalDetalhe sd ON sd.CodSala=a.CodSala
    INNER JOIN tabSetor se ON a.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor
    INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND sd.Indice=ls.Indice
    WHERE sd.TipObjeto = 'C'
    AND ls.StaCadeira = 'R'
    AND ls.CodReserva = @codReserva
    AND ap.id_apresentacao=@id_apresentacao
    AND sd.Indice NOT IN (SELECT indice FROM CI_MIDDLEWAY..ticketoffice_indice_waiting sub WHERE sub.id_apresentacao=@id_apresentacao)

    DELETE d
    FROM CI_MIDDLEWAY..mw_reserva d
    INNER JOIN #indiceRemove i ON d.id_cadeira=i.indice
    WHERE d.id_apresentacao=@id_apresentacao

    DELETE d
    FROM tabLugSala d
    INNER JOIN #indiceRemove i ON d.Indice=i.indice AND d.CodApresentacao=i.codApresentacao
    AND d.StaCadeira IN ('R')

    DELETE d
    FROM tabResCliente d
    INNER JOIN #indiceRemove i ON d.Indice=i.indice
    WHERE d.CodReserva=@codReserva COLLATE SQL_Latin1_General_CP1_CI_AS
END

INSERT INTO #result (indice, CodApresentacao, CodSala, ds_setor, ds_cadeira, codPeca)
SELECT TOP (@qtd)
    sd.Indice
    ,ap.CodApresentacao
    ,a.CodSala
    ,se.NomSetor
    ,sd.NomObjeto
    ,a.CodPeca
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON sd.CodSala=a.CodSala
INNER JOIN tabSetor se ON a.CodSala=se.CodSala
WHERE sd.TipObjeto = 'C'
AND sd.Indice NOT IN (SELECT indice FROM tabLugSala sub WHERE sub.CodApresentacao=ap.CodApresentacao)
AND ap.id_apresentacao=@id_apresentacao
AND sd.Indice NOT IN (SELECT indice FROM CI_MIDDLEWAY..ticketoffice_indice_waiting sub WHERE sub.id_apresentacao=@id_apresentacao)
ORDER BY NEWID()

INSERT INTO CI_MIDDLEWAY..ticketoffice_indice_waiting (indice, CodApresentacao, id_apresentacao, id_user)
SELECT r.indice, r.CodApresentacao, @id_apresentacao, @id
FROM #result r

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT DISTINCT 
@seatTaken = (SELECT COUNT(*) FROM tabLugSala sub WHERE sub.CodApresentacao=a.CodApresentacao)
,@seatsTotal = (SELECT 
    COUNT(*) 
    FROM tabSala sub 
    INNER JOIN tabSalDetalhe subSd ON sub.CodSala=subSd.CodSala AND subSd.TipObjeto = 'C'
    WHERE sub.CodSala=a.CodSala)
FROM tabPeca p
INNER JOIN tabApresentacao a ON p.CodPeca=a.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE ap.id_apresentacao=@id_apresentacao

SET @available = @seatsTotal-@seatTaken

DECLARE @countAux INT
SELECT @countAux = COUNT(*) FROM #result

IF @available < @qtd OR @countAux<>@qtd
BEGIN
    DELETE FROM CI_MIDDLEWAY..ticketoffice_indice_waiting WHERE id_user=@id AND id_apresentacao=@id_apresentacao

    SELECT
        1 as error
        ,'limit' info
        ,@codError_qtdNotOk code

    RETURN;
END


DECLARE @reserved INT = 1
        ,@totalByPurchase INT = 0

SELECT TOP 1
    @totalByPurchase=e.qt_ingr_por_pedido
FROM tabApresentacao a
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
WHERE ap.id_apresentacao=@id_apresentacao

SELECT 
    @reserved=COUNT(*)
FROM CI_MIDDLEWAY..mw_reserva r
WHERE r.id_apresentacao=@id_apresentacao AND r.id_session=@id

IF (@reserved+@qtd)>@totalByPurchase
BEGIN
    SELECT
        1 as error
        ,'purchase' info
        ,@codError_limitedByPurchase code
    RETURN;
END

IF @NIN IS NOT NULL
BEGIN
    DECLARE @reservedCPF INT = 1
            ,@purchasedCPF INT = 0
            ,@totalByCPF INT = 0
    SELECT 
        @purchasedCPF=COUNT(*)
        ,@totalByCPF=ISNULL(MAX(ISNULL(p.qt_ingressos_por_cpf,0)),0)
    FROM tabCliente c
    INNER JOIN tabHisCliente hc ON c.Codigo=hc.Codigo
    INNER JOIN tabApresentacao a ON hc.CodApresentacao=a.CodApresentacao
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
    INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
    WHERE ap.id_apresentacao=@id_apresentacao AND c.CPF=@NIN

    IF @totalByCPF > 0 AND (@purchasedCPF+@qtd)>=@totalByCPF
    BEGIN
        SELECT
            1 as error
            ,'cpf' info
            ,@codError_limitedByNIN code
        RETURN;
    END
    
END

DECLARE @codApresentacao INT
        -- ,@ds_setor VARCHAR(100)
        -- ,@ds_cadeira VARCHAR(100)

SELECT
    @codApresentacao=a.CodApresentacao
    -- ,@ds_cadeira=sd.NomObjeto
    -- ,@ds_setor=s.NomSala
FROM tabSalDetalhe sd
INNER JOIN tabApresentacao a ON sd.CodSala=a.CodSala
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN tabSala s ON sd.CodSala=s.CodSala
WHERE ap.id_apresentacao=@id_apresentacao --AND sd.Indice=@indice

DECLARE @codCaixa INT
        ,@codUsuario INT

SELECT
    @codCaixa=tub.codCaixa
    ,@codUsuario=tub.codUsuario
FROM CI_MIDDLEWAY..ticketoffice_user_base tub
WHERE tub.id_ticketoffice_user=@id
AND tub.id_base=@id_base

INSERT INTO CI_MIDDLEWAY..mw_reserva (ID_APRESENTACAO,ID_CADEIRA,DS_CADEIRA,DS_SETOR,ID_SESSION,DT_VALIDADE) 
--VALUES (@id_apresentacao,@indice,@ds_cadeira,@ds_setor,@id_session,DATEADD(MI, @minutesToExpire, GETDATE()))
SELECT @id_apresentacao, r.indice, r.ds_cadeira, r.ds_setor, @id_session, DATEADD(MI, @minutesToExpire, GETDATE())
FROM #result r


INSERT INTO TABLUGSALA (CODAPRESENTACAO,INDICE,CODTIPBILHETE,CODCAIXA,CODVENDA,STAIMPRESSAO,STACADEIRA,CODUSUARIO,CODRESERVA,ID_SESSION)
--VALUES (@codApresentacao, @indice, NULL,@codCaixa,NULL, 0, 'T', @codUsuario, NULL, @id_session)
SELECT @codApresentacao, r.indice, NULL, @codCaixa,NULL, 0, 'T', @codUsuario, NULL, @id_session
FROM #result r

DECLARE @PerDesconto DECIMAL(19,2) = 0

DECLARE @amount INT
        ,@amount_topay INT

SELECT
    @amount=CONVERT(INT,REPLACE(CONVERT(VARCHAR(30),(CONVERT(DECIMAL(19,2),a.ValPeca))),'.',''))
    ,@PerDesconto=se.PerDesconto
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON s.CodSala=se.CodSala
WHERE ap.id_apresentacao=@id_apresentacao

SET @amount_topay=@amount-((@PerDesconto/100)*@amount)


IF @codCliente IS NOT NULL
BEGIN
    INSERT INTO tabResCliente (codCliente,CodREserva,Indice,TipLancamento)
        SELECT @CodCliente ,@CodReserva , ls.Indice, 1  
        FROM tablugsala ls 
        INNER JOIN #result i ON ls.Indice=i.indice
        WHERE ls.CodCaixa = @CodCaixa and (ls.stacadeira = 'T' OR ls.stacadeira = 'M')

    UPDATE ls
    SET	ls.StaCadeira = 'R', 
        ls.CodUsuario = @CodUsuario ,
        ls.CodReserva = @CodReserva
    FROM tabLugSala ls
    INNER JOIN #result i ON ls.Indice=i.indice
    WHERE ls.CodCaixa = @CodCaixa and (ls.stacadeira = 'T' OR ls.stacadeira = 'M')
END


INSERT INTO CI_MIDDLEWAY..ticketoffice_shoppingcart (id_ticketoffice_user,id_event,id_base,id_apresentacao,indice,quantity,currentStep,id_payment_type,amount,amount_discount,amount_topay)
SELECT @id, r.codPeca, @id_base, @id_apresentacao, r.indice, 1, 'step1', NULL, @amount, 0, @amount_topay
FROM #result r

DELETE FROM CI_MIDDLEWAY..ticketoffice_indice_waiting WHERE id_user=@id AND id_apresentacao=@id_apresentacao

SELECT
    0 error
    ,'' info
    ,NULL code