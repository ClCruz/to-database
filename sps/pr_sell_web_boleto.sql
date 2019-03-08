ALTER PROCEDURE dbo.pr_sell_web_boleto (@transaction VARCHAR(100))

AS

-- DECLARE @transaction VARCHAR(100) = '77990246'

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@id_pedido_venda INT = 0
        ,@email_address VARCHAR(1000) = ''
        ,@email_name VARCHAR(1000) = ''


SELECT @has=1
        ,@id_pedido_venda=pv.id_pedido_venda
        ,@email_address = ISNULL(pv.ds_email_voucher,'')
        ,@email_name = ISNULL(pv.nm_cliente_voucher,'')
FROM CI_MIDDLEWAY..mw_pedido_venda pv
WHERE pv.cd_numero_transacao=@transaction

IF @has = 0
BEGIN
    SELECT 0 success,
            'Não foi possível achar o pedido.' msg
    RETURN;
END

UPDATE CI_MIDDLEWAY..mw_pedido_venda
    SET in_situacao='F'
        ,dt_boleto=GETDATE()
WHERE id_pedido_venda=@id_pedido_venda

SELECT 1 success
        ,@email_address email_address
        ,@email_name email_name
        ,'Efetuado com sucesso.' msg
