
-- exec sp_executesql N'EXEC pr_ticketoffice_shoppingcart_tickettype @P1,@P2,@P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',N'4161',N'7'
ALTER PROCEDURE pr_ticketoffice_shoppingcart_tickettype (@id_ticketoffice_user UNIQUEIDENTIFIER, @indice INT, @id_ticket_type INT = NULL)

AS

-- DECLARE @id_ticketoffice_user UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'
--         ,@indice INT = 4161
--         ,@id_ticket_type INT = 7

SET NOCOUNT ON;

DECLARE @amount DECIMAL(19,2)
        ,@PerDesconto DECIMAL(19,2)
        ,@PerDescontoTB DECIMAL(19,2)
        ,@total INT
        ,@isFixedAmount BIT = 0
        ,@fixedAmount DECIMAL(19,2)

SELECT
    @amount=CONVERT(INT,REPLACE(CONVERT(VARCHAR(30),(CONVERT(DECIMAL(19,2),a.ValPeca))),'.',''))
    ,@PerDesconto=(se.PerDesconto/100)
FROM CI_MIDDLEWAY..mw_apresentacao ap
INNER JOIN CI_MIDDLEWAY..ticketoffice_shoppingcart tosc ON ap.id_apresentacao=tosc.id_apresentacao AND tosc.indice=@indice
INNER JOIN tabApresentacao a ON ap.CodApresentacao=a.CodApresentacao
INNER JOIN tabSala s ON a.CodSala=s.CodSala
INNER JOIN tabSetor se ON s.CodSala=se.CodSala
WHERE tosc.id_ticketoffice_user=@id_ticketoffice_user


IF @id_ticket_type IS NOT NULL
BEGIN
    SELECT
        @PerDescontoTB=(PerDesconto/100)
        ,@isFixedAmount=(CASE WHEN tb.vl_preco_fixo IS NULL OR tb.vl_preco_fixo = 0 THEN 0 ELSE 1 END)
        ,@fixedAmount=(CASE WHEN tb.vl_preco_fixo IS NULL OR tb.vl_preco_fixo = 0 THEN 0 ELSE (tb.vl_preco_fixo) END)
    FROM tabTipBilhete tb
    WHERE tb.CodTipBilhete=@id_ticket_type

    IF @isFixedAmount = 1
    BEGIN
        SET @amount = @fixedAmount;
    END
    ELSE
    BEGIN
        SET @amount=@amount/100
        SET @amount=@amount-(@amount*@PerDesconto)
        SET @amount=@amount-(@amount*@PerDescontoTB)
    END

    SET @total = CONVERT(INT,REPLACE(CONVERT(VARCHAR(30),(CONVERT(DECIMAL(19,2),@amount))),'.',''))
    UPDATE CI_MIDDLEWAY..ticketoffice_shoppingcart SET id_ticket_type=@id_ticket_type, amount_topay=@total WHERE id_ticketoffice_user=@id_ticketoffice_user AND indice=@indice
END
ELSE 
BEGIN
    SET @amount=@amount/100
    SET @amount=@amount-(@amount*@PerDesconto)
    SET @total = CONVERT(INT,REPLACE(CONVERT(VARCHAR(30),(CONVERT(DECIMAL(19,2),@amount))),'.',''))

    UPDATE CI_MIDDLEWAY..ticketoffice_shoppingcart SET id_ticket_type=NULL, amount_topay=@total WHERE id_ticketoffice_user=@id_ticketoffice_user AND indice=@indice
END
-- select @total, @id_ticket_type

-- select * from CI_MIDDLEWAY..ticketoffice_shoppingcart

-- select vl_preco_fixo*100 from tabTipBilhete where CodTipBilhete=7