-- exec sp_executesql N'EXEC pr_api_sell @P1,@P2,@P3,@P4,@P5',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 char(1),@P5 nvarchar(4000)',N'J8B9K533OOG8KY8',N'79#1|88#7',N'601',N'19344',N'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f'
ALTER PROCEDURE pr_api_sell (@id_session VARCHAR(100)
         ,@seats VARCHAR(MAX)
        ,@id_payment INT
        ,@codCliente INT = NULL
        ,@qpcode VARCHAR(1000) = NULL
        ,@bin VARCHAR(10) = NULL)

AS

-- DECLARE @id_session VARCHAR(100) = 'J5668O71GACF8PO'
--          ,@id_payment INT = '601'
--         ,@seats VARCHAR(MAX) = '87#1|85#7'
--         ,@isComplementoMeia BIT = 0
--         ,@codCliente INT = 19344
--         ,@qpcode VARCHAR(1000) = 'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#seats', 'U') IS NOT NULL
    DROP TABLE #seats; 

IF OBJECT_ID('tempdb.dbo.#data_bases_2', 'U') IS NOT NULL
    DROP TABLE #data_bases_2; 

CREATE TABLE #seats (id INT, tickettype INT);

CREATE TABLE #data_bases_2 (id_event INT
                            ,base INT
                            ,id_presentantion INT
                            ,id_ticket INT
                            ,sectorName VARCHAR(1000)
                            ,sectorDiscount DECIMAL(16,4)
                            ,seatName VARCHAR(1000)
                            ,id_seat INT
                            ,price INT
                            ,allowticketoffice BIT
                            ,allowweb BIT
                            ,PerDesconto DECIMAL(16,4)
                            ,ticketType VARCHAR(1000)
                            ,sell_sun BIT
                            ,sell_mon BIT
                            ,sell_tue BIT
                            ,sell_wed BIT
                            ,sell_thu BIT
                            ,sell_fri BIT
                            ,sell_sat BIT)


INSERT INTO #data_bases_2
EXEC CI_MIDDLEWAY..pr_api_tickets_list @qpcode, NULL;

INSERT INTO #seats (id, tickettype)
    SELECT SUBSTRING(Item,1,CHARINDEX('#',Item)-1), CONVERT(INT,SUBSTRING(Item,CHARINDEX('#',Item)+1,LEN(Item))) FROM dbo.splitString(@seats, '|')


DECLARE @id_quotapartner UNIQUEIDENTIFIER

SELECT @id_quotapartner = qp.id FROM CI_MIDDLEWAY..quota_partner qp WHERE qp.[key]=@qpcode

BEGIN TRY

  BEGIN TRANSACTION sell

  DECLARE @NumeroBIN VARCHAR(100) = NULL

IF @codCliente IS NOT NULL
BEGIN
    IF LTRIM(RTRIM(@codCliente)) = '' OR LTRIM(RTRIM(@codCliente)) = 'null'
        SET @codCliente = NULL
END

DECLARE @now DATETIME = GETDATE()
        ,@codVenda VARCHAR(10) = NULL

DECLARE @cliente_Nome VARCHAR(1000) = '', @cliente_DDD VARCHAR(3) = '', @cliente_Telefone VARCHAR(50) = '', @cliente_Ramal VARCHAR(4) = '', @cliente_CPF VARCHAR(14) = '', @cliente_RG VARCHAR(15) = ''

DECLARE @NomeEmpresa VARCHAR(100)
        ,@Id_Cartao_patrocinado INT
        ,@id_base INT
        ,@idpedidovenda BIGINT
        ,@isComplementoMeia BIT = 1

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT @NomeEmpresa=NomEmpresa FROM tabEmpresa


IF @codVenda IS NULL
BEGIN
    IF OBJECT_ID('tempdb.dbo.#idpedidovenda', 'U') IS NOT NULL
        DROP TABLE #idpedidovenda; 
    IF OBJECT_ID('tempdb.dbo.#codVendaTemp', 'U') IS NOT NULL
        DROP TABLE #codVendaTemp; 

    DECLARE @userHelp VARCHAR(100) = CONVERT(VARCHAR(100),@id_session)

    CREATE TABLE #idpedidovenda (id bigint);
    CREATE TABLE #codVendaTemp (codVenda VARCHAR(10));

    INSERT INTO #idpedidovenda EXEC CI_MIDDLEWAY..seqPedidoVenda @userHelp;

    SELECT @idpedidovenda=id FROM #idpedidovenda

    INSERT INTO #codVendaTemp EXEC CI_MIDDLEWAY..seqCodVenda @idpedidovenda;

    SELECT @codVenda=codVenda FROM #codVendaTemp
END

DECLARE @codCaixa INT = 0, @codUsuario INT = 255
        ,@codMovimento INT,@CodTipLancamento INT
        ,@name VARCHAR(1000), @login VARCHAR(1000)
        ,@id_payment_type INT, @id_meio_pagamento INT

SELECT @codMovimento=Codmovimento
FROM tabMovCaixa
WHERE CodCaixa=@codCaixa AND CodUsuario=@codUsuario AND StaMovimento='A'

SELECT @id_payment_type = codforpagto 
        ,@id_meio_pagamento=mp.id_meio_pagamento
from CI_MIDDLEWAY..mw_meio_pagamento mp
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento mpfp	on mpfp.id_base = @id_base and mpfp.id_meio_pagamento = mp.id_meio_pagamento
WHERE
	mp.cd_meio_pagamento = @id_payment

UPDATE ls
SET ls.StaCadeira='V'
    ,ls.CodTipBilhete=ab.CodTipBilhete
    ,ls.CodVenda=@codVenda
    ,ls.CodUsuario=@codUsuario
    ,ls.id_quotapartner = @id_quotapartner
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_reserva r ON ls.id_session=r.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND r.id_apresentacao=ap.id_apresentacao AND r.id_cadeira=ls.Indice
INNER JOIN #seats ss ON ls.Indice=ss.id
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON r.id_apresentacao_bilhete=ab.id_apresentacao_bilhete AND ab.in_ativo=1 AND ss.tickettype=ab.CodTipBilhete
WHERE ls.id_session=@id_session
AND e.id_base=@id_base


DECLARE @NumLancamento INT
SELECT @NumLancamento = (SELECT COALESCE(MAX(NumLancamento),0)+1 FROM tabLancamento)

INSERT INTO tabLancamento (NumLancamento,CodTipBilhete,CodTipLancamento,CodApresentacao,Indice,CodUsuario,CodForPagto,CodCaixa,DatMovimento,QtdBilhete,ValPagto, DatVenda, CodMovimento, cardbin)
    SELECT  DISTINCT
        @NumLancamento
        ,ab.CodTipBilhete
        ,(CASE WHEN ISNULL(ls.StaCadeiraComplMeia, 'T') = 'M' THEN 4 ELSE 1 END)
        ,a.CodApresentacao
        ,r.id_cadeira
        ,@codUsuario
        ,@id_payment_type
        ,@codCaixa
        ,CONVERT(SMALLDATETIME,CONVERT(VARCHAR(8), @now,112) + ' ' + LEFT(CONVERT(VARCHAR, @now,114),8))
        ,1
        ,CONVERT(DECIMAL(18,2),db.price)/100
        ,@now
        ,@codMovimento
        ,@bin
    FROM CI_MIDDLEWAY..mw_reserva r
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
    INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
    INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
    INNER JOIN #seats ss ON ls.Indice=ss.id
    INNER JOIN #data_bases_2 db ON db.id_presentantion=r.id_apresentacao AND db.id_seat=r.id_cadeira AND ss.tickettype=db.id_ticket
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete ab ON r.id_apresentacao_bilhete=ab.id_apresentacao_bilhete AND ab.in_ativo=1 AND ss.tickettype=ab.CodTipBilhete
    WHERE ls.id_session=@id_session

    
-- return
IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

CREATE TABLE #helper (indice int, id_apresentacao int, codapresentacao int, numLancamento INT NULL, id_session VARCHAR(100), CodTipLancamento INT)

SELECT @cliente_Nome=c.Nome,@cliente_DDD=c.DDD, @cliente_Telefone=Telefone, @cliente_Ramal=Ramal, @cliente_CPF=CPF, @cliente_RG=RG FROM tabCliente c WHERE Codigo=@codCliente

INSERT INTO #helper (indice, id_apresentacao, codapresentacao, numLancamento, id_session, CodTipLancamento)
    SELECT r.id_cadeira, r.id_apresentacao, a.CodApresentacao, @NumLancamento, r.id_session, 1
    FROM CI_MIDDLEWAY..mw_reserva r
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
    INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
    -- LEFT JOIN tabLancamento l ON ap.CodApresentacao=l.CodApresentacao AND tosc.indice=l.Indice    
    WHERE r.id_session=@id_session

IF (@codCliente IS NOT NULL)
BEGIN
    INSERT INTO tabHisCliente (Codigo,NumLancamento,CodTipBilhete,CodTipLancamento,CodApresentacao,Indice)
        SELECT
        @codCliente
        ,h.numLancamento
        ,ss.tickettype
        ,h.CodTipLancamento
        ,h.codapresentacao
        ,h.indice
        FROM #helper h
        INNER JOIN #seats ss ON h.indice=ss.id
        -- INNER JOIN #data_bases_2 db ON ss.id=db.id_seat AND db.id_ticket=ss.tickettype
END

INSERT INTO tabComprovante
	(CodVenda,TipDocumento,NomSala,
	Nome,Numero,DatValidade,
	DDD,Telefone,Ramal,
    CPF,RG,ForPagto,
	NomUsuario,StaImpressao,NomEmpresa,
	CodCliente,CodApresentacao,CodPeca)
SELECT TOP 1
    @codVenda,'V',s.NomSala
    ,@cliente_Nome,@NumeroBIN,''
    ,@cliente_DDD,@cliente_Telefone,@cliente_Ramal
    ,@cliente_CPF,@cliente_RG, @id_payment_type
    ,@name,0,@NomeEmpresa
    ,@codCliente,h.codapresentacao,a.CodPeca
FROM #helper h
INNER JOIN tabApresentacao a ON h.codapresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.codPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala

INSERT INTO tabControleSeqVenda (codapresentacao, indice, numseq, codbar, statusingresso)
SELECT 
    h.codapresentacao
    ,h.indice
    ,1
    ,
right('00000'+convert(varchar,h.codapresentacao),5) --5
+convert(char(1), sd.CodSetor) --6
+right('0000'+replace(convert(varchar(5),a.HorSessao),':',''),4) --10
+right('00000'+convert(varchar(10),h.indice),5) --15
+LEFT(CONVERT(VARCHAR(100),right(cast(rand(checksum(newid())) as decimal(15, 15)), 6)),6) --21
    ,'L'
FROM #helper h
INNER JOIN tabApresentacao a ON h.codapresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON sd.Indice=h.indice AND sd.CodSala=a.CodSala


INSERT INTO tabIngresso	(Indice,CodVenda,NomObjeto
,NomPeca,NomRedPeca,DatApresentacao
,HorSessao,Elenco,Autor
,Diretor,NomRedSala,TipBilhete
,ValPagto,CodCaixa,[Login]
,NomResPeca,CenPeca,NomSetor
,DatVenda,Qtde,PerDesconto
,StaImpressao,CodSala,Id_Cartao_patrocinado
,BINCartao)
SELECT 
h.indice,@codVenda
,SUBSTRING(sd.NomObjeto,1,10)
,SUBSTRING(p.NomPeca,1,35),SUBSTRING(p.NomRedPeca,1,35),a.DatApresentacao
,SUBSTRING(a.HorSessao,1,5),SUBSTRING(p.Elenco,1,50),SUBSTRING(p.Autor,1,50)
,SUBSTRING(p.Diretor,1,50),SUBSTRING(s.NomRedSala,1,6),SUBSTRING(tb.TipBilhete,1,20)
,(CONVERT(DECIMAL(18,2),db.price)/100),@codCaixa,SUBSTRING('api', 0, 10)
,SUBSTRING(p.NomResPeca,0,6),p.CenPeca,SUBSTRING(se.NomSetor,1,26)
,@now, 1,tb.PerDesconto
,0,s.CodSala,(SELECT TOP 1 ep.id_cartao_patrocinado FROM CI_MIDDLEWAY..mw_evento_patrocinado ep WHERE ep.CodPeca=a.CodPeca AND ep.id_base=@id_base AND convert(varchar, a.datapresentacao,112) between convert(varchar, ep.dt_inicio,112) and convert(varchar, ep.dt_fim ,112))-- ep.id_cartao_patrocinado
,@NumeroBIN
FROM #helper h
INNER JOIN #seats ss ON h.indice=ss.id
INNER JOIN #data_bases_2 db ON ss.id=db.id_seat AND ss.tickettype=db.id_ticket AND h.id_apresentacao=db.id_presentantion
INNER JOIN CI_MIDDLEWAY..mw_reserva r ON r.id_cadeira=db.id_seat AND r.id_apresentacao=db.id_presentantion AND r.id_session=@id_session
INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON r.id_apresentacao_bilhete=apb.id_apresentacao_bilhete AND ss.tickettype=apb.CodTipBilhete
INNER JOIN tabApresentacao a ON h.codapresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON s.CodSala=sd.CodSala AND h.indice=sd.Indice
INNER JOIN tabSetor se ON sd.CodSetor=se.CodSetor AND a.CodSala=se.CodSala
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete

DECLARE @CodLog INT
SELECT @CodLog = (SELECT COALESCE(MAX(IdLogOperacao),0)+1 FROM tabLogOperacao)

INSERT INTO tabLogOperacao (IdLogOperacao, DatOperacao, CodUsuario, Operacao) 
SELECT TOP 1
@CodLog
,@now
,@codUsuario
,'Venda de Ingressos - espetáculo '+ p.NomPeca + '  Dt.:' + convert(varchar(10),@now,103) + ' Cod.Venda:' + @codVenda
FROM #helper h
INNER JOIN tabApresentacao a ON h.codapresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca

DECLARE @nextStep VARCHAR(100)
        ,@isMoney BIT
        ,@isFree BIT
        ,@isCreditCard BIT
        ,@isDebitCard BIT
        ,@PagarMe BIT


DELETE FROM CI_MIDDLEWAY..mw_reserva WHERE id_session=@id_session

SELECT 0 hasError, @codVenda codVenda, @idpedidovenda id_pedido_venda


  COMMIT TRANSACTION sell
END TRY
BEGIN CATCH 
  IF (@@TRANCOUNT > 0)
   BEGIN
      ROLLBACK TRANSACTION sell
   END 
    SELECT
        1 hasError,
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH