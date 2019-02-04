CREATE PROCEDURE dbo.pr_purchase_renew (@id_session VARCHAR(100), @minutes INT)

AS

UPDATE CI_MIDDLEWAY..mw_reserva SET dt_validade=DATEADD(minute,@minutes, GETDATE()) WHERE id_session=@id_session