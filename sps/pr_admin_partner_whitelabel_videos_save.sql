CREATE PROCEDURE dbo.pr_admin_partner_whitelabel_videos_save (@id_partner UNIQUEIDENTIFIER
                                                            ,@fileorder INT
                                                            ,@filetype VARCHAR(100)
                                                            ,@source VARCHAR(1000))
AS


SET NOCOUNT ON;

DECLARE @uniquename varchar(1000)
        ,@has BIT = 0

SELECT @has = 1 FROM CI_MIDDLEWAY.dbo.whitelabelcontentvideo wlcv WHERE wlcv.id_partner=@id_partner AND wlcv.filetype=@filetype

SELECT @uniquename=uniquename FROM CI_MIDDLEWAY.dbo.[partner] WHERE id=@id_partner


IF @has = 1 
BEGIN
    UPDATE CI_MIDDLEWAY.dbo.whitelabelcontentvideo
    SET source=@source
    WHERE id_partner=@id_partner
    AND filetype=@filetype
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY.dbo.whitelabelcontentvideo (id_partner,uniquename,source,filetype,fileorder)
    VALUES (@id_partner, @uniquename, @source, @filetype, @fileorder)
END
