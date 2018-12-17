ALTER PROCEDURE dbo.pr_apresentacao_offer_save (@id_apresentacao int
        ,@onOffer BIT = 1
        ,@onOfferPercentage INT = NULL
        ,@onOfferOlderValue INT = NULL
        ,@onOfferText VARCHAR(50) = NULL) 

AS

-- DECLARE @id_apresentacao int = 167474
--         ,@onOffer BIT = 1
--         ,@onOfferPercentage INT = NULL
--         ,@onOfferOlderValue INT = NULL
--         ,@onOfferText VARCHAR(50) = NULL

SET NOCOUNT ON;

DECLARE @id_evento INT
        ,@id_base INT
        ,@codPeca INT
        ,@codApresentacao INT
        ,@msg VARCHAR(100)

SELECT
    @id_evento=e.id_evento
    ,@id_base=e.id_base
    ,@codPeca=e.CodPeca
    ,@codApresentacao=a.CodApresentacao
FROM CI_MIDDLEWAY..mw_apresentacao a
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.id_evento=a.id_evento
WHERE a.id_apresentacao=@id_apresentacao

DECLARE @id UNIQUEIDENTIFIER = NULL

SELECT @id = id FROM CI_MIDDLEWAY..mw_apresentacao_extra WHERE id_apresentacao=@id_apresentacao

IF @id IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..mw_apresentacao_extra (id_apresentacao, id_evento, id_base, codPeca, codApresentacao, onOffer, onOfferOlderValue, onOfferPercentage, onOfferText) 
        SELECT @id_apresentacao, @id_evento, @id_base, @codPeca, @codApresentacao, @onOffer, @onOfferOlderValue, @onOfferPercentage, @onOfferText;
    SET @msg = 'Salvo com sucesso.';
END
ELSE
BEGIN
    UPDATE CI_MIDDLEWAY..mw_apresentacao_extra 
        SET onOffer=@onOffer
            ,onOfferOlderValue=@onOfferOlderValue
            ,onOfferPercentage=@onOfferPercentage
            ,onOfferText=@onOfferText
    WHERE id=@id;
    SET @msg = 'Alterado com sucesso.';
END

SELECT 1 success
        ,@msg msg