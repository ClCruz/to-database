CREATE PROCEDURE dbo.pr_reservation_select (@id_apresentacao INT)

AS

-- DECLARE @id_apresentacao INT = 167779


SET NOCOUNT ON; 

DECLARE @id_base INT
SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()


SELECT DISTINCT
ls.CodReserva
,cli.Nome
,cli.CPF
,(SELECT COUNT(*) FROM tabLugSala sub WHERE sub.CodReserva=ls.CodReserva AND sub.StaCadeira='R') howmany
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN tabResCliente rc ON ls.CodReserva=rc.CodReserva
INNER JOIN tabCliente cli ON rc.CodCliente=cli.Codigo
WHERE ap.id_apresentacao=@id_apresentacao