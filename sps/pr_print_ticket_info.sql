-- exec dbo.pr_print_ticket2 'F63GIOAICE', NULL, 'localhost', 'live_dd310c796ff04199b5680a5cad098930c2ae8da63b974b43abb21d92ec5123b2'


ALTER PROCEDURE dbo.pr_print_ticket_info(@codVenda VARCHAR(10)
        ,@indice INT = NULL
        ,@uniquename VARCHAR(100)
        ,@api VARCHAR(1000))


AS

-- DECLARE @codVenda VARCHAR(10) = 'D64ICCCAHG'
--         ,@indice INT = NULL
--         ,@uniquename VARCHAR(100) = 'viveringressos'
--         ,@api VARCHAR(1000) = 'live_dd310c796ff04199b5680a5cad098930c2ae8da63b974b43abb21d92ec5123b2'


SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@show_partner_info BIT

SELECT TOP 1 @id_partner=p.id,@show_partner_info=p.show_partner_info FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

DECLARE @domain VARCHAR(3000) = NULL

SELECT TOP 1 
    @domain = p.domain
FROM CI_MIDDLEWAY..[partner] p 
WHERE 
    p.uniquename=@uniquename

IF @domain IS NULL
    SET @domain = 'www.ticketoffice.com.br'

IF @indice=''
    SET @indice=NULL

IF OBJECT_ID('tempdb.dbo.#result', 'U') IS NOT NULL
    DROP TABLE #result; 

DECLARE @weekday TABLE (id INT, [name] VARCHAR(100), [full] VARCHAR(100));

INSERT INTO @weekday (id, [name],[full]) VALUES(1, 'dom', 'domingo')
INSERT INTO @weekday (id, [name],[full]) VALUES(2, 'seg', 'segunda-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(3, 'ter', 'terça-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(4, 'qua', 'quarta-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(5, 'qui', 'quinta-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(6, 'sex', 'sexta-feira')
INSERT INTO @weekday (id, [name],[full]) VALUES(7, 'sab', 'sábado')

DECLARE @month TABLE (id INT, [name] VARCHAR(100), [full] VARCHAR(100));

INSERT INTO @month (id,[name],[full]) VALUES(1, 'jan', 'janeiro')
INSERT INTO @month (id,[name],[full]) VALUES(2, 'fev', 'fevereiro')
INSERT INTO @month (id,[name],[full]) VALUES(3, 'mar', 'março')
INSERT INTO @month (id,[name],[full]) VALUES(4, 'abr', 'abril')
INSERT INTO @month (id,[name],[full]) VALUES(5, 'mai', 'maio')
INSERT INTO @month (id,[name],[full]) VALUES(6, 'jun', 'junho')
INSERT INTO @month (id,[name],[full]) VALUES(7, 'jul', 'julho')
INSERT INTO @month (id,[name],[full]) VALUES(8, 'ago', 'agosto')
INSERT INTO @month (id,[name],[full]) VALUES(9, 'set', 'setembro')
INSERT INTO @month (id,[name],[full]) VALUES(10, 'out', 'outubro')
INSERT INTO @month (id,[name],[full]) VALUES(11, 'nov', 'novembro')
INSERT INTO @month (id,[name],[full]) VALUES(12, 'dez', 'dezembro')

DECLARE @id_base INT
SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

DECLARE @transaction VARCHAR(100) = NULL
        ,@now DATETIME = GETDATE()

SELECT TOP 1 @transaction=togr.transactionKey
FROM CI_MIDDLEWAY..ticketoffice_gateway_result togr
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosch ON togr.id_ticketoffice_shoppingcart=tosch.id
WHERE tosch.codVenda=@codVenda AND togr.transactionKey IS NOT NULL

IF @transaction IS NULL
BEGIN
    SELECT TOP 1 @transaction=pv.cd_numero_autorizacao
    FROM CI_MIDDLEWAY..mw_item_pedido_venda ipv
    INNER JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
    WHERE ipv.CodVenda=@codVenda AND pv.cd_numero_autorizacao IS NOT NULL
END

SELECT DISTINCT
tosch.id
,ls.Indice seatIndice
,le.ds_local_evento [local]
,le.ds_googlemaps [address]
,e.ds_evento [name]
,(SELECT TOP 1 [name] FROM @weekday WHERE id = DATEPART(dw, a.DatApresentacao)) [weekday]
,(SELECT TOP 1 [full] FROM @weekday WHERE id = DATEPART(dw, a.DatApresentacao)) [weekdayName]
,a.HorSessao [hour]
,(SELECT TOP 1 [name] FROM @month WHERE id = DATEPART(m, a.DatApresentacao)) [monthNameAbb]
,(SELECT TOP 1 [full] FROM @month WHERE id = DATEPART(m, a.DatApresentacao)) [monthName]
,RIGHT('00'+CONVERT(VARCHAR(2),DATEPART(d, a.DatApresentacao)),2) [day]
,RIGHT('00'+CONVERT(VARCHAR(2),DATEPART(m, a.DatApresentacao)),2) [month]
,DATEPART(yyyy, a.DatApresentacao) [year]
,s.NomSala [roomName]
,s.NomRedSala roomNameOther
,sd.NomObjeto seatNameFull
,se.NomSetor sectorName
,SUBSTRING(sd.NomObjeto, 0,CHARINDEX('-', sd.NomObjeto)) [seatRow]
,SUBSTRING(sd.NomObjeto, CHARINDEX('-', sd.NomObjeto) + 1, LEN(sd.NomObjeto)) [seatName]
,ls.CodVenda purchaseCode
,(CASE WHEN tosch.id_pedido_venda IS NULL THEN ipv.id_pedido_venda ELSE tosch.id_pedido_venda END) purchaseCodeInt
,tb.TipBilhete ticket
,fp.ForPagto payment
,tfp.TipForPagto paymentType
,@transaction AS [transaction]
,(CASE WHEN pv.id_pedido_venda IS NULL THEN c.Nome ELSE cli.ds_nome + ' ' + cli.ds_sobrenome COLLATE SQL_Latin1_General_CP1_CI_AS END) buyer 
,(CASE WHEN pv.id_pedido_venda IS NULL THEN c.CPF ELSE cli.cd_cpf COLLATE SQL_Latin1_General_CP1_CI_AS END) buyerDoc
,(CASE WHEN pv.id_pedido_venda IS NULL THEN c.EMail ELSE cli.cd_email_login COLLATE SQL_Latin1_General_CP1_CI_AS END) buyerEmail
,(CASE WHEN eei.insurance_policy IS NULL THEN '' ELSE eei.insurance_policy END) insurance_policy
,(CASE WHEN eei.opening_time IS NULL THEN '' ELSE eei.opening_time END) opening_time
-- ,p.NomResPeca eventResp
,(CASE WHEN tou.[login] IS NULL THEN 'web' ELSE tou.[login] END) [user]
,ROW_NUMBER() OVER (order by tosch.id) countTicket
,CONVERT(VARCHAR(10),l.DatVenda,103) + ' ' + CONVERT(VARCHAR(8),l.DatVenda,114) AS purchase_date
,CONVERT(VARCHAR(10),@now,103) + ' ' + CONVERT(VARCHAR(8),@now,114) AS print_date
,csv.codbar barcode
,(CASE WHEN pro.ds_razao_social IS NULL THEN '-' ELSE pro.ds_razao_social END) ds_razao_social
,(CASE WHEN pro.cd_cpf_cnpj IS NULL THEN '-' ELSE pro.cd_cpf_cnpj END) cd_cpf_cnpj
,(CASE WHEN pro.ds_endereco IS NULL THEN '-' ELSE pro.ds_endereco END) ds_endereco
,s.IngressoNumerado
,CONVERT(VARCHAR(100),FORMAT(CONVERT(decimal(18,2),tosch.amount_topay)/100, 'C', 'pt-br')) amount_topay
,ISNULL((SELECT TOP 1 COUNT(1) FROM CI_MIDDLEWAY..print_ticket sub WHERE sub.codVenda=@codVenda AND sub.id_base=@id_base),0) reprint
,b.name_site
,b.ds_nome_base_sql
,CONVERT(INT,ValPagto*100) ValPagto -- l.ValPagto
,FORMAT(ValPagto, 'N', 'pt-br') price_formatted
,l.NumLancamento
,pv.cd_bin_cartao
INTO #result
FROM tabLugSala ls
INNER JOIN tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSalDetalhe sd ON ls.Indice=sd.Indice AND a.CodSala=sd.CodSala
INNER JOIN tabSetor se ON sd.CodSetor=se.CodSetor AND s.CodSala=se.CodSala
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento AND ap.CodApresentacao=a.CodApresentacao
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN tabLancamento l ON ls.CodApresentacao=l.CodApresentacao AND ls.Indice=l.Indice AND l.CodTipLancamento=1 AND l.NumLancamento NOT IN (SELECT sub.NumLancamento FROM tablancamento sub WHERE sub.indice=ls.Indice AND sub.CodApresentacao=ls.codapresentacao AND sub.CodTipLancamento=2)
INNER JOIN CI_MIDDLEWAY..mw_produtor pro ON p.id_produtor=pro.id_produtor
INNER JOIN CI_MIDDLEWAY..mw_base b ON e.id_base=b.id_base
LEFT JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento=le.id_local_evento
LEFT JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart_hist tosch ON ls.Indice=tosch.indice AND ap.id_apresentacao=tosch.id_apresentacao
LEFT JOIN CI_MIDDLEWAY..mw_item_pedido_venda ipv ON ipv.Indice=ls.Indice AND ipv.id_apresentacao=ap.id_apresentacao
LEFT JOIN CI_MIDDLEWAY..mw_pedido_venda pv ON ipv.id_pedido_venda=pv.id_pedido_venda
LEFT JOIN CI_MIDDLEWAY..mw_cliente cli ON pv.id_cliente=cli.id_cliente
LEFT JOIN tabTipBilhete tb ON l.CodTipBilhete=tb.CodTipBilhete
LEFT JOIN tabForPagamento fp ON l.CodForPagto=fp.CodForPagto
LEFT JOIN tabTipForPagamento tfp ON fp.CodTipForPagto=tfp.CodTipForPagto
LEFT JOIN tabHisCliente hc ON l.NumLancamento=hc.NumLancamento AND ls.CodApresentacao=hc.CodApresentacao AND ls.Indice=hc.Indice
LEFT JOIN tabCliente c ON hc.Codigo=c.Codigo
LEFT JOIN CI_MIDDLEWAY..ticketoffice_user tou ON tosch.id_ticketoffice_user=tou.id
LEFT JOIN tabControleSeqVenda csv ON ls.Indice=csv.Indice AND ls.CodApresentacao=csv.CodApresentacao AND csv.statusingresso IN ('L','V')
WHERE ls.CodVenda=@codVenda
AND (@indice IS NULL OR ls.Indice=@indice)
-- return;

SELECT 
[id]
,[local]
-- ,'Rua do funk' [address]
,[address]
,[name]
,[weekday]
,[weekdayName]
,[hour]
,[month]
,[monthNameAbb]
,[monthName]
,[day]
,[year]
,[roomName]
,[roomNameOther]
,[seatNameFull]
,[sectorName]
,[seatRow]
,[seatName]
,[seatIndice]
,[purchaseCode]
,[purchaseCodeInt]
,[ticket]
,[payment]
,[paymentType]
,[transaction]
,(CASE WHEN [buyer] = '' OR [buyer] = ' ' THEN '-' ELSE [buyer] END) [buyer]
,(CASE WHEN [buyerDoc] = '' THEN '-' ELSE [buyerDoc] END) [buyerDoc]
,(CASE WHEN [buyerEmail] = '' THEN '-' ELSE [buyerEmail] END) [buyerEmail]
,cd_bin_cartao buyer_bin_card
,[insurance_policy]
,[opening_time]
,[ds_razao_social] productor_name
,[cd_cpf_cnpj] productor_document
,[ds_endereco] productor_address
,[user]
,[countTicket]
,[purchase_date]
,[print_date]
,[barcode]
,[IngressoNumerado]
,amount_topay
,@domain domain
,CONVERT(VARCHAR(10),countTicket) + '/' + CONVERT(VARCHAR(10),(SELECT MAX(countTicket) FROM #result)) [howMany]
,reprint
,@show_partner_info show_partner_info
,@id_partner id_partner
,name_site
,ds_nome_base_sql
,ValPagto price
,price_formatted
,NumLancamento unique_sell_code
,(SELECT SUM(ValPagto) FROM #result) price_total
,(SELECT COUNT(ValPagto) FROM #result) count_total
,FORMAT((SELECT SUM(ValPagto) FROM #result), 'N', 'pt-br') price_total_formatted
FROM #result
ORDER BY countTicket