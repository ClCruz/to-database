ALTER PROCEDURE dbo.pr_boleto_save (@id_pedido_venda INT, @boleto_url VARCHAR(1000), @boleto_barcode VARCHAR(1000), @boleto_expiration_date DATETIME)

AS


UPDATE CI_MIDDLEWAY..mw_pedido_venda SET boleto_barcode=@boleto_barcode, url_boleto=@boleto_url, boleto_expiration_date=@boleto_expiration_date, isboletogenerated=1 WHERE id_pedido_venda=@id_pedido_venda