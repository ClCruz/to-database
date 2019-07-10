
ALTER PROCEDURE dbo.pr_getpurchase (@codVenda VARCHAR(10) = NULL, @cpf VARCHAR(15) = NULL, @id_apresentacao INT = NULL)

AS

-- DECLARE @codVenda VARCHAR(10) = '5ZFAICBECO', @cpf VARCHAR(15) = '', @id_apresentacao INT = ''


SET @codVenda = (CASE WHEN @codVenda = '' OR @codVenda IS NULL THEN NULL ELSE @codVenda END);
SET @cpf = (CASE WHEN @cpf = '' OR @cpf IS NULL THEN NULL ELSE @cpf END);
SET @cpf=REPLACE(REPLACE(@cpf, '-', ''), '.', '')
SET @id_apresentacao = (CASE WHEN @id_apresentacao = '' OR @id_apresentacao IS NULL THEN NULL ELSE @id_apresentacao END);


DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT DISTINCT
c.Nome
,l.NumLancamento
,c.CPF
,ls.Indice
,se.NomSetor
,p.NomPeca
,s.NomSala
,a.HorSessao
,CONVERT(VARCHAR(10),a.DatApresentacao,103) DatApresentacao
,l.ValPagto
,tb.TipBilhete
,CONVERT(VARCHAR(10),l.DatVenda,103) + ' ' + CONVERT(VARCHAR(8),l.DatVenda,114) AS created
,tosh.id_pedido_venda
,sd.NomObjeto
,togr.id_gateway
,togr.transactionKey
,(CASE WHEN togr.transactionKey IS NULL THEN 0 ELSE 1 END) refundInGateway
,ls.CodVenda
,(CASE WHEN tosh.id IS NULL AND ls.id_quotapartner IS NULL THEN 'web' 
    WHEN tosh.id IS NULL AND ls.id_quotapartner IS NOT NULL THEN 'api'
  ELSE 'bilheteria' END) purchaseType
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON s.CodSala=se.CodSala
INNER JOIN tabSalDetalhe sd ON a.CodSala=sd.CodSala AND ls.Indice=sd.Indice AND sd.CodSetor=se.CodSetor
INNER JOIN CI_MIDDLEWAY..mw_evento e ON a.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ls.CodApresentacao=ap.CodApresentacao
LEFT JOIN tabLancamento l ON ls.Indice=l.Indice AND ls.CodApresentacao=l.CodApresentacao AND l.CodTipLancamento=1 AND l.NumLancamento NOT IN (SELECT sub.NumLancamento FROM tablancamento sub WHERE sub.indice=ls.Indice AND sub.CodApresentacao=ls.codapresentacao AND sub.CodTipLancamento=2)
LEFT JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosh ON tosh.id_base=e.id_base AND tosh.id_apresentacao=ap.id_apresentacao AND tosh.indice=ls.Indice
LEFT JOIN CI_MIDDLEWAY..ticketoffice_gateway_result togr ON tosh.id=togr.id_ticketoffice_shoppingcart
LEFT JOIN tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete
LEFT JOIN tabHisCliente hc ON l.NumLancamento=hc.NumLancamento AND ls.CodApresentacao=hc.CodApresentacao AND ls.Indice=hc.Indice
LEFT JOIN tabCliente c ON hc.Codigo=c.Codigo
WHERE (@codVenda IS NULL OR ls.CodVenda=@codVenda)
AND (@cpf IS NULL OR c.CPF=@cpf)
AND (@id_apresentacao IS NULL OR ap.id_apresentacao=@id_apresentacao)
AND ls.StaCadeira='V'