CREATE PROCEDURE dbo.pr_apresentacao_offer (@id_apresentacao int) 

AS

SELECT
    ae.onOffer
    ,ae.onOfferOlderValue
    ,ae.onOfferPercentage
    ,ae.onOfferText
FROM CI_MIDDLEWAY..mw_apresentacao_extra ae
WHERE ae.id_apresentacao=@id_apresentacao

