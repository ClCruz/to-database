-- select * from CI_MIDDLEWAY..mw_reserva where id_session='a641pashoq45rag6ipo3hmp0d5'
-- SELECT * FROM tabLugSala where id_session='a641pashoq45rag6ipo3hmp0d5' AND stacadeira='T'

CREATE PROCEDURE dbo.pr_clear_morethanone_presentation (@id_session VARCHAR(100))

AS

-- DECLARE @id_session VARCHAR(100) = 'a641pashoq45rag6ipo3hmp0d5';

IF OBJECT_ID('tempdb.dbo.#helper', 'U') IS NOT NULL
    DROP TABLE #helper; 

SELECT id_apresentacao
INTO #helper
FROM CI_MIDDLEWAY..mw_reserva
WHERE
id_session=@id_session
GROUP BY id_apresentacao


IF @@ROWCOUNT<>1
BEGIN
    DECLARE @id_apresentacao INT 
            ,@codApresentacao INT

    SELECT TOP 1 @id_apresentacao=r.id_apresentacao 
                ,@codApresentacao=ap.codApresentacao
    FROM CI_MIDDLEWAY..mw_reserva r 
    INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON r.id_apresentacao=ap.id_apresentacao
    WHERE id_session=@id_session
    ORDER BY dt_selecao DESC

    DELETE FROM CI_MIDDLEWAY..mw_reserva WHERE id_apresentacao <> @id_apresentacao AND id_session=@id_session
    -- DELETE FROM tabLugSala WHERE id_session=@id_session AND CodApresentacao <> @codApresentacao AND StaCadeira='T'
END
