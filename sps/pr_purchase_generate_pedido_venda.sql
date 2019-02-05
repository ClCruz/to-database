
--select * from mw_pedido_venda
--exec sp_executesql N'EXEC pr_purchase_generate_pedido_venda @P1, @P2, @P3,@P4,@P5,@P6,@P7,@P8,@P9,@P10,@P11,@P12,@P13',N'@P1 nvarchar(4000),@P2 char(1),@P3 int,@P4 int,@P5 int,@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 nvarchar(4000),@P12 nvarchar(4000),@P13 nvarchar(4000)',N'30',NULL,200,200,0,N'424242',N'1',N'172.17.0.1',N'localhost',N'',N'',N'',N'matt murdock'

ALTER PROCEDURE dbo.pr_purchase_generate_pedido_venda (
        @id_cliente INT
        ,@id_operador INT
        ,@amountTotalINT INT
        ,@amountTotalwithoutserviceINT INT
        ,@amountTotalServiceINT INT
        ,@bin VARCHAR(6)
        ,@installment INT
        ,@ip VARCHAR(1000)
        ,@host VARCHAR(1000)
        ,@nr_beneficio VARCHAR(32)
        ,@nm_cliente_voucher VARCHAR(60)
        ,@ds_email_voucher VARCHAR(100)
        ,@nm_titular_cartao VARCHAR(60)
        ,@id_pedido_ipagare VARCHAR(36)
        ,@cd_numero_autorizacao VARCHAR(50)
        ,@cd_numero_transacao VARCHAR(50)
        ,@id_transaction_braspag VARCHAR(36)
        ,@id_meio_pagamento INT
        )

AS

SET NOCOUNT ON;

SET @nm_cliente_voucher = SUBSTRING(@nm_cliente_voucher, 1, 60)
SET @ds_email_voucher = SUBSTRING(@ds_email_voucher, 1, 100)
SET @nm_titular_cartao = SUBSTRING(@nm_titular_cartao, 1, 60)

DECLARE @id_pedido_venda INT  = NULL
        ,@now DATETIME = GETDATE()
        ,@in_situacao VARCHAR(10) = 'P'
        ,@in_situacao_despacho VARCHAR(10) = 'D'
        ,@in_retirada_entrega VARCHAR(10) = 'E'
        ,@frete NUMERIC(15,2) = 0
        ,@vl_total_pedido NUMERIC(15,2) = CONVERT(NUMERIC(15,2),@amountTotalINT)/CONVERT(NUMERIC(15,2),100)
        ,@vl_total_ingressos NUMERIC(15,2) = CONVERT(NUMERIC(15,2),@amountTotalwithoutserviceINT)/CONVERT(NUMERIC(15,2),100)
        ,@vl_total_taxa_conveniencia NUMERIC(15,2) = CONVERT(NUMERIC(15,2),@amountTotalServiceINT)/CONVERT(NUMERIC(15,2),100)

SELECT @id_pedido_venda=MAX(id_pedido_venda)+1 FROM CI_MIDDLEWAY..mw_pedido_venda

IF @id_pedido_venda IS NULL
    SET @id_pedido_venda=1

INSERT INTO CI_MIDDLEWAY..MW_PEDIDO_VENDA
    (ID_PEDIDO_VENDA
    ,ID_CLIENTE
    ,ID_USUARIO_CALLCENTER
    ,DT_PEDIDO_VENDA
    ,VL_TOTAL_PEDIDO_VENDA
    ,IN_SITUACAO
    ,IN_RETIRA_ENTREGA
    ,VL_TOTAL_INGRESSOS
    ,VL_FRETE
    ,VL_TOTAL_TAXA_CONVENIENCIA
    ,IN_SITUACAO_DESPACHO
    ,CD_BIN_CARTAO
    ,nr_parcelas_pgto
    ,id_IP
    ,nr_beneficio
    ,nm_cliente_voucher
    ,ds_email_voucher
    ,nm_titular_cartao
    ,id_pedido_ipagare
    ,cd_numero_autorizacao
    ,cd_numero_transacao
    ,id_transaction_braspag
    ,id_meio_pagamento)
    
VALUES
    (@id_pedido_venda
    , @id_cliente
    , @id_operador
    , @now
    , @vl_total_pedido
    , @in_situacao
    , @in_retirada_entrega
    , @vl_total_ingressos
    , @frete
    , @vl_total_taxa_conveniencia
    , @in_situacao_despacho
    , @bin
    , @installment
    , @ip  
    , @nr_beneficio
    , @nm_cliente_voucher
    , @ds_email_voucher
    , @nm_titular_cartao
    , @id_pedido_ipagare
    , @cd_numero_autorizacao
    , @cd_numero_transacao
    , @id_transaction_braspag
    , @id_meio_pagamento
    )


DECLARE @id_host UNIQUEIDENTIFIER = NULL

SELECT @id_host = id FROM CI_MIDDLEWAY..host WHERE host = @host

IF @id_host IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..host ([NAME], [HOST]) VALUES (@host, @host);

    SELECT @id_host = id FROM CI_MIDDLEWAY..host WHERE host = @host
END

INSERT INTO CI_MIDDLEWAY..order_host (id_pedido_venda, indice, id_host, id_cliente)
SELECT 
    @id_pedido_venda
    , r.id_cadeira
    , @id_host
    , csc.id_cliente
FROM CI_MIDDLEWAY..current_session_client csc
INNER JOIN CI_MIDDLEWAY..mw_reserva r ON csc.id_session=r.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE csc.id_cliente=@id_cliente
    
SELECT @id_pedido_venda id_pedido_venda