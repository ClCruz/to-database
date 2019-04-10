CREATE PROCEDURE dbo.pr_organizator_save (@id uniqueidentifier, @name VARCHAR(1000), @id_partner uniqueidentifier, @document VARCHAR(50))

AS

-- DECLARE @id uniqueidentifier, @name VARCHAR(1000), @id_partner uniqueidentifier, @document VARCHAR(50)

DECLARE @has BIT
        ,@idexist UNIQUEIDENTIFIER

SELECT @has = 1, @idexist=id FROM CI_MIDDLEWAY..organizator WHERE document=@document AND id_partner=@id_partner AND id!=@id 


IF @has = 1
BEGIN
    SELECT 0 success
            ,'Já existe organizador para esse documento' msg
            ,@idexist id
    
END
ELSE
BEGIN
    DECLARE @hasbyid BIT

    SELECT @hasbyid = 1 FROM CI_MIDDLEWAY..organizator WHERE id=@id AND id_partner=@id_partner

    IF @hasbyid = 1
    BEGIN
        UPDATE [CI_MIDDLEWAY].[dbo].[organizator]
        SET [name] = @name
            ,[document] = @document
        WHERE id=@id AND id_partner=@id_partner
    END
    ELSE
    BEGIN
        SET @id = NEWID();

        INSERT INTO [CI_MIDDLEWAY].[dbo].[organizator]
                ([id]
                ,[created]
                ,[name]
                ,[id_partner]
                ,[document])
            VALUES
                (@id
                ,GETDATE()
                ,@name
                ,@id_partner
                ,@document)
    END
END

SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@id id