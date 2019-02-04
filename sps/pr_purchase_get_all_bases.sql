--pr_purchase_bin_get_all_bases 'lo37k6asbd9uo0gfkglakfuem2'

CREATE PROCEDURE dbo.pr_purchase_get_all_bases (@id_session VARCHAR(1000))

AS

SELECT e.id_base, e.id_evento, e.CodPeca, a.CodApresentacao,a.id_apresentacao, r.id_reserva
FROM MW_EVENTO E
INNER JOIN MW_APRESENTACAO A ON A.ID_EVENTO = E.ID_EVENTO
INNER JOIN MW_RESERVA R ON R.ID_APRESENTACAO = A.ID_APRESENTACAO
WHERE R.id_session = @id_session