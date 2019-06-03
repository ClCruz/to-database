-- exec sp_executesql N'EXEC pr_quotapartner_save @P1, @P2, @P3, @P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'00000000-0000-0000-0000-000000000000',N'teste',N'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5',N'1'

ALTER PROCEDURE dbo.pr_quotapartner_save (@id UNIQUEIDENTIFIER, @name VARCHAR(1000), @api VARCHAR(100), @active BIT)

AS

-- DECLARE @id UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000', @name VARCHAR(1000) = 'teste', @api VARCHAR(100) = 'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5', @active BIT = 1

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SET @name = RTRIM(LTRIM(@name));

IF @id IS NOT NULL AND @id<>'00000000-0000-0000-0000-000000000000'
BEGIN
    UPDATE CI_MIDDLEWAY..quota_partner SET [name]=@name, active=@active WHERE id=@id
END
ELSE
BEGIN
    DECLARE @key VARCHAR(100) 
    SET @key = CONCAT('qp_', LOWER(REPLACE(CONVERT(VARCHAR(100),NEWID()),'-','')),LOWER(REPLACE(CONVERT(VARCHAR(100),NEWID()),'-','')));

    INSERT INTO CI_MIDDLEWAY..quota_partner (id, [name], [key], id_partner, active) VALUES (NEWID(), @name, @key, @id_partner, 1);
END


SELECT 1 success
        ,'Salvo com sucesso.' msg