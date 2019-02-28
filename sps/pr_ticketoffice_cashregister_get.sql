CREATE PROCEDURE dbo.pr_ticketoffice_cashregister_get (@id UNIQUEIDENTIFIER)

AS

-- DECLARE @id UNIQUEIDENTIFIER = '0a6ef827-39ae-4cbf-b2c0-726eb460b6f3'

SET NOCOUNT ON;

SELECT tcrm.id
,CONVERT(VARCHAR(100),FORMAT(CONVERT(decimal(18,2),tcrm.amount)/100, 'C', 'pt-br')) amount
,tcrm.[type]
,tcrm.id_ticketoffice_user
,tcrm.justification
,toau.[login]
,toau.name
,CONVERT(VARCHAR(10),tcrm.created,103) + ' ' + CONVERT(VARCHAR(8),tcrm.created,114) created
FROM CI_MIDDLEWAY..ticketoffice_cashregister_moviment tcrm
INNER JOIN CI_MIDDLEWAY..to_admin_user toau ON tcrm.id_ticketoffice_user=toau.id
WHERE tcrm.id=@id
