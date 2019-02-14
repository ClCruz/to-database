--pr_purchase_installments 36

CREATE PROCEDURE dbo.pr_purchase_installments (@id_client INT)

AS

SELECT TOP 1 e.id_evento
                , eei.interest_rate
                , eei.max_installments
                , eei.free_installments
FROM CI_MIDDLEWAY..mw_reserva r
INNER JOIN CI_MIDDLEWAY..current_session_client csc ON r.id_session=csc.id_session COLLATE SQL_Latin1_General_CP1_CI_AS
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento
inner join CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
WHERE csc.id_cliente=@id_client
