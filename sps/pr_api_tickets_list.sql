
CREATE PROCEDURE dbo.pr_api_tickets_list (@key VARCHAR(1000), @date DATETIME = NULL)

AS

-- DECLARE @key VARCHAR(1000) = 'qp_625b2ce3dcc14c1bba8058a436c9a36ac3e7dfcabcfd4a7f8fc391c8488c16f4'

SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#events', 'U') IS NOT NULL
    DROP TABLE #events; 

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

IF OBJECT_ID('tempdb.dbo.#data_bases', 'U') IS NOT NULL
    DROP TABLE #data_bases; 


CREATE TABLE #data_bases (event_id INT
                            ,base INT
                            ,id_presentantion INT
                            ,sectorName VARCHAR(1000)
                            ,sectorDiscount DECIMAL(16,4)
                            ,seatName VARCHAR(1000)
                            ,seatId INT
                            ,price DECIMAL(16,4)
                            ,allowticketoffice BIT
                            ,allowweb BIT
                            ,ds_nome_site VARCHAR(1000)
                            ,in_dom BIT
                            ,in_qua BIT
                            ,in_qui BIT
                            ,in_sab BIT
                            ,in_seg BIT
                            ,in_sex BIT
                            ,in_ter BIT
                            ,in_venda_site BIT
                            ,PerDesconto DECIMAL(16,4)
                            ,TipBilhete VARCHAR(1000)
                            ,vl_preco_fixo DECIMAL(16,4))

SELECT
h.id_evento [id]
,e.id_base base
,h.ds_evento [name]
,h.codPeca id_old
,h.ds_nome_teatro [place]
,h.ds_municipio [city]
,h.ds_estado [state]
,h.sg_estado [state_acronym]
,h.cardimage [image_card]
,h.cardbigimage [image_big]
,h.uri
,h.dates
,eei.id_genre
,CONVERT(VARCHAR(10), eei.created, 103) created
,g.name genreName 
,(CASE WHEN eei.maxAmount IS NULL AND eei.minAmount IS NOT NULL THEN FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') ELSE FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br')+' a '+FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') END) amounts
,FORMAT(CONVERT(DECIMAL(16,2),eei.minAmount)/100,'C', 'pt-br') minAmount
,FORMAT(CONVERT(DECIMAL(16,2),eei.maxAmount)/100,'C', 'pt-br') maxAmount
INTO #events
FROM home h
INNER JOIN CI_MIDDLEWAY..mw_evento e ON h.id_evento=e.id_evento
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..mw_apresentacao ap ON e.id_evento=ap.id_evento
INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpr ON ap.id_apresentacao=qpr.id_apresentacao
INNER JOIN CI_MIDDLEWAY..quota_partner qp ON qpr.id_quotapartner=qp.id AND qp.[key]=@key
LEFT JOIN CI_MIDDLEWAY..genre g ON eei.id_genre=g.id
WHERE 
    DATEADD(minute, ((eei.minuteBefore)*-1), CONVERT(VARCHAR(10),ap.dt_apresentacao,121) + ' ' + REPLACE(ap.hr_apresentacao, 'h', ':') + ':00.000')>=GETDATE()
    AND e.in_ativo=1
GROUP BY 
h.id_evento
,h.ds_evento
,h.codPeca
,h.ds_nome_teatro
,h.ds_municipio
,h.ds_estado
,h.sg_estado
,h.cardimage
,h.cardbigimage
,h.uri
,h.dates
,eei.id_genre
,eei.created
,g.name
,eei.minAmount
,eei.maxAmount
,e.id_base

SELECT DISTINCT base,0 done
INTO #bases
FROM #events


WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    DECLARE @currentBase INT = 0
            ,@db_name VARCHAR(1000)
            ,@toExec NVARCHAR(MAX)

    SELECT TOP 1 @currentBase=base FROM #bases WHERE done=0 ORDER BY base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    SET @toExec=''
    SET @toExec = @toExec + 'INSERT INTO #data_bases (event_id,base,id_presentantion,sectorName,sectorDiscount,seatName,seatId,price,allowticketoffice,allowweb,ds_nome_site,in_dom,in_qua,in_qui,in_sab,in_seg,in_sex,in_ter,in_venda_site,PerDesconto,TipBilhete,vl_preco_fixo) '
    SET @toExec = @toExec + ' SELECT  '
    SET @toExec = @toExec + ' ev.[id] event_id '
    SET @toExec = @toExec + ' ,ev.base '
    SET @toExec = @toExec + ' ,ap.id_apresentacao id_presentantion '
    SET @toExec = @toExec + ' ,se.NomSetor sectorName '
    SET @toExec = @toExec + ' ,se.PerDesconto sectorDiscount '
    SET @toExec = @toExec + ' ,sd.NomObjeto seatName '
    SET @toExec = @toExec + ' ,sd.Indice '
    SET @toExec = @toExec + ' ,(CASE WHEN se.PerDesconto = 0 THEN CONVERT(DECIMAL(16,2),a.ValPeca) ELSE (CONVERT(DECIMAL(16,2),a.ValPeca)*CONVERT(DECIMAL(16,2),se.PerDesconto)) END) price '
    SET @toExec = @toExec + ' ,tb.allowticketoffice '
    SET @toExec = @toExec + ' ,tb.allowweb '
    SET @toExec = @toExec + ' ,tb.ds_nome_site '
    SET @toExec = @toExec + ' ,tb.in_dom '
    SET @toExec = @toExec + ' ,tb.in_qua '
    SET @toExec = @toExec + ' ,tb.in_qui '
    SET @toExec = @toExec + ' ,tb.in_sab '
    SET @toExec = @toExec + ' ,tb.in_seg '
    SET @toExec = @toExec + ' ,tb.in_sex '
    SET @toExec = @toExec + ' ,tb.in_ter '
    SET @toExec = @toExec + ' ,tb.in_venda_site '
    SET @toExec = @toExec + ' ,tb.PerDesconto '
    SET @toExec = @toExec + ' ,tb.TipBilhete '
    SET @toExec = @toExec + ' ,tb.vl_preco_fixo '
    SET @toExec = @toExec + ' FROM CI_MIDDLEWAY..mw_apresentacao ap '
    SET @toExec = @toExec + ' INNER JOIN #events ev ON ap.id_evento=ev.id '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_evento e ON ap.id_evento=e.id_evento AND e.id_base=ev.base '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..mw_apresentacao_bilhete apb ON apb.id_apresentacao=ap.id_apresentacao AND apb.in_ativo=1 '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..quota_partner_reservation qpr ON ap.id_apresentacao=qpr.id_apresentacao '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..quota_partner qp ON qpr.id_quotapartner=qp.id AND qp.[key]= '''+@key+''''
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON apb.CodTipBilhete=tb.CodTipBilhete '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON e.CodPeca=p.CodPeca '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON sd.CodSala=a.CodSala AND sd.Indice=qpr.indice '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON a.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabLugSala ls ON a.CodApresentacao=ls.CodApresentacao AND sd.Indice=ls.Indice '

    -- select @toExec
    exec sp_executesql @toExec
	
    UPDATE #bases SET done=1 WHERE base=@currentBase;
END

SELECT
event_id
,base
,id_presentantion
,sectorName
,sectorDiscount
,seatName
,seatId
,(CASE WHEN PerDesconto = 0 AND (vl_preco_fixo = 0 OR vl_preco_fixo IS NULL ) THEN price
        WHEN PerDesconto <> 0 THEN price-(price*(PerDesconto/100))
        WHEN PerDesconto = 0 AND vl_preco_fixo IS NOT NULL AND vl_preco_fixo <> 0 THEN vl_preco_fixo END) price
,allowticketoffice
,allowweb
,PerDesconto
,(CASE WHEN ds_nome_site IS NULL THEN TipBilhete ELSE ds_nome_site END) ticketType
,in_dom sell_sun
,in_seg sell_mon
,in_ter sell_tue
,in_qua sell_wed
,in_qui sell_thu
,in_sex sell_fri
,in_sab sell_sat
FROM #data_bases


