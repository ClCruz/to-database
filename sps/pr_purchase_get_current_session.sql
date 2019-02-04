CREATE PROCEDURE dbo.pr_purchase_get_current_session(@id_client INT)

AS

SELECT TOP 1
csc.id_session
,csc.created
,csc.id_cliente
FROM CI_MIDDLEWAY..current_session_client csc
WHERE csc.id_cliente=@id_client