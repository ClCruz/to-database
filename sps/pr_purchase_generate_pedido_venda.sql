CREATE PROCEDURE dbo.pr_purchase_generate_pedido_venda (
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
        ,@frete NUMERIC(15,2) = NULL
        ,@vl_total_pedido NUMERIC(15,2) = NULL
        ,@vl_total_ingressos NUMERIC(15,2) = NULL
        ,@vl_total_taxa_conveniencia NUMERIC(15,2) = NULL

SELECT @id_pedido_venda=MAX(id_pedido_venda) FROM CI_MIDDLEWAY..mw_pedido_venda

IF @id_pedido_venda IS NULL
    SET @id_pedido_venda=1

INSERT INTO MW_PEDIDO_VENDA
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
    ,nm_titular_cartao)
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
    )


DECLARE @id_host UNIQUEIDENTIFIER = NULL

SELECT @id_host = id FROM CI_MIDDLEWAY..host WHERE host = @host

IF @id_host IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..host ([NAME], [HOST]) VALUES (@host, @host);

    SELECT @id_host = id FROM CI_MIDDLEWAY..host WHERE host = @host
END

INSERT INTO order_host (id_pedido_venda, indice, id_host, id_cliente)
SELECT 
    @id_pedido_venda
    , r.id_cadeira
    , @id_host
    , csc.id_cliente
FROM CI_MIDDLEWAY..current_session_client csc
INNER JOIN CI_MIDDLEWAY..mw_reserva r ON csc.id_session=r.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
WHERE csc.id_cliente=@id_cliente
    
SELECT @id_pedido_venda id_pedido_venda