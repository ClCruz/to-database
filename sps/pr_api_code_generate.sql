-- CREATE PROCEDURE dbo.pr_api_code_generate (@key VARCHAR(1000))

-- AS
-- DECLARE @key VARCHAR(1000)

DECLARE @key VARCHAR(1000) = 'qp_d46f770a04254154a8406a040d26c106e69b8414eee6486f92b12824b768eb8f'

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        ,@active BIT
        ,@code VARCHAR(1000)
        ,@id BIGINT
SELECT
@id_partner=qp.id_partner
,@active=qp.active
FROM CI_MIDDLEWAY..quota_partner qp
WHERE qp.[key]=@key


INSERT INTO CI_MIDDLEWAY..api_code (created, code, id_partner)
SELECT GETDATE(), NULL, @id_partner

SELECT @id = @@IDENTITY


IF OBJECT_ID('tempdb.dbo.#code', 'U') IS NOT NULL
    DROP TABLE #code; 

CREATE TABLE #code (code VARCHAR(15));
INSERT INTO #code EXEC CI_MIDDLEWAY..seqapipurchasecode @id;


SELECT @code=code FROM #code

UPDATE CI_MIDDLEWAY..api_code SET code=@code WHERE id=@id


SELECT @code code

-- SET @code = REPLACE(newid(),'-','')+REPLACE(newid(),'-','')+REPLACE(newid(),'-','')

-- SELECT @code