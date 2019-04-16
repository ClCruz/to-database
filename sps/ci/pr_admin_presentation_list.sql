--pr_admin_presentation_list 33016

ALTER PROCEDURE dbo.pr_admin_presentation_list (@id_evento INT)

AS

-- DECLARE @id_evento INT = 33016

-- SET @id_evento=22723
-- SET @id_evento=22696
-- SET @id_evento=22695


SET NOCOUNT ON;

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

DECLARE @weekday TABLE (id INT, [name] VARCHAR(100));

INSERT INTO @weekday (id, name) VALUES(1, 'dom')
INSERT INTO @weekday (id, name) VALUES(2, 'seg')
INSERT INTO @weekday (id, name) VALUES(3, 'ter')
INSERT INTO @weekday (id, name) VALUES(4, 'qua')
INSERT INTO @weekday (id, name) VALUES(5, 'qui')
INSERT INTO @weekday (id, name) VALUES(6, 'sex')
INSERT INTO @weekday (id, name) VALUES(7, 'sab')


SELECT
    a.CodApresentacao
    ,DATEPART(dw, a.DatApresentacao) [weekday]
    ,(SELECT TOP 1 [name] FROM @weekday WHERE id = DATEPART(dw, a.DatApresentacao)) weekdayName
    ,CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao
    ,a.HorSessao
    ,a.ValPeca
    ,CAST((a.ValPeca*100) AS INT) amount
    ,a.StaAtivoWeb
    ,a.StaAtivoBilheteria
    ,a.CodSala
    ,s.NomSala
FROM tabApresentacao a
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN tabSala s ON a.CodSala=s.CodSala
WHERE
    e.id_evento=@id_evento
ORDER BY CONVERT(DATETIME,CONVERT(VARCHAR(10),a.DatApresentacao,121) + ' ' + a.HorSessao) DESC