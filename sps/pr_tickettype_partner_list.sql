CREATE PROCEDURE dbo.pr_tickettype_partner_list (@id_base INT, @CodTipBilhete INT)

AS
-- select * from tickettype_partner
-- sp_help tickettype_partner
-- DECLARE @id_base INT
--         ,@CodTipBilhete INT

SELECT
p.id
,p.name
,p.domain
,(CASE WHEN aup.id IS NULL THEN 0 ELSE aup.active END) active
FROM CI_MIDDLEWAY..[partner] p
LEFT JOIN CI_MIDDLEWAY..tickettype_partner aup ON p.id=aup.id_partner AND aup.id_base=@id_base AND aup.CodTipBilhete=@CodTipBilhete
WHERE p.dateEnd IS NULL OR p.dateEnd>=GETDATE()
ORDER BY p.name