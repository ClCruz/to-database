CREATE PROCEDURE dbo.pr_event_save (@api VARCHAR(100)
    ,@id_produtor INT
    ,@id_to_admin_user UNIQUEIDENTIFIER
    ,@CodPeca INT
    ,@NomPeca VARCHAR(35)
    ,@CodTipPeca INT
    ,@TemDurPeca int
    ,@CenPeca int
    ,@id_local_evento int
    ,@ValIngresso numeric(11,2)
    ,@description VARCHAR(MAX)
    ,@address VARCHAR(1000)
    ,@meta_description VARCHAR(1000)
    ,@meta_keyword VARCHAR(1000)
    ,@showInBanner BIT = 0
    ,@bannerDescription VARCHAR(1000) = NULL
    ,@QtIngrPorPedido smallint = 4
    ,@in_obriga_cpf char(1) = '0'
    ,@qt_ingressos_por_cpf smallint = 4)

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@id_base INT
        ,@youshallnotpass BIT = 1

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api
SELECT TOP 1 @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()
SELECT @youshallnotpass=0 FROM CI_MIDDLEWAY..partner_database pd WHERE pd.id_base=@id_base AND pd.id_partner=@id_partner

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
        ,@id_genre INT = NULL
        ,@genre VARCHAR(MAX)

SELECT @id_evento=id_evento FROM CI_MIDDLEWAY..mw_evento WHERE CodPeca=@CodPeca AND id_base=@id_base

SELECT @id_local_evento=id_local_evento FROM CI_MIDDLEWAY..mw_evento where id_evento=@id_evento

SELECT @genre=TipPeca FROM tabTipPeca WHERE CodTipPeca=@CodTipPeca

SELECT @id_genre=g.id
FROM CI_MIDDLEWAY..genre g
WHERE RTRIM(LTRIM(g.name))=RTRIM(LTRIM(@genre)) COLLATE SQL_Latin1_General_Cp1251_CS_AS

IF @address IS NOT NULL AND @address != '' AND @id_local_evento IS NOT NULL
BEGIN
    UPDATE CI_MIDDLEWAY..mw_local_evento
    SET ds_googlemaps=@address
    WHERE id_local_evento=@id_local_evento
END

UPDATE CI_MIDDLEWAY..mw_evento_extrainfo
SET [description]=@description
    ,meta_description=@meta_description
    ,meta_keyword=@meta_keyword
    ,id_genre=@id_genre
    ,showInBanner=@showInBanner
    ,bannerDescription=@bannerDescription
WHERE id_evento=@id_evento

UPDATE CI_MIDDLEWAY..search
SET outofdate=1
WHERE id_evento=@id_evento

UPDATE CI_MIDDLEWAY..home
SET outofdate=1
WHERE id_evento=@id_evento