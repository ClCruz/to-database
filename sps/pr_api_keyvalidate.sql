CREATE PROCEDURE dbo.pr_api_keyvalidate (@key VARCHAR(1000))

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@active BIT
        ,@has BIT = 0

SELECT
@id_partner=qp.id_partner
,@active=qp.active
,@has = 1
FROM CI_MIDDLEWAY..quota_partner qp
WHERE qp.[key]=@key

SELECT @id_partner id_partner
    ,@active active
    ,@has has