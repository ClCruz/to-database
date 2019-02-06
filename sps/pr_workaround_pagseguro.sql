CREATE PROCEDURE dbo.pr_workaround_pagseguro (@id_pedido_venda INT, @obj VARCHAR(MAX), @status VARCHAR(100))

AS

INSERT INTO MW_PEDIDO_PAGSEGURO (ID_PEDIDO_VENDA, DT_STATUS, CD_STATUS, OBJ_PAGSEGURO) VALUES (@id_pedido_venda, GETDATE(), @status, @obj);