-- exec sp_executesql N'EXEC pr_seat_reservation_multi @P1, @P2, @P3, @P4, @P5, @P6, @P7, @P8',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 int,@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000)',N'167857',N'4097,4098,4147,4148',N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',N'',15,N'19318',N'RX6DGGICAH',N'0'

ALTER PROCEDURE dbo.pr_seat_reservation_multi (@id_apresentacao INT, @indice VARCHAR(MAX), @id VARCHAR(100), @NIN VARCHAR(10), @minutesToExpire INT, @codCliente INT = NULL, @codReserva VARCHAR(10) = NULL, @overwrite BIT = 0)
AS

-- DECLARE @id_apresentacao INT, @indice VARCHAR(MAX), @id VARCHAR(100), @NIN VARCHAR(10), @minutesToExpire INT, @codCliente INT = NULL, @codReserva VARCHAR(10) = NULL
--         ,@overwrite BIT = 0

-- SELECT
--     @id_apresentacao=167856
--     ,@indice='1797'
--     ,@id='f2177e5e-f727-4906-948d-4eea9b9bbd0e'
--     ,@minutesToExpire=15
--     ,@NIN=''
--     ,@codCliente=''
--     ,@codReserva=''
--     ,@overwrite=1

SET NOCOUNT ON;

IF @codCliente = 0 
    SET @codCliente=NULL

IF @codReserva = ''
    SET @codReserva = NULL


DECLARE @id_base INT
        ,@id_session VARCHAR(32) = replace(@id,'-','')
        ,@trytodelete BIT = 0
        ,@deletebecauseoverwrite BIT = 0

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

IF OBJECT_ID('tempdb.dbo.#indice', 'U') IS NOT NULL
    DROP TABLE #indice; 

CREATE TABLE #indice (indice int, seatTaken BIT, seatTakenByPackage BIT, seatTakenTemp BIT
                    , seatTakenReserved BIT, seatTakenBySite BIT, limitedByPurchase BIT
                    , limitedByNIN BIT, hasError BIT, ds_cadeira VARCHAR(1000) NULL
                    , ds_setor VARCHAR(1000) NULL, codApresentacao INT NULL, isAdd BIT, codPeca INT
                    , needoverwrite BIT, codReservaSaved VARCHAR(100), isme BIT
                    , deletefromquota BIT);

INSERT INTO #indice (indice,seatTaken,seatTakenByPackage,seatTakenTemp,seatTakenReserved,seatTakenBySite,limitedByPurchase,limitedByNIN, hasError, ds_cadeira, ds_setor, codApresentacao, isAdd, codPeca, needoverwrite, codReservaSaved, isme,deletefromquota)
    SELECT Item,0,0,0,0,0,0,0,0,NULL,NULL,NULL,1,0,0,'',0,0 FROM dbo.splitString(@indice, ',')

UPDATE i
SET i.ds_cadeira=sd.NomObjeto
    ,i.ds_setor=s.NomSala
    ,i.codApresentacao=a.CodApresentacao
    ,i.codPeca=a.CodPeca
FROM tabSalDetalhe sd
INNER JOIN tabApresentacao a ON sd.CodSala=a.CodSala
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN tabSala s ON sd.CodSala=s.CodSala
INNER JOIN #indice i ON sd.Indice=i.indice AND i.hasError=0
WHERE ap.id_apresentacao=@id_apresentacao

UPDATE i
SET i.codReservaSaved=ls.CodReserva
FROM #indice i
INNER JOIN tabLugSala ls ON i.indice=ls.Indice AND i.codApresentacao=ls.CodApresentacao
WHERE ls.StaCadeira='R'

UPDATE i
SET i.isAdd=0
    ,i.isme=1
FROM #indice i
INNER JOIN tabLugSala ls ON i.indice=ls.Indice AND i.codApresentacao=ls.CodApresentacao
WHERE ls.id_session=@id_session

UPDATE i
SET i.needoverwrite=1
FROM #indice i
INNER JOIN tabLugSala ls ON i.indice=ls.Indice AND i.codApresentacao=ls.CodApresentacao
WHERE ls.StaCadeira='R'

UPDATE i
SET i.deletefromquota=1
FROM #indice i
INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpp ON i.indice=qpp.indice AND qpp.id_apresentacao=@id_apresentacao

SELECT TOP 1 @trytodelete=1 FROM #indice WHERE isAdd=0

DELETE d
FROM CI_MIDDLEWAY..quota_partner_reservation d
INNER JOIN #indice i ON d.Indice=i.indice AND d.id_apresentacao=@id_apresentacao
AND i.deletefromquota=1

IF @overwrite = 1
BEGIN
    SELECT TOP 1 @deletebecauseoverwrite=1 FROM #indice WHERE needoverwrite=1
END

IF @deletebecauseoverwrite = 1
BEGIN
    DELETE d
    FROM CI_MIDDLEWAY..mw_reserva d
    INNER JOIN #indice i ON d.id_cadeira=i.indice
    WHERE d.id_apresentacao=@id_apresentacao
    AND i.needoverwrite=1

    DELETE d
    FROM tabLugSala d
    INNER JOIN #indice i ON d.Indice=i.indice AND d.CodApresentacao=i.codApresentacao
    AND d.StaCadeira IN ('R')
    AND i.needoverwrite=1

    DELETE d
    FROM tabResCliente d
    INNER JOIN #indice i ON d.Indice=i.indice
    WHERE d.CodReserva=i.codReservaSaved COLLATE SQL_Latin1_General_CP1_CI_AS
    AND i.needoverwrite=1
END

IF @trytodelete = 1
BEGIN
    DELETE d
    FROM CI_MIDDLEWAY..mw_reserva d
    INNER JOIN #indice i ON d.id_cadeira=i.indice
    WHERE d.id_apresentacao=@id_apresentacao
    AND d.id_session=@id_session
    AND i.isAdd=0

    DELETE d
    FROM tabLugSala d
    INNER JOIN #indice i ON d.Indice=i.indice
    WHERE d.CodApresentacao=i.codApresentacao
    AND d.id_session=@id_session
    AND d.StaCadeira IN ('T', 'R')
    AND i.isAdd=0

    DELETE d
    FROM tabResCliente d
    INNER JOIN #indice i ON d.Indice=i.indice
    WHERE d.CodReserva=@codReserva 
    AND i.isAdd=0

    DELETE d
    FROM CI_MIDDLEWAY..ticketoffice_shoppingcart d
    INNER JOIN #indice i ON d.indice=i.indice
    WHERE d.id_apresentacao=@id_apresentacao
    AND d.id_ticketoffice_user=@id

END


IF @overwrite = 1
BEGIN
    UPDATE #indice SET isAdd=1;
END

-- UPDATE #indice SET isAdd=1;

-- UPDATE i
-- SET i.isAdd=0
--     ,i.isme=1
-- FROM #indice i
-- INNER JOIN tabLugSala ls ON i.indice=ls.Indice AND i.codApresentacao=ls.CodApresentacao
-- WHERE ls.id_session=@id_session


DECLARE @codError_seatTaken INT = 1
        ,@codError_seatTakenByPackage INT = 2
        ,@codError_seatTakenByReservation INT = 3
        ,@codError_seatTakenByTemp INT = 4
        ,@codError_seatTakenBySite INT = 5
        ,@codError_limitedByPurchase INT = 6
        ,@codError_limitedByNIN INT = 7
        ,@codError_Fail INT = 10
---------------------------------- Check if seat has been taken
UPDATE i
SET i.seattaken=1,i.hasError=1
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN #indice i ON ls.indice=i.indice
WHERE 
    ap.id_apresentacao=@id_apresentacao AND ls.StaCadeira='V'
    AND i.isAdd=1
---------------------------------- Check if seat has been taken reserved
UPDATE i
SET i.seatTakenReserved=1,i.hasError=1 
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN #indice i ON ls.indice=i.indice
WHERE 
    ap.id_apresentacao=@id_apresentacao AND ls.StaCadeira='R'-- AND ls.id_session!=@id_session
    AND i.isAdd=1
---------------------------------- Check if seat has been taken reserved
UPDATE i
SET i.seatTakenTemp=1,i.hasError=1 
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN #indice i ON ls.indice=i.indice
WHERE 
    ap.id_apresentacao=@id_apresentacao AND ls.StaCadeira='T'
    AND i.isAdd=1
---------------------------------- Check if seat has been taken by site
UPDATE i
SET i.seatTakenBySite=1,i.hasError=1 
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN #indice i ON r.id_cadeira=i.indice
WHERE r.id_apresentacao=@id_apresentacao
AND i.isAdd=1
---------------------------------- Check if seat has been taken
UPDATE i
SET i.seatTakenByPackage=1,i.hasError=1 
FROM CI_MIDDLEWAY..mw_pacote_reserva r
INNER JOIN CI_MIDDLEWAY..mw_pacote_apresentacao a ON r.id_pacote=a.id_pacote
INNER JOIN #indice i ON r.id_cadeira=i.indice
WHERE a.id_apresentacao=@id_apresentacao
AND i.isAdd=1

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

IF @reserved>@totalByPurchase
BEGIN
    UPDATE #indice SET limitedByPurchase=1,hasError=1 WHERE isAdd=1
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

    IF @totalByCPF > 0 AND @purchasedCPF>=@totalByCPF
    BEGIN
        UPDATE #indice SET limitedByNIN=1,hasError=1 WHERE isAdd=1
    END
    
END

DECLARE @hasOk BIT = 0
SELECT @hasOk=1 FROM #indice WHERE hasError=0 AND isAdd=1

DECLARE @codCaixa INT
        ,@codUsuario INT

SELECT
    @codCaixa=tub.codCaixa
    ,@codUsuario=tub.codUsuario
FROM CI_MIDDLEWAY..ticketoffice_user_base tub
WHERE tub.id_ticketoffice_user=@id
AND tub.id_base=@id_base

IF @codCliente IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..mw_reserva (ID_APRESENTACAO,ID_CADEIRA,DS_CADEIRA,DS_SETOR,ID_SESSION,DT_VALIDADE) 
    SELECT @id_apresentacao, indice, ds_cadeira, ds_setor, @id_session,DATEADD(MI, @minutesToExpire, GETDATE())
    FROM #indice
    WHERE hasError=0
    AND isAdd=1
END

INSERT INTO TABLUGSALA (CODAPRESENTACAO,INDICE,CODTIPBILHETE,CODCAIXA,CODVENDA,STAIMPRESSAO,STACADEIRA,CODUSUARIO,CODRESERVA,ID_SESSION)
    SELECT codApresentacao, indice, NULL, @codCaixa,NULL,0,'T',@codUsuario, NULL, @id_session
    FROM #indice
    WHERE hasError=0
    AND isAdd=1

IF @codCliente IS NOT NULL
BEGIN
    DECLARE @id_quotapartner UNIQUEIDENTIFIER = NULL
    SELECT @id_quotapartner = id_quotapartner FROM tabCliente WHERE Codigo=@codCliente

    IF @id_quotapartner IS NOT NULL
    BEGIN
        INSERT INTO CI_MIDDLEWAY.[dbo].[quota_partner_reservation] (id_apresentacao, indice, id_quotapartner, codReserva)
        SELECT @id_apresentacao, i.indice, @id_quotapartner, @codReserva
        FROM #indice i
        WHERE i.deletefromquota=0
    END

    INSERT INTO tabResCliente (codCliente,CodREserva,Indice,TipLancamento)
        SELECT @CodCliente ,@CodReserva , ls.Indice, 1  
        FROM tablugsala ls 
        INNER JOIN #indice i ON ls.Indice=i.indice
        WHERE ls.CodCaixa = @CodCaixa and (ls.stacadeira = 'T' OR ls.stacadeira = 'M')
        AND i.hasError=0
        AND i.isAdd=1

    UPDATE ls
    SET	ls.StaCadeira = 'R', 
        ls.CodUsuario = @CodUsuario ,
        ls.CodReserva = @CodReserva
    FROM tabLugSala ls
    INNER JOIN #indice i ON ls.Indice=i.indice
    WHERE ls.CodCaixa = @CodCaixa and (ls.stacadeira = 'T' OR ls.stacadeira = 'M')
    AND i.hasError=0
    AND i.isAdd=1
END


INSERT INTO CI_MIDDLEWAY.[dbo].[ticketoffice_reservation] ([id_apresentacao],[indice],[id_ticketoffice_user], codReserva)
SELECT @id_apresentacao, i.indice, @id, @codReserva
FROM #indice i

DECLARE @amount INT = NULL, @amount_discount INT = NULL, @amount_topay INT = NULL
        ,@PerDesconto DECIMAL(19,2) = 0

SELECT
    @amount=CONVERT(INT,REPLACE(CONVERT(VARCHAR(30),(CONVERT(DECIMAL(19,2),a.ValPeca))),'.',''))
    ,@PerDesconto=se.PerDesconto
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON s.CodSala=se.CodSala
WHERE ap.id_apresentacao=@id_apresentacao

SET @amount_topay=@amount-((@PerDesconto/100)*@amount)

INSERT INTO CI_MIDDLEWAY..ticketoffice_shoppingcart (id_ticketoffice_user,id_event,id_base
    ,id_apresentacao,indice,quantity
    ,currentStep,id_payment_type,amount,amount_discount
    ,amount_topay)
SELECT @id,i.codPeca,@id_base
        ,@id_apresentacao, i.indice, 1
        ,'step2',NULL,@amount,@amount_discount
        ,@amount_topay
FROM #indice i
WHERE i.isAdd=1 AND i.hasError=0

DECLARE @total INT
        ,@totalError INT

SELECT @totalError = SUM(1) FROM #indice WHERE hasError=1
SELECT @total = SUM(1) FROM #indice


SELECT indice
    ,seatTaken
    ,seatTakenByPackage
    ,seatTakenTemp
    ,seatTakenReserved
    ,seatTakenBySite
    ,limitedByPurchase
    ,limitedByNIN
    ,hasError
    ,ds_cadeira
    ,ds_setor
    ,isAdd
    ,(CASE WHEN @totalError>0 THEN 1 ELSE 0 END) hasanyerror
    ,(CASE WHEN @total-@totalError=0 THEN 1 ELSE 0 END) alliserror
FROM #indice


