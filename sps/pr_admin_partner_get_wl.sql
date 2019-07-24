--exec sp_executesql N'EXEC pr_admin_partner_get_wl @P1, @P2',N'@P1 nvarchar(4000),@P2 nvarchar(4000)',N'00000000-0000-0000-0000-000000000000',N'bringressos'

ALTER PROCEDURE dbo.pr_admin_partner_get_wl (@id UNIQUEIDENTIFIER, @uniquenamesearch VARCHAR(1000))

AS

SET NOCOUNT ON;

IF @id = '00000000-0000-0000-0000-000000000000'
BEGIN
        SELECT @id=id FROM CI_MIDDLEWAY..[partner] p WHERE p.uniquename=@uniquenamesearch
END

-- DECLARE @id UNIQUEIDENTIFIER = '1a0fdc45-e934-4c9e-bf4c-8fc8c11474a1';

DECLARE @domain VARCHAR(1000)
        ,@uniquename VARCHAR(500)
        ,@name VARCHAR(1000)
        ,@databaseOK BIT = 0
        ,@userOK BIT = 0
        ,@databaseStatus VARCHAR(1000) = 'not_init'
        ,@userStatus VARCHAR(1000) = 'not_init'
        ,@apikey VARCHAR(200) = ''
        ,@videoURI_MP4 VARCHAR(1000) = ''
        ,@videoURI_WEBM VARCHAR(1000) = ''
        ,@fb_appid VARCHAR(1000) = ''

        ,@json_ga VARCHAR(100)
        ,@json_meta_description VARCHAR(MAX)
        ,@json_meta_keywords VARCHAR(MAX)
        ,@json_template VARCHAR(100)
        ,@json_info_title VARCHAR(MAX)
        ,@json_info_description VARCHAR(MAX)
        ,@json_info_cnpj VARCHAR(50)
        ,@json_info_companyaddress VARCHAR(MAX)
        ,@json_info_companyname VARCHAR(MAX)
        ,@scss_colors_primary VARCHAR(50)
        ,@scss_colors_secondary VARCHAR(50)
        ,@scss_colors_text VARCHAR(50)
        ,@scss_image_background VARCHAR(50)

SELECT
    @domain = p.domain
    ,@name = p.name
    ,@uniquename = p.uniquename
    ,@apikey=p.[key]
    ,@fb_appid=p.fb_appid
FROM CI_MIDDLEWAY..[partner] p
WHERE 
p.id=@id

-- SET @uniquename='bringressos'

SELECT @databaseOK = 1 FROM master.sys.databases WHERE [name]=@uniquename
SELECT @userOK = 1 FROM master.sys.server_principals WHERE [name]='api.'+@uniquename

SELECT @databaseStatus=[status] FROM CI_MIDDLEWAY..whitelabelconf WHERE id_partner=@id AND [type]='database'
SELECT @userStatus=[status] FROM CI_MIDDLEWAY..whitelabelconf WHERE id_partner=@id AND [type]='user'

SELECT @json_meta_description=wlc.json_meta_description
        ,@json_ga=wlc.json_ga
        ,@json_meta_keywords=wlc.json_meta_keywords
        ,@json_template=wlc.json_template
        ,@json_info_title=wlc.json_info_title
        ,@json_info_description=wlc.json_info_description
        ,@json_info_cnpj=wlc.json_info_cnpj
        ,@json_info_companyaddress=wlc.json_info_companyaddress
        ,@json_info_companyname=wlc.json_info_companyname
        ,@scss_colors_primary=wlc.scss_colors_primary
        ,@scss_colors_secondary=wlc.scss_colors_secondary
        ,@scss_colors_text=wlc.scss_colors_text
        ,@scss_image_background=wlc.scss_image_background
FROM CI_MIDDLEWAY..whitelabelcontent wlc
WHERE wlc.id_partner=@id


SELECT 
    @id id
    ,@domain domain
    ,@name [name]
    ,@uniquename uniquename
    ,@databaseOK databaseOK
    ,@userOK userOK
    ,@databaseStatus databaseStatus
    ,@userStatus userStatus
    ,@json_ga json_ga
    ,@json_meta_description json_meta_description
    ,@json_meta_keywords json_meta_keywords
    ,@json_template json_template
    ,@json_info_title json_info_title
    ,@json_info_description json_info_description
    ,@json_info_cnpj json_info_cnpj
    ,@json_info_companyaddress json_info_companyaddress
    ,@json_info_companyname json_info_companyname
    ,@scss_colors_primary scss_colors_primary
    ,@scss_colors_secondary scss_colors_secondary
    ,@scss_colors_text scss_colors_text
    ,@scss_image_background scss_image_background
    ,@apikey apikey
    ,@fb_appid fb_appid