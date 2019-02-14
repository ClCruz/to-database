--exec dbo.pr_purchase_payment_method_hoursinadvance 910

ALTER PROCEDURE dbo.pr_purchase_payment_method_hoursinadvance (@id INT)

AS

SELECT TOP 1
    ISNULL(QT_HR_ANTECED,0) QT_HR_ANTECE
FROM CI_MIDDLEWAY..MW_MEIO_PAGAMENTO 
WHERE CD_MEIO_PAGAMENTO = @id