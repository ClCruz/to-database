
-- exec sp_executesql N'EXEC pr_tickettype_event_save @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'43980',N'4',N'2019-08-01',N'2019-08-30'
-- exec sp_executesql N'EXEC pr_accountingdebittype_event_save @P1,@P2,@P3,@P4',N'@P1 nvarchar(4000),@P2 char(1),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'43980',NULL,N'2019-08-01',N'2019-08-07'

CREATE PROCEDURE dbo.pr_accountingdebittype_event_save (@id_evento INT
        ,@CodTipDebBordero INT
        ,@date_start DATETIME
        ,@date_end DATETIME)

AS

-- DECLARE @id_evento INT = 43980
--         ,@CodTipDebBordero INT = 4
--         ,@date_start DATETIME = '2019-08-07'
--         ,@date_end DATETIME = '2019-08-30'


SET NOCOUNT ON;

IF @date_start>@date_end
BEGIN
        SELECT 0 success
        ,'Datas invalidas.' msg
        RETURN;
END


DECLARE @codPeca INT
        ,@db_start DATETIME
        ,@db_end DATETIME

SELECT @codPeca=codPeca FROM CI_MIDDLEWAY..mw_evento WHERE id_evento=@id_evento

SELECT @db_start=MIN(dt_apresentacao) FROM CI_MIDDLEWAY..mw_apresentacao ap WHERE ap.id_evento=@id_evento AND in_ativo=1
SELECT @db_end=MAX(dt_apresentacao) FROM CI_MIDDLEWAY..mw_apresentacao ap WHERE ap.id_evento=@id_evento AND in_ativo=1

-- SELECT (CASE WHEN @date_start>=@db_start THEN 1 ELSE 0 END),(CASE WHEN @date_end<=@db_end THEN 1 ELSE 0 END)

-- RETURN

IF @date_start>=@db_start AND @date_end<=@db_end
BEGIN

        DECLARE @has BIT = 0

        SELECT @has = 1 FROM tabDebBordero WHERE CodTipDebBordero=@CodTipDebBordero AND CodPeca=@codPeca 

        IF @has = 1
        BEGIN
            UPDATE tabDebBordero
            SET [DatIniDebito] = @date_start
                    ,[DatFinDebito] = @date_end
            WHERE [CodTipDebBordero] = @CodTipDebBordero
            AND [CodPeca] = @CodPeca
        END
        ELSE
        BEGIN
        INSERT INTO [dbo].[tabDebBordero]
                ([CodTipDebBordero]
                ,[CodPeca]
                ,[DatIniDebito]
                ,[DatFinDebito])
        VALUES
                (@CodTipDebBordero
                ,@CodPeca
                ,@date_start
                ,@date_end)
        END

        SELECT 1 success
                ,'Salvo com sucesso' msg
END
ELSE
BEGIN
        DECLARE @Helper VARCHAR(1000) = ''
        SET @Helper = ' Data deve ser entre ' + CONVERT(VARCHAR(10), @db_start, 103) + ' '+ CONVERT(VARCHAR(10), @db_end, 103) + '.';

        SELECT 0 success
        ,'Datas invalidas.' + @Helper msg
        RETURN;
END
