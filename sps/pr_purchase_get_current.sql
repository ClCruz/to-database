--pr_purchase_get_current '6lp3jnara0n0jmflihg6kh4c93'

ALTER PROCEDURE dbo.pr_purchase_get_current (@id_session VARCHAR(1000))

AS
--DECLARE @id_session VARCHAR(1000) = 'j5pu5q3um4cn4hcmuetsvcf9n0'


SET NOCOUNT ON;

IF OBJECT_ID('tempdb.dbo.#aux', 'U') IS NOT NULL
    DROP TABLE #aux; 
IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 
IF OBJECT_ID('tempdb.dbo.#data_bases', 'U') IS NOT NULL
    DROP TABLE #data_bases; 

CREATE TABLE #bases (id_base INT, done BIT)


CREATE TABLE #data_bases (id UNIQUEIDENTIFIER, id_base INT, base_sql VARCHAR(1000), CodApresentacao INT,CodTipBilhete INT
    ,Indice INT,StaCadeira VARCHAR(1000),DatApresentacao DATETIME
    ,HorSessao VARCHAR(1000),ValPeca INT,CodPeca INT
    ,NomPeca VARCHAR(1000), qt_parcelas INT,NomSala VARCHAR(1000),StaSala VARCHAR(1000)
    ,active BIT,allowticketoffice BIT,allowweb BIT
    ,NomObjeto VARCHAR(1000),NomSetor VARCHAR(1000),PerDescontoSetor FLOAT
    ,[Status] VARCHAR(1000),PerDesconto FLOAT,QtdVendaPorLote INT
    ,StaTipBilhMeiaEstudante VARCHAR(1000),StaTipBilhete VARCHAR(1000),TipBilhete VARCHAR(1000), ID_PROMOCAO_CONTROLE INT
    ,id_evento INT, id_apresentacao INT, id_reserva INT, hoursinadvance INT, in_taxa_por_pedido VARCHAR(1), id_apresentacao_bilhete INT, nr_beneficio VARCHAR(32),QT_INGRESSOS_POR_CPF INT, purchasebythiscpf INT)

SELECT e.id_base, e.id_evento, e.CodPeca, a.CodApresentacao,a.id_apresentacao, r.id_reserva, r.id_cadeira
INTO #aux
FROM CI_MIDDLEWAY..MW_EVENTO E
INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_EVENTO = E.ID_EVENTO
INNER JOIN CI_MIDDLEWAY..MW_RESERVA R ON R.ID_APRESENTACAO = A.ID_APRESENTACAO
WHERE R.id_session = @id_session

DECLARE @cpf VARCHAR(100)
SELECT @cpf=c.cd_cpf FROM CI_MIDDLEWAY..current_session_client csc
INNER JOIN CI_MIDDLEWAY..mw_cliente c ON csc.id_cliente=c.id_cliente
WHERE csc.id_session=@id_session

INSERT INTO #bases (id_base, done)
SELECT DISTINCT id_base,0
FROM #aux
WHILE (EXISTS (SELECT 1 FROM #bases WHERE done=0 ))
BEGIN
    DECLARE @currentBase INT = 0
            ,@db_name VARCHAR(1000)
            ,@toExec NVARCHAR(MAX)

    SELECT TOP 1 @currentBase=id_base FROM #bases WHERE done=0 ORDER BY id_base
    SELECT TOP 1 @db_name=b.ds_nome_base_sql FROM CI_MIDDLEWAY..mw_base b WHERE b.id_base=@currentBase;

    SET @toExec=''
    SET @toExec = @toExec + 'INSERT INTO #data_bases (id, id_base, base_sql, CodApresentacao,CodTipBilhete '
    SET @toExec = @toExec + ',Indice,StaCadeira,DatApresentacao '
    SET @toExec = @toExec + ',HorSessao,ValPeca,CodPeca '
    SET @toExec = @toExec + ',NomPeca,qt_parcelas,NomSala,StaSala '
    SET @toExec = @toExec + ',active,allowticketoffice,allowweb '
    SET @toExec = @toExec + ',NomObjeto,NomSetor,PerDescontoSetor '
    SET @toExec = @toExec + ',[Status],PerDesconto,QtdVendaPorLote '
    SET @toExec = @toExec + ',StaTipBilhMeiaEstudante,StaTipBilhete,TipBilhete, ID_PROMOCAO_CONTROLE'
    SET @toExec = @toExec + ',id_evento, id_apresentacao, id_reserva,hoursinadvance,in_taxa_por_pedido,id_apresentacao_bilhete, nr_beneficio,QT_INGRESSOS_POR_CPF,purchasebythiscpf) '
    SET @toExec = @toExec + 'SELECT DISTINCT '
    SET @toExec = @toExec + '        NEWID() '
    SET @toExec = @toExec + '        , ' + CONVERT(VARCHAR(10),@currentBase)
    SET @toExec = @toExec + '        , ''' + @db_name + ''''
    SET @toExec = @toExec + '        ,ls.CodApresentacao '
    SET @toExec = @toExec + '        ,ls.CodTipBilhete '
    SET @toExec = @toExec + '        ,ls.Indice '
    SET @toExec = @toExec + '        ,ls.StaCadeira '
    SET @toExec = @toExec + '        ,a.DatApresentacao '
    SET @toExec = @toExec + '        ,a.HorSessao '
    SET @toExec = @toExec + '        ,CONVERT(INT,CONVERT(DECIMAL(18,2),a.ValPeca)*100)'
    SET @toExec = @toExec + '        ,a.CodPeca '
    SET @toExec = @toExec + '        ,p.NomPeca '
    SET @toExec = @toExec + '        ,p.qt_parcelas '
    SET @toExec = @toExec + '        ,s.NomSala '
    SET @toExec = @toExec + '        ,s.StaSala '
    SET @toExec = @toExec + '        ,sd.active '
    SET @toExec = @toExec + '        ,sd.allowticketoffice '
    SET @toExec = @toExec + '        ,sd.allowweb '
    SET @toExec = @toExec + '        ,sd.NomObjeto '
    SET @toExec = @toExec + '        ,se.NomSetor '
    SET @toExec = @toExec + '        ,se.PerDesconto '
    SET @toExec = @toExec + '        ,se.[Status] '
    SET @toExec = @toExec + '        ,tb.PerDesconto '
    SET @toExec = @toExec + '        ,tb.QtdVendaPorLote '
    SET @toExec = @toExec + '        ,tb.StaTipBilhMeiaEstudante '
    SET @toExec = @toExec + '        ,tb.StaTipBilhete '
    SET @toExec = @toExec + '        ,tb.TipBilhete '
    SET @toExec = @toExec + '        ,tb.ID_PROMOCAO_CONTROLE '
    SET @toExec = @toExec + '        ,e.id_evento '
    SET @toExec = @toExec + '        ,ap.id_apresentacao '
    SET @toExec = @toExec + '        ,r.id_reserva '
    SET @toExec = @toExec + '        , DATEDIFF(HOUR, GETDATE(), CONVERT(DATETIME, CONVERT(VARCHAR, ap.dt_apresentacao, 112) + '' '' + LEFT(ap.hr_apresentacao,2) + '':'' + RIGHT(ap.hr_apresentacao,2) + '':00'')) hoursinadvance '
    SET @toExec = @toExec + '        ,(SELECT TOP 1 SUB.IN_TAXA_POR_PEDIDO FROM CI_MIDDLEWAY..MW_TAXA_CONVENIENCIA SUB WHERE SUB.ID_EVENTO = E.ID_EVENTO AND SUB.DT_INICIO_VIGENCIA <= GETDATE() ORDER BY SUB.DT_INICIO_VIGENCIA DESC) in_taxa_por_pedido'
    SET @toExec = @toExec + '        ,apb.id_apresentacao_bilhete '
    SET @toExec = @toExec + '        ,r.nr_beneficio '
    SET @toExec = @toExec + '        ,p.QT_INGRESSOS_POR_CPF '

    SET @toExec = @toExec + '        ,( '
    SET @toExec = @toExec + '        SELECT SUM(CASE subH.CODTIPLANCAMENTO WHEN 1 THEN 1 ELSE -1 END)  '
    SET @toExec = @toExec + '        FROM '+@db_name+'.dbo.tabCliente subC '
    SET @toExec = @toExec + '        INNER JOIN '+@db_name+'.dbo.tabHisCliente subH ON subH.CODIGO = subC.CODIGO '
    SET @toExec = @toExec + '        INNER JOIN '+@db_name+'.dbo.tabApresentacao subA ON subA.CODAPRESENTACAO = subH.CODAPRESENTACAO '
    SET @toExec = @toExec + '        INNER JOIN '+@db_name+'.dbo.tabApresentacao subA2 ON subA2.DATAPRESENTACAO = subA.DATAPRESENTACAO AND subA2.CODPECA = subA.CODPECA AND subA2.HORSESSAO = subA.HORSESSAO '
    SET @toExec = @toExec + '        WHERE subC.CPF = '''+@cpf+''' AND subA2.CODAPRESENTACAO = a.codApresentacao '
    SET @toExec = @toExec + '        ) AS purchasebythiscpf '

    SET @toExec = @toExec + ' FROM '+@db_name+'.dbo.tabLugSala ls '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabApresentacao a ON ls.CodApresentacao=a.CodApresentacao '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabPeca p ON a.CodPeca=p.CodPeca '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSala s ON a.CodSala=s.CodSala '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSalDetalhe sd ON a.CodSala=sd.CodSala AND ls.Indice=sd.Indice '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabSetor se ON a.CodSala=se.CodSala AND sd.CodSetor=se.CodSetor '
    SET @toExec = @toExec + ' INNER JOIN '+@db_name+'.dbo.tabTipBilhete tb ON ls.CodTipBilhete=tb.CodTipBilhete '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_EVENTO e ON e.codPeca=p.codPeca AND e.id_base='+CONVERT(VARCHAR(10),@currentBase) + ' '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO AP ON AP.ID_EVENTO = E.ID_EVENTO AND a.codApresentacao=ap.CodApresentacao '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_RESERVA R ON r.id_session=ls.id_session COLLATE SQL_Latin1_General_CP1_CI_AS AND R.id_apresentacao = ap.id_apresentacao AND r.id_cadeira=ls.indice '
    SET @toExec = @toExec + ' INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO_BILHETE APB ON APB.id_apresentacao=ap.id_apresentacao AND apb.codTipBilhete=ls.codTipBilhete AND r.id_apresentacao_bilhete=apb.id_apresentacao_bilhete '

    SET @toExec = @toExec + 'WHERE ls.id_session='''+@id_session+''''

    -- select @toExec
    exec sp_executesql @toExec
	
    UPDATE #bases SET done=1 WHERE id_base=@currentBase;
END


SELECT 
    id
    ,id_base
    ,base_sql
    ,CodApresentacao
    ,CodTipBilhete    
    ,Indice
    ,StaCadeira
    ,DatApresentacao
    ,HorSessao
    ,ValPeca
    ,CodPeca
    ,NomPeca
    ,qt_parcelas
    ,NomSala
    ,StaSala
    ,active
    ,allowticketoffice
    ,allowweb
    ,NomObjeto
    ,NomSetor
    ,PerDescontoSetor
    ,[Status]
    ,PerDesconto
    ,QtdVendaPorLote
    ,StaTipBilhMeiaEstudante
    ,StaTipBilhete
    ,TipBilhete
    ,ID_PROMOCAO_CONTROLE
    ,id_evento
    ,id_apresentacao
    ,id_reserva
    ,hoursinadvance
    ,in_taxa_por_pedido
    ,id_apresentacao_bilhete
    ,nr_beneficio
    ,QT_INGRESSOS_POR_CPF
    ,purchasebythiscpf
FROM #data_bases
