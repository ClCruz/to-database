-- exec sp_executesql N'EXEC pr_geteventsforcards @P1, @P2, @P3, @P4, @P5',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000)',N'Barueri',N'',N'live_dd310c796ff04199b5680a5cad098930c2ae8da63b974b43abb21d92ec5123b2',N'',N''

-- exec sp_executesql N'EXEC pr_geteventsforcards @P1, @P2, @P3, @P4, @P5',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000)',N'',N'',N'live_6bfa0de8c52f4dd0bbb53d5a61945bbddb2aaa5545644e61873f1d1cd78f6bae',N'',N''

-- EXEC pr_geteventsforcards @api='live_578abaf329f84119bb7c1e55dfdc7e0f4f20e693cd2c4bc7a5bc0a0965fae322'
-- exec sp_executesql N'EXEC pr_geteventsforcards @P1, @P2, @P3, @P4',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000)',N'',N'',N'live_279e0f576f1547faa1ac5600d7802778f3754aa3f6d44f9aabbdbb709b2ed442',N'created'

CREATE PROCEDURE dbo.pr_getcitiesforcards (@api VARCHAR(100) = NULL)

AS

SET NOCOUNT ON;

DECLARE @id_partner UNIQUEIDENTIFIER
        

SELECT TOP 1 @id_partner=p.id FROM CI_MIDDLEWAY..[partner] p WHERE p.[key]=@api OR p.key_test=@api

SELECT 
h.ds_municipio, 
m.img, 
m.img_extra 
FROM CI_MIDDLEWAY..dbo.home h
INNER JOIN CI_MIDDLEWAY..MW_EVENTO e ON h.id_evento = e.id_evento
INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base AND pd.id_partner=@id_partner
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON e.id_local_evento = le.id_local_evento
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio = m.id_municipio
GROUP BY 
h.ds_municipio,
m.img,
m.img_extra
ORDER BY
NEWID()