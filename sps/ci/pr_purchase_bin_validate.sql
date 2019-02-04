ALTER PROCEDURE dbo.pr_purchase_bin_validate (@bin VARCHAR(100), @id_session VARCHAR(1000))

AS

-- DECLARE @bin VARCHAR(100)
--         ,@id_session VARCHAR(1000)

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@id_base INT = 0

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

SELECT id_reserva
INTO #result
FROM CI_MIDDLEWAY..MW_RESERVA R
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_APRESENTACAO = R.ID_APRESENTACAO
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.id_evento=e.id_evento AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE AB ON AB.ID_APRESENTACAO = R.ID_APRESENTACAO AND AB.IN_ATIVO = 1 AND AB.ID_APRESENTACAO_BILHETE = R.ID_APRESENTACAO_BILHETE
INNER JOIN TABTIPBILHETE TTB ON TTB.CODTIPBILHETE = AB.CODTIPBILHETE
INNER JOIN CI_MIDDLEWAY..MW_PROMOCAO_CONTROLE PC ON PC.ID_PROMOCAO_CONTROLE = TTB.ID_PROMOCAO_CONTROLE AND A.DT_APRESENTACAO BETWEEN PC.DT_INICIO_PROMOCAO AND PC.DT_FIM_PROMOCAO
INNER JOIN CI_MIDDLEWAY..MW_CARTAO_PATROCINADO CP ON CP.ID_PATROCINADOR = PC.ID_PATROCINADOR
WHERE (
    (PC.CODTIPPROMOCAO in (4, 7) AND CP.CD_BIN = @bin)
    OR
    (PC.CODTIPPROMOCAO = 7 AND CP.CD_BIN = SUBSTRING(@bin, 1, 5))
)
AND R.id_session=@id_session

SELECT @has = 1 FROM #result

IF @has = 1
BEGIN
    UPDATE d
    SET d.cd_binitau=@bin
        ,d.nr_beneficio=NULL
    FROM CI_MIDDLEWAY..mw_reserva d
    INNER JOIN #result r ON d.id_reserva=r.id_reserva
    SELECT 1 success
            ,'' msg
END
ELSE
BEGIN
    SELECT 0 success
            ,'Este cartão não é participante da promoção vigente para esta apresentação! Informe outro cartão ou indique outro tipo de ingresso não participante da promoção.' msg
END