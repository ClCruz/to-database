ALTER PROCEDURE dbo.pr_seats(@id_apresentacao INT, @id VARCHAR(36))

AS
-- DECLARE @id_apresentacao INT = 167818, @id VARCHAR(36) = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'

DECLARE @id_session VARCHAR(32) = REPLACE(@id,'-','');

WITH RESULTADO AS (
    SELECT 
        PR.ID_CADEIRA 
    FROM CI_MIDDLEWAY..MW_PACOTE_RESERVA PR
    INNER JOIN CI_MIDDLEWAY..MW_PACOTE_APRESENTACAO PA ON PA.ID_PACOTE = PR.ID_PACOTE
    INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_APRESENTACAO = PA.ID_APRESENTACAO
    INNER JOIN CI_MIDDLEWAY..MW_EVENTO E ON E.ID_EVENTO = A.ID_EVENTO
    WHERE a.id_apresentacao=@id_apresentacao AND PR.IN_STATUS_RESERVA IN ('A', 'S', 'R')

    UNION ALL

    SELECT 
        PR.ID_CADEIRA 
    FROM CI_MIDDLEWAY..MW_PACOTE_RESERVA PR
    INNER JOIN CI_MIDDLEWAY..MW_PACOTE P ON P.ID_PACOTE = PR.ID_PACOTE
    INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A2 ON A2.ID_APRESENTACAO = P.ID_APRESENTACAO
    INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_EVENTO = A2.ID_EVENTO AND A.DT_APRESENTACAO = A2.DT_APRESENTACAO AND A.HR_APRESENTACAO = A2.HR_APRESENTACAO AND A2.IN_ATIVO = 1
    INNER JOIN CI_MIDDLEWAY..MW_EVENTO E ON E.ID_EVENTO = A.ID_EVENTO AND E.IN_ATIVO = 1
    WHERE a.id_apresentacao=@id_apresentacao AND PR.IN_STATUS_RESERVA IN ('A', 'S', 'R')
)
SELECT DISTINCT 
    S.Indice
    ,S.NomObjeto
    ,S.ClasseObj
    ,S.CodSetor
    ,SE.NomSetor
    ,S.PosXSite
    ,S.PosYSite
    ,S.PosX
    ,S.PosY
    ,L.STACADEIRA
    ,CASE WHEN (L.STACADEIRA IS NULL AND R.ID_CADEIRA IS NULL) THEN 'O' 
          WHEN (L.STACADEIRA IN ('T', 'M') AND l.id_session=@id_session) THEN 'S'
          WHEN (L.STACADEIRA IN ('R') AND l.id_session=@id_session) THEN 'R'
          WHEN (L.STACADEIRA IN ('R') AND l.id_session!=@id_session) THEN 'W'
    ELSE 'C' END [status]
    ,L.id_session
    ,CASE WHEN S.IMGVISAOLUGARFOTO IS NOT NULL THEN 1 ELSE 0 END [imgvisaolugarfoto]
    ,rc.CodCliente
    ,l.CodReserva
    ,l.CodVenda
FROM TABSALDETALHE S
INNER JOIN TABSETOR SE ON SE.CODSALA = S.CODSALA AND SE.CODSETOR = S.CODSETOR
INNER JOIN TABAPRESENTACAO A ON A.CODSALA = S.CODSALA
INNER JOIN TABPECA P ON P.CODPECA = A.CODPECA
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND ap.id_evento=e.id_evento
LEFT JOIN TABLUGSALA L ON L.INDICE = S.INDICE AND L.CODAPRESENTACAO = A.CODAPRESENTACAO
LEFT JOIN RESULTADO R ON R.ID_CADEIRA = S.INDICE
LEFT JOIN tabResCliente rc ON s.Indice=rc.Indice AND l.CodReserva=rc.CodReserva
WHERE ap.id_apresentacao=@id_apresentacao AND S.TIPOBJETO = 'C' AND P.STAPECA = 'A' 
AND CONVERT(varchar(8), P.DATFINPECA, 112) >= CONVERT(varchar(8), GETDATE(), 112) AND P.IN_VENDE_SITE = 1
-- AND s.Indice in (4047, 3017)
-- AND s.Indice in (4180)