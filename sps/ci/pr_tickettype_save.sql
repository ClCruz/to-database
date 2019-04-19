ALTER PROCEDURE dbo.pr_tickettype_save (@id INT
,@id_base INT
,@nameWeb VARCHAR(1000)
,@nameTicketOffice VARCHAR(1000)
,@description VARCHAR(3000)
,@in_dom BIT
,@in_seg BIT
,@in_ter BIT
,@in_qua BIT
,@in_qui BIT
,@in_sex BIT
,@in_sab BIT
,@allowweb BIT
,@allowticketoffice BIT
,@isPrincipal BIT
,@isDiscount BIT
,@isHalf BIT
,@isFixed BIT
,@isPlus BIT
,@isAllotment BIT
,@vl_preco_fixo FLOAT
,@PerDesconto DECIMAL(18,2)
,@CotaMeiaEstudante INT
,@StaCalculoMeiaEstudante VARCHAR(1)
,@QtdVendaPorLote INT
,@StaTipBilhete VARCHAR(1)
,@TipCaixa VARCHAR(1)
,@TipBilhete VARCHAR(100)
,@StaTipBilhMeiaEstudante VARCHAR(1)
,@StaTipBilhMeia VARCHAR(1)
,@in_venda_site VARCHAR(1))

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0;

IF @id != 0
BEGIN
    SELECT @has = 1 FROM tabTipBilhete WHERE CodTipBilhete=@id;
END

IF @has = 1
BEGIN
    UPDATE [dbo].[tabTipBilhete]
    SET [TipBilhete] = @TipBilhete
        ,[PerDesconto] = @PerDesconto
        ,[StaTipBilhete] = @StaTipBilhete
        ,[TipCaixa] = @TipCaixa
        ,[in_venda_site] = @in_venda_site
        ,[ds_nome_site] = @nameWeb
        ,[in_dom] = @in_dom
        ,[in_seg] = @in_seg
        ,[in_ter] = @in_ter
        ,[in_qua] = @in_qua
        ,[in_qui] = @in_qui
        ,[in_sex] = @in_sex
        ,[in_sab] = @in_sab
        ,[vl_preco_fixo] = @vl_preco_fixo
        ,[StaTipBilhMeia] = @StaTipBilhMeia
        ,[StaTipBilhMeiaEstudante] = @StaTipBilhMeiaEstudante
        ,[StaCalculoMeiaEstudante] = @StaCalculoMeiaEstudante
        ,[CotaMeiaEstudante] = @CotaMeiaEstudante
        ,[QtdVendaPorLote] = @QtdVendaPorLote
        ,[isFixed] = @isFixed
        ,[isPrincipal] = @isPrincipal
        ,[isHalf] = @isHalf
        ,[isDiscount] = @isDiscount
        ,[isPlus] = @isPlus
        ,[isAllotment] = @isAllotment
        ,[allowweb] = @allowweb
        ,[allowticketoffice] = @allowticketoffice
        ,[nameWeb] = @nameWeb
        ,[nameTicketOffice] = @nameTicketOffice
        ,[description] = @description
    WHERE CodTipBilhete=@id
END
ELSE
BEGIN
    DECLARE @CodTipBilhete INT
    SELECT @CodTipBilhete=MAX(CodTipBilhete)+1 FROM tabTipBilhete
    IF @CodTipBilhete IS NULL
    BEGIN
        SET @CodTipBilhete = 1
    END
    SET @id = @CodTipBilhete

    INSERT INTO [dbo].[tabTipBilhete]
            ([CodTipBilhete]
            ,[TipBilhete]
            ,[PerDesconto]
            ,[StaTipBilhete]
            ,[TipCaixa]
            ,[CobraComs]
            ,[ImpVlIngresso]
            ,[ImpDSBilhDest]
            ,[in_venda_site]
            ,[ds_nome_site]
            ,[in_dom]
            ,[in_seg]
            ,[in_ter]
            ,[in_qua]
            ,[in_qui]
            ,[in_sex]
            ,[in_sab]
            ,[vl_preco_fixo]
            ,[StaTipBilhMeia]
            ,[StaTipBilhMeiaEstudante]
            ,[StaCalculoMeiaEstudante]
            ,[CotaMeiaEstudante]
            ,[StaCalculoPorSala]
            ,[QtdVendaPorLote]
            ,[Img1Promocao]
            ,[Img2Promocao]
            ,[in_hot_site]
            ,[id_promocao_controle]
            ,[InPacote]
            ,[isFixed]
            ,[isPrincipal]
            ,[isOld]
            ,[isHalf]
            ,[isDiscount]
            ,[isPlus]
            ,[isAllotment]
            ,[hasImage]
            ,[allowweb]
            ,[allowticketoffice]
            ,[nameWeb]
            ,[nameTicketOffice]
            ,[description])
        VALUES
            (@CodTipBilhete
            ,@TipBilhete
            ,@PerDesconto
            ,@StaTipBilhete
            ,@TipCaixa
            ,NULL --@CobraComs
            ,1--@ImpVlIngresso
            ,0--@ImpDSBilhDest
            ,@in_venda_site
            ,@nameWeb
            ,@in_dom
            ,@in_seg
            ,@in_ter
            ,@in_qua
            ,@in_qui
            ,@in_sex
            ,@in_sab
            ,@vl_preco_fixo
            ,@StaTipBilhMeia
            ,@StaTipBilhMeiaEstudante
            ,@StaCalculoMeiaEstudante
            ,@CotaMeiaEstudante
            ,'S'--@StaCalculoPorSala
            ,@QtdVendaPorLote
            ,''--@Img1Promocao
            ,''--@Img2Promocao
            ,0--@in_hot_site
            ,NULL--@id_promocao_controle
            ,'N'--@InPacote
            ,@isFixed
            ,@isPrincipal
            ,0
            ,@isHalf
            ,@isDiscount
            ,@isPlus
            ,@isAllotment
            ,0
            ,@allowweb
            ,@allowticketoffice
            ,@nameWeb
            ,@nameTicketOffice
            ,@description)
END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,DB_NAME() directoryname
        ,@id id