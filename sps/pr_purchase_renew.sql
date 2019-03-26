ALTER PROCEDURE dbo.pr_purchase_renew (@id_session VARCHAR(100), @id_user INT)

AS

UPDATE CI_MIDDLEWAY..mw_reserva SET dt_validade=DATEADD(minute,20, GETDATE()) WHERE id_session=@id_session