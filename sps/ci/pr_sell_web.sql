ALTER PROCEDURE pr_sell_web (@id_cliente INT
        ,@totalAmount INT
        ,@id_pedido_venda INT
        ,@cd_meio_pagamento INT
        ,@ID_PEDIDO_IPAGARE	VARCHAR(36)
        ,@CD_NUMERO_AUTORIZACAO VARCHAR(50)
        ,@CD_NUMERO_TRANSACAO VARCHAR(50)
        ,@NR_CARTAO_CREDITO VARCHAR(16))

AS

SET NOCOUNT ON;

-- USE CI_MIDDLEWAY
-- USE CI_LOCALHOST

DECLARE @codUsuario INT = 255 -- usuario web
        ,@codCaixa INT = 0
        ,@in_retira_entrega VARCHAR(20) = NULL
        ,@id_usuario_callcenter INT = NULL
        ,@codForPagto INT
        ,@id_base INT
        ,@CodTipLancamento INT
        ,@quantity INT
        ,@id_meio_pagamento INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT @quantity=COUNT(1) 
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE csc.id_cliente=@id_cliente

SET @codCaixa = (CASE WHEN @id_usuario_callcenter IS NOT NULL THEN (CASE WHEN @in_retira_entrega <> 'R' THEN 252 ELSE 254 END)
                                                              ELSE (CASE WHEN @in_retira_entrega <> 'R' THEN 253 ELSE 255 END) END)

SELECT @in_retira_entrega = pv.in_retira_entrega
        ,@id_usuario_callcenter = pv.id_usuario_callcenter
FROM CI_MIDDLEWAY..mw_pedido_venda pv
WHERE pv.id_pedido_venda=@id_pedido_venda

SELECT @codforpagto = codforpagto 
        ,@id_meio_pagamento=mp.id_meio_pagamento
from CI_MIDDLEWAY..mw_meio_pagamento mp
INNER JOIN CI_MIDDLEWAY..mw_meio_pagamento_forma_pagamento mpfp	on mpfp.id_base = @id_base and mpfp.id_meio_pagamento = mp.id_meio_pagamento
WHERE
	mp.cd_meio_pagamento = @cd_meio_pagamento

BEGIN TRY

--  BEGIN TRANSACTION sellweb

  DECLARE @cliente_Nome VARCHAR(1000) = ''
        , @cliente_DDD VARCHAR(3) = ''
        , @cliente_Telefone VARCHAR(50) = ''
        , @cliente_Ramal VARCHAR(4) = ''
        , @cliente_CPF VARCHAR(14) = ''
        , @cliente_RG VARCHAR(15) = ''
        , @codCliente INT = NULL

SELECT @cliente_CPF = SUBSTRING(c.cd_cpf, 1, 14)
        ,@cliente_Nome = SUBSTRING(c.ds_nome + ' ' + c.ds_sobrenome, 1, 1000)
        ,@cliente_RG = SUBSTRING(c.cd_rg, 1, 15)
        ,@cliente_DDD = SUBSTRING((CASE WHEN c.ds_ddd_telefone IS NULL OR c.ds_ddd_telefone = '' THEN c.ds_ddd_celular ELSE c.ds_ddd_telefone END), 1, 10)
        ,@cliente_Telefone = SUBSTRING((CASE WHEN c.ds_telefone IS NULL OR c.ds_telefone = '' THEN c.ds_celular ELSE c.ds_telefone END), 1, 20)
FROM CI_MIDDLEWAY..mw_cliente c
WHERE c.id_cliente=@id_cliente

SELECT @codCliente = c.Codigo FROM tabCliente c
WHERE c.CPF=@cliente_CPF

IF @codCliente IS NULL
BEGIN
    INSERT INTO tabcliente (nome, rg, cpf, ddd, telefone,stacliente)
    SELECT @cliente_Nome, @cliente_RG, @cliente_CPF, @cliente_DDD, @cliente_Telefone, 'A'

    SELECT @codCliente=SCOPE_IDENTITY()
END

DECLARE @now DATETIME = GETDATE()
        ,@codVenda VARCHAR(10) = NULL


DECLARE @NomeEmpresa VARCHAR(100)
        ,@Id_Cartao_patrocinado INT
        ,@idpedidovenda BIGINT

SELECT @NomeEmpresa=NomEmpresa FROM tabEmpresa

IF @codVenda IS NULL
BEGIN
    IF OBJECT_ID('tempdb.dbo.#codVendaTemp', 'U') IS NOT NULL
        DROP TABLE #codVendaTemp; 

    DECLARE @userHelp VARCHAR(100) = CONVERT(VARCHAR(100),@id_cliente)

    CREATE TABLE #codVendaTemp (codVenda VARCHAR(10));

    INSERT INTO #codVendaTemp EXEC CI_MIDDLEWAY..seqCodVenda @id_pedido_venda;

    SELECT @codVenda=codVenda FROM #codVendaTemp
END

UPDATE ls
SET ls.StaCadeira='V'
    ,ls.CodTipBilhete=ab.CodTipBilhete
    ,ls.CodVenda=@codVenda
    ,ls.CodUsuario=@codUsuario
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabLugSala ls ON ls.CodApresentacao=a.CodApresentacao AND ls.Indice=r.id_cadeira
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE csc.id_cliente=@id_cliente

update CI_MIDDLEWAY..mw_pedido_venda
	SET id_pedido_ipagare = @ID_PEDIDO_IPAGARE,
		cd_numero_autorizacao = @CD_NUMERO_AUTORIZACAO,
		cd_numero_transacao = @CD_NUMERO_TRANSACAO,
		in_situacao = 'F',
		cd_bin_cartao = @NR_CARTAO_CREDITO
WHERE
	id_pedido_venda = @id_pedido_venda


UPDATE CI_MIDDLEWAY..mw_item_pedido_venda
    SET CodVenda=@codVenda
WHERE
    id_pedido_venda=@id_pedido_venda


DECLARE @NumLancamento INT
SELECT @NumLancamento = (SELECT COALESCE(MAX(NumLancamento),0)+1 FROM tabLancamento)

INSERT INTO tabLancamento (NumLancamento,CodTipBilhete,CodTipLancamento,CodApresentacao,Indice, 
CodUsuario,CodForPagto,CodCaixa,DatMovimento,QtdBilhete,ValPagto, DatVenda, CodMovimento)
    SELECT  
        @NumLancamento
        ,ab.CodTipBilhete
        ,1
        ,a.CodApresentacao
        ,r.id_cadeira
        ,@codUsuario
        ,@codForPagto
        ,@codCaixa
        ,CONVERT(SMALLDATETIME,CONVERT(VARCHAR(8), @now,112) + ' ' + LEFT(CONVERT(VARCHAR, @now,114),8))
        ,@quantity
        ,CONVERT(DECIMAL(18,2),@totalAmount)/100
        ,@now
        ,NULL
    FROM CI_MIDDLEWAY..mw_reserva r
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
    INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
    INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
    INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
    INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
    INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
    WHERE csc.id_cliente=@id_cliente

IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

IF (@codCliente IS NOT NULL)
BEGIN
    INSERT INTO tabHisCliente (Codigo,NumLancamento,CodTipBilhete,CodTipLancamento,CodApresentacao,Indice)
        SELECT
        @codCliente
        ,@NumLancamento
        ,ab.CodTipBilhete
        ,1
        ,a.codapresentacao
        ,ls.indice
        FROM CI_MIDDLEWAY..mw_reserva r
        INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
        INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
        INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
        INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
        INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
        INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
        WHERE csc.id_cliente=@id_cliente
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
    ,@cliente_Nome,r.cd_binitau,''
    ,@cliente_DDD,@cliente_Telefone,@cliente_Ramal
    ,@cliente_CPF,@cliente_RG, ab.CodTipBilhete
    ,'WEB',0,@NomeEmpresa
    ,@codCliente,a.codapresentacao,a.CodPeca
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
INNER JOIN tabSala s ON a.CodSala=s.CodSala
WHERE csc.id_cliente=@id_cliente

INSERT INTO tabControleSeqVenda (codapresentacao, indice, numseq, codbar, statusingresso)
SELECT 
    a.codapresentacao
    ,ls.indice
    ,1
    ,
right('00000'+convert(varchar,a.codapresentacao),5) --5
+convert(char(1), sd.CodSetor) --6
+right('0000'+replace(convert(varchar(5),a.HorSessao),':',''),4) --10
+right('00000'+convert(varchar(10),ls.indice),5) --15
+LEFT(CONVERT(VARCHAR(100),newid()),6) --21
    ,'L'
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON sd.Indice=ls.indice AND sd.CodSala=a.CodSala
WHERE csc.id_cliente=@id_cliente


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
ls.indice,@codVenda
,SUBSTRING(sd.NomObjeto,1,10)
,SUBSTRING(p.NomPeca,1,35),SUBSTRING(p.NomRedPeca,1,35),a.DatApresentacao
,SUBSTRING(a.HorSessao,1,5),SUBSTRING(p.Elenco,1,50),SUBSTRING(p.Autor,1,50)
,SUBSTRING(p.Diretor,1,50),SUBSTRING(s.NomRedSala,1,6),SUBSTRING(tb.TipBilhete,1,20)
,(CONVERT(DECIMAL(18,2),@totalAmount)/100),@codCaixa,SUBSTRING('WEB', 0, 10)
,SUBSTRING(p.NomResPeca,0,6),p.CenPeca,SUBSTRING(se.NomSetor,1,26)
,@now, @quantity,tb.PerDesconto
,0,s.CodSala,(SELECT TOP 1 ep.id_cartao_patrocinado FROM CI_MIDDLEWAY..mw_evento_patrocinado ep WHERE ep.CodPeca=a.CodPeca AND ep.id_base=@id_base AND convert(varchar, a.datapresentacao,112) between convert(varchar, ep.dt_inicio,112) and convert(varchar, ep.dt_fim ,112))-- ep.id_cartao_patrocinado
,r.cd_binitau
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN tabPeca p ON e.codPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND r.id_cadeira=ls.Indice
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON sd.Indice=ls.indice AND sd.CodSala=a.CodSala
INNER JOIN tabTipBilhete tb ON ab.CodTipBilhete=tb.CodTipBilhete
INNER JOIN tabSetor se ON sd.CodSetor=se.CodSetor AND a.CodSala=se.CodSala
WHERE csc.id_cliente=@id_cliente


INSERT INTO tabDetPagamento (CodForPagto, NumLancamento, Agencia, Numero, DatValidade,Observacao )
		VALUES(@CodForPagto, @NumLancamento, null, @NR_CARTAO_CREDITO, '0000',null)



DECLARE @CodLog INT
SELECT @CodLog = (SELECT COALESCE(MAX(IdLogOperacao),0)+1 FROM tabLogOperacao)
INSERT INTO tabLogOperacao (IdLogOperacao, DatOperacao, CodUsuario, Operacao) 
SELECT TOP 1
@CodLog
,@now
,@codUsuario
,'Venda de Ingressos - espetáculo '+ e.ds_evento + '  Dt.:' + convert(varchar(10),@now,103) + ' Cod.Venda:' + @codVenda
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE csc.id_cliente=@id_cliente


SELECT 1 success
    , @id_base id_base
    , @codVenda codVenda
    , @id_pedido_venda id_pedido_venda
    ,NULL AS ErrorNumber
    ,NULL AS ErrorSeverity
    ,NULL AS ErrorState
    ,NULL AS ErrorProcedure
    ,NULL AS ErrorLine
    ,NULL AS ErrorMessage

  --COMMIT TRANSACTION sellweb
END TRY
BEGIN CATCH 
  --IF (@@TRANCOUNT > 0)
   --BEGIN
   --   ROLLBACK TRANSACTION sellweb
   --END 
    SELECT
        0 success
        , @id_base id_base
        ,NULL codVenda
        ,@id_pedido_venda id_pedido_venda
        ,ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage
END CATCH