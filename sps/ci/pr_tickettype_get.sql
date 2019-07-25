ALTER PROCEDURE dbo.pr_tickettype_get (@id INT)

AS

SET NOCOUNT ON;

SELECT 
  tb.CodTipBilhete
  ,DB_NAME() uniquename
  ,tb.allowticketoffice
  ,tb.allowweb
  ,tb.allowapi
  ,tb.CobraComs
  ,tb.CotaMeiaEstudante
  ,tb.[description]
  ,tb.ds_nome_site
  ,tb.hasImage
  ,tb.id_promocao_controle
  ,tb.Img1Promocao
  ,tb.Img2Promocao
  ,tb.ImpDSBilhDest
  ,tb.ImpVlIngresso
  ,tb.in_dom
  ,tb.in_hot_site
  ,tb.in_qua
  ,tb.in_qui
  ,tb.in_sab
  ,tb.in_seg
  ,tb.in_sex
  ,tb.in_ter
  ,tb.in_venda_site
  ,tb.InPacote
  ,tb.isAllotment
  ,tb.isFixed
  ,tb.isHalf
  ,tb.isOld
  ,tb.isPlus
  ,tb.isDiscount
  ,tb.isPrincipal
  ,tb.isNoValue
  ,tb.isPOS
  ,tb.nameTicketOffice
  ,tb.nameWeb
  ,tb.nameAPI
  ,tb.PerDesconto
  ,tb.QtdVendaPorLote
  ,tb.StaCalculoMeiaEstudante
  ,tb.StaCalculoPorSala
  ,tb.StaTipBilhete
  ,tb.StaTipBilhMeia
  ,tb.StaTipBilhMeiaEstudante
  ,tb.TipBilhete
  ,tb.TipCaixa
  ,tb.vl_preco_fixo
FROM [dbo].tabTipBilhete tb
WHERE tb.CodTipBilhete=@id