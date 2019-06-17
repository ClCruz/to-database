ALTER PROCEDURE dbo.pr_seat_info (@id_apresentacao INT
        ,@indice INT
        ,@id VARCHAR(1000))

AS

-- DECLARE @id_apresentacao INT = 167818
--         ,@indice INT = 4177--4175--4131--4181
--         ,@id VARCHAR(1000) = 'f2177e5e-f727-4906-948d-4eea9b9bbd0e'

SET NOCOUNT ON;

DECLARE @id_base INT
        ,@id_session VARCHAR(32) = replace(@id,'-','')
        -- ,@id_ticketoffice_user UNIQUEIDENTIFIER = CAST(@id AS UNIQUEIDENTIFIER)


SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()


SELECT
sd.Indice
,(CASE WHEN s.nameonsite IS NULL THEN s.NomSala ELSE s.nameonsite END) NomSala
,(CASE WHEN ls.StaCadeira = 'V' THEN 1 ELSE 0 END) isBought
,(CASE WHEN ls.StaCadeira = 'R' THEN (CASE WHEN tosc.indice IS NULL THEN 1 ELSE 0 END) ELSE 0 END) isReserved
,(CASE WHEN ls.StaCadeira IS NULL THEN 1 ELSE 0 END) isOpen
,(CASE WHEN (ls.StaCadeira = 'R' OR ls.StaCadeira = 'T') AND tosc.id_ticketoffice_user=@id THEN 1 ELSE 0 END) isSelected 
,(CASE WHEN pv.id_pedido_venda IS NULL THEN 0 ELSE 1 END) isWeb
,(CASE WHEN pv.id_pedido_venda IS NULL THEN 1 ELSE 0 END) isTicketOffice
,ls.StaCadeira
,sd.NomObjeto
,se.NomSetor
,tb.TipBilhete
,fp.ForPagto
,(CASE 
    WHEN pv.id_pedido_venda IS NULL THEN 
        (CASE WHEN ls.StaCadeira = 'R' THEN cres.Nome COLLATE SQL_Latin1_General_CP1_CI_AI 
                                        ELSE c.Nome COLLATE SQL_Latin1_General_CP1_CI_AI 
         END) 
                                    ELSE cli.ds_nome + ' ' + cli.ds_sobrenome COLLATE SQL_Latin1_General_CP1_CI_AI 
  END) Nome
,(CASE 
    WHEN pv.id_pedido_venda IS NULL THEN 
        (CASE WHEN ls.StaCadeira = 'R' THEN cres.CPF COLLATE SQL_Latin1_General_CP1_CI_AI 
                                        ELSE c.CPF COLLATE SQL_Latin1_General_CP1_CI_AI 
         END) 
                                    ELSE cli.cd_cpf COLLATE SQL_Latin1_General_CP1_CI_AI 
  END) CPF
,(CASE 
    WHEN pv.id_pedido_venda IS NULL THEN 
        (CASE WHEN ls.StaCadeira = 'R' THEN cres.DDD COLLATE SQL_Latin1_General_CP1_CI_AI 
                                        ELSE c.DDD COLLATE SQL_Latin1_General_CP1_CI_AI 
         END) 
                                    ELSE (CASE WHEN cli.ds_ddd_celular IS NULL OR cli.ds_ddd_celular = '' THEN cli.ds_ddd_telefone ELSE cli.ds_ddd_celular COLLATE SQL_Latin1_General_CP1_CI_AS END) 
  END) DDD
,(CASE 
    WHEN pv.id_pedido_venda IS NULL THEN 
        (CASE WHEN ls.StaCadeira = 'R' THEN cres.Telefone COLLATE SQL_Latin1_General_CP1_CI_AS 
                                        ELSE c.Telefone COLLATE SQL_Latin1_General_CP1_CI_AS 
         END) 
                                    ELSE (CASE WHEN cli.ds_celular IS NULL OR cli.ds_celular = '' THEN cli.ds_telefone ELSE cli.ds_celular COLLATE SQL_Latin1_General_CP1_CI_AS END) 
  END) Telefone
,ls.StaCadeira
,pv.id_pedido_venda
,ls.CodVenda
,tou.[login]
,ls.CodReserva
FROM tabSalDetalhe sd  --ON sd.Indice=ls.Indice AND sd.CodSala=s.CodSala
INNER JOIN tabApresentacao a ON a.CodSala=sd.CodSala
INNER JOIN tabPeca p ON a.CodPeca=p.CodPeca
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON a.CodApresentacao=ap.CodApresentacao AND e.id_evento=ap.id_evento
INNER JOIN tabSala s ON s.CodSala=a.CodSala
INNER JOIN tabSetor se ON sd.CodSetor=se.CodSetor AND s.CodSala=se.CodSala
LEFT JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart tosc ON tosc.id_event=p.CodPeca AND tosc.id_apresentacao=ap.id_apresentacao AND tosc.indice=sd.Indice
LEFT JOIN CI_MIDDLEWAY..mw_reserva re ON re.id_cadeira=sd.Indice AND re.id_apresentacao=ap.id_apresentacao
LEFT JOIN tabLugSala ls ON sd.Indice=ls.Indice AND a.CodApresentacao=ls.CodApresentacao
LEFT JOIN tabLancamento l ON ls.CodApresentacao=l.CodApresentacao AND ls.Indice=l.Indice AND l.CodTipLancamento=1 AND l.NumLancamento NOT IN (SELECT sub.NumLancamento FROM tablancamento sub WHERE sub.indice=ls.Indice AND sub.CodApresentacao=ls.codapresentacao AND sub.CodTipLancamento=2)
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
LEFT JOIN tabResCliente rc ON rc.CodReserva=ls.CodReserva AND rc.Indice=ls.Indice
LEFT JOIN tabCliente cres ON rc.CodCliente=cres.Codigo

WHERE ap.id_apresentacao=@id_apresentacao
AND sd.Indice=@indice


-- NSPIHOEAEO