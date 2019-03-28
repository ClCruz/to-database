--exec sp_executesql N'EXEC pr_ad_save @P1, @P2, @P3, @P4, @P5, @P6, @P7, @P8, @P9, @P10, @P11, @P12, @P13',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 nvarchar(4000),@P12 nvarchar(4000),@P13 nvarchar(4000)',N'00000000-0000-0000-0000-000000000000',N'75FAE8CE-07BD-4125-8252-9CFEA9708087',N'1',N'2019-03-01 00:00',N'2019-04-30 00:00',N'ADMIN - BRINGRESSSOS',N'teste',N'https://www.google.com.br',N'banner',N'cap',N'teste',N'',N''
--delete from ci_middleway..ad
ALTER PROCEDURE dbo.pr_ad_save
           (@id UNIQUEIDENTIFIER, @id_partner uniqueidentifier,@isactive bit
           ,@startdate datetime,@enddate datetime,@title varchar(1000)
           ,@content varchar(5000),@link varchar(5000),@type varchar(100)
           ,@campaign varchar(100),@name varchar(500),@priority int
           ,@index int)

AS
-- select * from CI_MIDDLEWAY..ad

-- DECLARE @id UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000', @id_partner uniqueidentifier = '75FAE8CE-07BD-4125-8252-9CFEA9708087',@isactive bit = 1
--         ,@startdate datetime = '2019-03-01 00:00',@enddate datetime = '2019-04-30 00:00',@title varchar(1000) = 'Titulo'
--         ,@content varchar(5000) = 'Tanto faz',@link varchar(5000) = 'https://www.google.com.br',@type varchar(100) = 'banner'
--         ,@campaign varchar(100) = 'dddk',@name varchar(500)='teste'
--         ,@priority int = '',@index int = ''

SET NOCOUNT ON;

IF @id = '00000000-0000-0000-0000-000000000000'
    SET @id = NULL

DECLARE @has BIT = 0;

IF @id IS NOT NULL
BEGIN
    SELECT @has = 1 FROM CI_MIDDLEWAY..ad WHERE id=@id
END
IF @has=0
BEGIN
SET @id = NEWID()
INSERT INTO [dbo].[ad]
           ([id]
           ,[id_partner]
           ,[isactive]
           ,[startdate]
           ,[enddate]
           ,[title]
           ,[content]
           ,[link]
           ,[type]
           ,[campaign]
           ,[name]
           ,[priority]
           ,[index])
     VALUES
           (@id
           ,@id_partner
           ,@isactive
           ,@startdate
           ,@enddate
           ,@title
           ,@content
           ,@link
           ,@type
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
        ,[campaign] = @campaign
        ,[name] = @name
        ,[priority] = @priority
        ,[index] = @index
    WHERE id=@id

END


SELECT 1 success
        ,'Salvo com sucesso' msg
        ,@id directoryname