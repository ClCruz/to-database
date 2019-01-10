-- exec sp_executesql N'EXEC pr_event_save @P1,@P2,@P3,@P4,@P5,@P6,@P7,@P8,@P9,@P10,@P11,@P12,@P13,@P14,@P15,@P16,@P17,@P18,@P19',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 nvarchar(4000),@P12 nvarchar(4000),@P13 nvarchar(4000),@P14 nvarchar(4000),@P15 nvarchar(4000),@P16 nvarchar(4000),@P17 nvarchar(4000),@P18 nvarchar(4000),@P19 nvarchar(4000)',N'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5',N'32',N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',N'14',N'Replicas',N'89',N'60',N'12',N'265',N'<p>A scientist becomes obsessed with bringing back his family members who died in a traffic accident.</p>',N'desc',N'keyword',N'',N'',N'1',N'<p>evento show</p>',N'6',N'0',N'8'
-- select * from tabPeca
-- 
-- select * from CI_MIDDLEWAY..mw_evento where id_evento=22739
-- select * from CI_MIDDLEWAY..mw_evento_extrainfo where id_evento=22739

/*
delete from ci_middleway..mw_evento_extrainfo where id_evento in (select id_evento from CI_MIDDLEWAY..mw_evento where ds_evento like 'Replicas')
delete from ci_middleway..mw_evento where id_evento in (select id_evento from CI_MIDDLEWAY..mw_evento where ds_evento like 'Replicas')
delete from tabvalbilhete where codpeca in (select codPeca from CI_MIDDLEWAY..mw_evento where ds_evento like 'Replicas')
delete from tabpeca where codpeca in (select codPeca from CI_MIDDLEWAY..mw_evento where ds_evento like 'Replicas')
*/
-- go

ALTER PROCEDURE dbo.pr_event_save (@api VARCHAR(100)
    ,@id_produtor INT
    ,@id_to_admin_user UNIQUEIDENTIFIER
    ,@CodPeca INT
    ,@NomPeca VARCHAR(35)
    ,@CodTipPeca INT
    ,@TemDurPeca int
    ,@CenPeca int
    ,@id_local_evento int
    ,@description VARCHAR(MAX)
    ,@meta_description VARCHAR(1000)
    ,@meta_keyword VARCHAR(1000)
    ,@opening_time VARCHAR(1000)
    ,@insurance_policy VARCHAR(1000)
    ,@showInBanner BIT = 0
    ,@bannerDescription VARCHAR(1000) = NULL
--     ,@ValIngresso numeric(11,2) = 0
    ,@QtIngrPorPedido smallint = 4
    ,@in_obriga_cpf char(1) = '0'
    ,@qt_ingressos_por_cpf smallint = 4)



AS

-- declare @api VARCHAR(100) = 'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5'
--     ,@id_produtor INT = 32
--     ,@id_to_admin_user UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'
--     ,@CodPeca INT = ''
--     ,@NomPeca VARCHAR(35) = 'Replicas'
--     ,@CodTipPeca INT = '89'
--     ,@TemDurPeca int = '60'
--     ,@CenPeca int = '12'
--     ,@id_local_evento int = '265'
--     ,@description VARCHAR(MAX) = '<p>A scientist becomes obsessed with bringing back his family members who died in a traffic accident.</p>'
--     ,@meta_description VARCHAR(1000) = 'desc'
--     ,@meta_keyword VARCHAR(1000) = 'keyword'
--     ,@opening_time VARCHAR(1000) = '1hr antes'
--     ,@insurance_policy VARCHAR(1000) = 'apolice bradesco 123.x'
--     ,@showInBanner BIT = 1
--     ,@bannerDescription VARCHAR(1000) = '<p>evento show</p>'
--     ,@QtIngrPorPedido smallint = 6
--     ,@in_obriga_cpf char(1) = '0'
--     ,@qt_ingressos_por_cpf smallint = 8

SET NOCOUNT ON;

DECLARE @ValIngresso numeric(11,2) = 0

IF @CodPeca = 0 
        SET @CodPeca = NULL

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@id_base INT
        ,@youshallnotpass BIT = 1
        ,@id_genre INT = @CodTipPeca
        ,@genre VARCHAR(1000)

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api
SELECT TOP 1 @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()
SELECT @youshallnotpass=0 FROM CI_MIDDLEWAY..partner_database pd WHERE pd.id_base=@id_base AND pd.id_partner=@id_partner

SELECT @genre=[name] FROM CI_MIDDLEWAY..genre WHERE id=@id_genre

SELECT @CodTipPeca=tp.CodTipPeca
FROM tabTipPeca tp
WHERE RTRIM(LTRIM(tp.TipPeca))=RTRIM(LTRIM(@genre)) COLLATE SQL_Latin1_General_Cp1251_CS_AS

IF @youshallnotpass=1
BEGIN
    SELECT 0 success
            ,'not permitted' msg
    return;
END

DECLARE @nameResp VARCHAR(100)
        ,@documentResp VARCHAR(100)
        ,@addressResp VARCHAR(100)

SELECT @nameResp=p.ds_razao_social
        ,@documentResp=p.cd_cpf_cnpj
        ,@addressResp=p.ds_endereco
FROM CI_MIDDLEWAY..mw_produtor p
WHERE p.id_produtor=@id_produtor

DECLARE @nameUser VARCHAR(1000)
        ,@documentUser VARCHAR(1000)
        ,@emailUser VARCHAR(1000)

SELECT @nameUser=tau.name
        ,@documentUser=tau.document
        ,@emailUser=tau.email
FROM CI_MIDDLEWAY..to_admin_user tau
WHERE tau.id=@id_to_admin_user

DECLARE @NomRedPeca varchar(6) = LEFT(@NomPeca, (CASE WHEN LEN(@NomPeca) < 6 THEN LEN(@NomPeca) ELSE 6 END)),
        @NomResPeca varchar(35) = LEFT(CONCAT(LEFT(@nameResp, (CASE WHEN LEN(@nameResp) < 15 THEN LEN(@nameResp) ELSE 15 END)),@documentResp,LEFT(@addressResp, (CASE WHEN LEN(@addressResp) < 15 THEN LEN(@addressResp) ELSE 15 END))),35),
        @DatIniPeca datetime = GETDATE(),
        @DatFimPeca datetime = GETDATE(),
        @Autor varchar(50) = '',
        @Diretor varchar(50) = '',
        @Elenco varchar(50) = '',
        @StaPeca char(1) = 'A',
        @CodImagem int = 0,
        @InVendeSite char(1) = '1',
        @QtHrAnteced int = 0,
        @QtParcelas int = 1,
        @qt_dias_apresentacao int = 1,
        @in_obriga_rg char(1) = '0',
        @in_obriga_tel char(1) = '0',
        @in_obriga_nome char(1) = @in_obriga_cpf,        
        @in_BIN_Itau char(1) = '0',
        @qt_BIN_por_cpf smallint = @qt_ingressos_por_cpf,
        @nm_relatorio varchar(100) = NULL,
        @codtipbilhetebin   int = null,
        @in_impressao_comprovante char(1) = '0',
        @RazSocial varchar(80) = LEFT(@nameResp, (CASE WHEN LEN(@nameResp) < 80 THEN LEN(@nameResp) ELSE 80 END)),
        @CpfCnpj varchar(14) = @documentResp,
        @NomeContato varchar(60) = LEFT(@nameUser, (CASE WHEN LEN(@nameUser) < 60 THEN LEN(@nameUser) ELSE 60 END)),
        @EmailContato varchar(100) = LEFT(@emailUser, (CASE WHEN LEN(@emailUser) < 100 THEN LEN(@emailUser) ELSE 100 END)),
        @DDDTelFixo varchar(3) = '',
        @TelFixo varchar(12) = '',
        @DDDCel varchar(3) = '',
        @Cel varchar(12) = '',
        @NomBanco varchar(50) = '',
        @NumBanco varchar(6) = '',
        @NumAgencia varchar(8) = '',
        @TipPoupancaCc char(1) = '',
        @NumConta varchar(8) = '',
        @QtdPrazoRepasseDias integer = 0,
        @ValTaxaRepasse numeric(11,2) = 0, 
        @ValTaxaCartaoCred numeric(11,2) = 0,
        @ValTaxaCartaoDeb numeric(11,2) = 0,
        @qt_ingressos_por_promocao smallint = 999,
        @in_obriga_cod_barra char(1) = '0',
        @ObrigaCpfPos char(1) = '0', 
        @ImprimiCanhotoPOS char(1) = '0',
        @ExibeTelaAssinante char(1) = '0'

IF (@codPeca IS NULL)
BEGIN
    SELECT @CodPeca = COALESCE((SELECT MAX(CodPeca) FROM tabPeca),0) + 1

    INSERT INTO tabPeca (CodPeca, NomPeca, CodTipPeca, NomRedPeca
        , NomResPeca, TemDurPeca, CenPeca, DatIniPeca
        , DatFinPeca, Autor, Diretor , Elenco
        , StaPeca, CodImagem, in_vende_site, qt_hr_anteced
        , qt_parcelas, qt_dias_apresentacao, in_obriga_cpf, in_obriga_rg
        , in_obriga_tel, in_obriga_nome, qt_ingressos_por_cpf , in_BIN_Itau
        , qt_BIN_por_cpf, nm_relatorio, codtipbilhetebin, in_impressao_comprovante
        , id_local_evento, RazSocial , CpfCnpj , QtdPrazoRepasseDias 
        , NomBanco , NumBanco , NumAgencia , NumConta 
        , TipPoupancaCc , NomeContato , DDDTelFixo , TelFixo 
        , DDDCel , Cel , EmailContato , ValTaxaCartaoCred 
        , ValTaxaCartaoDeb , ValIngresso , ValTaxaRepasse , qt_ingressos_por_promocao 
        , in_obriga_cod_barra, QtIngrPorPedido, ObrigaCpfPos, ImprimiCanhotoPOS
        , ExibeTelaAssinante, id_produtor,id_to_admin_user)

    VALUES (@CodPeca, @NomPeca, @CodTipPeca, @NomRedPeca
        , @NomResPeca, @TemDurPeca, @CenPeca, @DatIniPeca
        , @DatFimPeca, @Autor, @Diretor , @Elenco
        , @StaPeca, @CodImagem, @InVendeSite, @QtHrAnteced
        , @QtParcelas, @qt_dias_apresentacao, @in_obriga_cpf, @in_obriga_rg
        , @in_obriga_tel, @in_obriga_nome, @qt_ingressos_por_cpf, @in_BIN_Itau
        , @qt_BIN_por_cpf, @nm_relatorio, @codtipbilhetebin, @in_impressao_comprovante
        , @id_local_evento, @RazSocial , @CpfCnpj , @QtdPrazoRepasseDias 
        , @NomBanco , @NumBanco , @NumAgencia , @NumConta 
        , @TipPoupancaCc , @NomeContato , @DDDTelFixo , @TelFixo 
        , @DDDCel , @Cel , @EmailContato , @ValTaxaCartaoCred 
        , @ValTaxaCartaoDeb , @ValIngresso , @ValTaxaRepasse , @qt_ingressos_por_promocao
        , @in_obriga_cod_barra, @QtIngrPorPedido, @ObrigaCpfPos , @ImprimiCanhotoPOS
        , @ExibeTelaAssinante, @id_produtor, @id_to_admin_user)
END
ELSE
BEGIN
    UPDATE tabPeca
    SET NomPeca=@NomPeca
        ,CodTipPeca=@CodTipPeca
        ,TemDurPeca=@TemDurPeca
        ,CenPeca=@CenPeca
        ,id_local_evento=@id_local_evento
        ,ValIngresso=@ValIngresso
        ,QtIngrPorPedido=@QtIngrPorPedido
        ,in_obriga_cpf=@in_obriga_cpf
        ,in_obriga_nome=@in_obriga_cpf
        ,qt_ingressos_por_cpf=@qt_ingressos_por_cpf
        ,NomRedPeca=@NomRedPeca
        ,NomResPeca=@NomResPeca
        ,RazSocial=@RazSocial
        ,CpfCnpj=@CpfCnpj
    WHERE CodPeca=@CodPeca
END


DECLARE @id_evento INT

SELECT @id_evento=id_evento FROM CI_MIDDLEWAY..mw_evento WHERE CodPeca=@CodPeca AND id_base=@id_base

SELECT @id_local_evento=id_local_evento FROM CI_MIDDLEWAY..mw_evento where id_evento=@id_evento

SELECT @id_genre=g.id
FROM CI_MIDDLEWAY..genre g
WHERE RTRIM(LTRIM(g.name))=RTRIM(LTRIM(@genre)) COLLATE SQL_Latin1_General_Cp1251_CS_AS

UPDATE CI_MIDDLEWAY..mw_evento_extrainfo
SET [description]=@description
    ,meta_description=@meta_description
    ,meta_keyword=@meta_keyword
    ,id_genre=@id_genre
    ,showInBanner=@showInBanner
    ,bannerDescription=@bannerDescription
    ,opening_time=@opening_time
    ,insurance_policy=@insurance_policy
WHERE id_evento=@id_evento

UPDATE CI_MIDDLEWAY..search
SET outofdate=1
WHERE id_evento=@id_evento

UPDATE CI_MIDDLEWAY..home
SET outofdate=1
WHERE id_evento=@id_evento

SELECT @id_evento id_evento
        ,@codPeca codPecca