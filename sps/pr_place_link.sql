--exec sp_executesql N'EXEC pr_place_save @P1, @P2, @P3, @P4, @P5, @P6',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000)',N'',N'Local de Teste',N'R. Dr. Carvalho de Mendonça, 777 - Marapé, Santos - SP, 11070-103',N'1',N'4',N'13'
--exec sp_executesql N'EXEC pr_place_save @P1, @P2, @P3, @P4, @P5, @P6',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000)',N'857',N'Local de Teste',N'13',N'4',N'1',N'R. Dr. Carvalho de Mendonça, 777 - Marapé, Santos - SP, 11070-103'

CREATE PROCEDURE dbo.pr_place_link (@api VARCHAR(100), @id_user UNIQUEIDENTIFIER, @id_local_evento INT)

AS

SET NOCOUNT ON;
DECLARE @has BIT = 0;
DECLARE @id_partner UNIQUEIDENTIFIER

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT @has = 1 FROM CI_MIDDLEWAY..[partner_local_evento] WHERE id_partner=@id_partner AND id_local_evento=@id_local_evento

IF @has = 1
BEGIN
    DELETE FROM CI_MIDDLEWAY..partner_local_evento WHERE id_partner=@id_partner AND id_local_evento=@id_local_evento
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY..partner_local_evento (id_partner, id_local_evento)
        SELECT @id_partner, @id_local_evento
END