CREATE PROCEDURE dbo.pr_ad_save
           (@id UNIQUEIDENTIFIER, @id_partner uniqueidentifier,@isactive bit,@startdate datetime
           ,@enddate datetime,@title varchar(1000),@content varchar(5000)
           ,@link varchar(5000),@type varchar(100),@image varchar(1000)
           ,@campaign varchar(100),@name varchar(500),@priority int
           ,@index int)

AS

-- DECLARE @id UNIQUEIDENTIFIER, @id_partner uniqueidentifier,@isactive bit
--         ,@startdate datetime,@enddate datetime,@title varchar(1000)
--         ,@content varchar(5000),@link varchar(5000),@type varchar(100)
--         ,@image varchar(1000),@campaign varchar(100),@name varchar(500)
--         ,@priority int,@index int

SET NOCOUNT ON;

IF @id = '00000000-0000-0000-0000-000000000000'
    SET @id = NULL

DECLARE @has BIT = 0;

IF @id IS NOT NULL
BEGIN
    SELECT @has = 1 FROM CI_MIDDLEWAY..ad WHERE id=@id
END


IF @has=1
BEGIN
INSERT INTO [dbo].[ad]
           ([id_partner]
           ,[isactive]
           ,[startdate]
           ,[enddate]
           ,[title]
           ,[content]
           ,[link]
           ,[type]
           ,[image]
           ,[campaign]
           ,[name]
           ,[priority]
           ,[index])
     VALUES
           (@id_partner
           ,@isactive
           ,@startdate
           ,@enddate
           ,@title
           ,@content
           ,@link
           ,@type
           ,@image
           ,@campaign
           ,@name
           ,@priority
           ,@index)
END
ELSE
BEGIN
    UPDATE [dbo].[ad]
    SET [id_partner] = @id_partner
        ,[isactive] = @isactive
        ,[startdate] = @startdate
        ,[enddate] = @enddate
        ,[title] = @title
        ,[content] = @content
        ,[link] = @link
        ,[type] = @type
        ,[image] = @image
        ,[campaign] = @campaign
        ,[name] = @name
        ,[priority] = @priority
        ,[index] = @index
    WHERE id=@id

END


SELECT 1 success
        ,'Salvo com sucesso' msg