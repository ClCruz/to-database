-- exec sp_executesql N'EXEC pr_genre_save @P1, @P2, @P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'',N'SCI-FI',N'1'

ALTER PROCEDURE dbo.pr_genre_save (@id INT, @name VARCHAR(1000), @active BIT)

AS


SET NOCOUNT ON;

SET @name = RTRIM(LTRIM(@name));

IF @id IS NOT NULL AND @id<>0
BEGIN
    UPDATE CI_MIDDLEWAY..genre SET [name]=@name, active=@active WHERE id=@id
END
ELSE
BEGIN
    DECLARE @idDb INT = 0

    SELECT @idDb = id FROM CI_MIDDLEWAY..genre WHERE lower([name])=lower(@name)

    IF @idDb = 0 OR @idDb IS NULL
    BEGIN
        SELECT @idDb = MAX(id)+1 FROM CI_MIDDLEWAY..genre

        INSERT INTO CI_MIDDLEWAY..genre (id, [name], active) VALUES (@idDb, @name, 1);
    END
END


SELECT 1 success
        ,'Salvo com sucesso.' msg