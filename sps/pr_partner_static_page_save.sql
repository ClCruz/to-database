--exec sp_executesql N'EXEC pr_partner_static_page_save @P1, @P2, @P3, @P4, @P5, @P6',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000)',N'live_185e1621cf994a99ba945fe9692d4bf6d66ef03a1fcc47af8ac909dbcea53fb5',N'1',N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',N'1',N'teste',N'<p>Somos uma empresa feita por gente apaixonada por entretenimento. Por isso, queremos compartilhar esse amor com outras pessoas que também sabem se divertir.</p><p><br></p><p>Nossa história vem com alguns colaboradores que através dos anos foram pioneiros em venda de ingressos para teatros, shows, partidas de futebol e que agora se encontram em um lugar novo e diferenciado, com muita tecnologia e inovação para oferecer o melhor do entretenimento para você.</p><p><br></p>'

CREATE PROCEDURE dbo.pr_partner_static_page_save (@api VARCHAR(100)
                                                , @id_static_page INT
                                                , @id_to_admin_user UNIQUEIDENTIFIER
                                                , @isvisible BIT
                                                , @title VARCHAR(MAX)
                                                , @content VARCHAR(MAX))

AS

-- DECLARE @api VARCHAR(100) = 'live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'
--         ,@id_static_page INT = 1

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

DECLARE @id UNIQUEIDENTIFIER = NULL

SELECT @id=id FROM CI_MIDDLEWAY..partner_static_page psp WHERE psp.id_partner=@id_partner AND psp.id_static_page=@id_static_page

IF @id IS NULL
BEGIN

    INSERT INTO CI_MIDDLEWAY.[dbo].[partner_static_page]
            ([id_partner]
            ,[id_to_admin_user]
            ,[title]
            ,[content]
            ,[isvisible]
            ,[id_static_page])
        VALUES
            (@id_partner
            ,@id_to_admin_user
            ,@title
            ,@content
            ,@isvisible
            ,@id_static_page)
END
ELSE
BEGIN

    UPDATE CI_MIDDLEWAY.[dbo].[partner_static_page]
    SET [changed] = GETDATE()
        ,[id_partner] = @id_partner
        ,[id_to_admin_user] = @id_to_admin_user
        ,[title] = @title
        ,[content] = @content
        ,[isvisible] = @isvisible
        ,[id_static_page] = @id_static_page
    WHERE id=@id
END



SELECT 1 success
        ,'Salvo com sucesso' msg