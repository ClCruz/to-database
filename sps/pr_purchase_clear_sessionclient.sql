CREATE PROCEDURE dbo.pr_purchase_clear_sessionclient (@id_client INT)

AS

DELETE FROM CI_MIDDLEWAY..current_session_client WHERE id_cliente = @id_client