ALTER PROCEDURE pr_admin_partner_whitelabelcontent_save (@id_partner UNIQUEIDENTIFIER
,@json_meta_description VARCHAR(MAX)
,@json_meta_keywords VARCHAR(MAX)
,@json_template VARCHAR(100)
,@json_info_title VARCHAR(MAX)
,@json_info_description VARCHAR(MAX)
,@json_info_cnpj VARCHAR(50)
,@json_info_companyname VARCHAR(MAX)
,@scss_colors_primary VARCHAR(50)
,@scss_colors_secondary VARCHAR(50))

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@id UNIQUEIDENTIFIER
        ,@uniquename VARCHAR(100);

SELECT @has = 1, @id=id FROM CI_MIDDLEWAY..[whitelabelcontent] WHERE id_partner=@id_partner;

SELECT @uniquename = uniquename FROM CI_MIDDLEWAY..[partner] WHERE id=@id_partner;


IF @has = 1
BEGIN
    UPDATE wlc
      SET wlc.json_meta_description=@json_meta_description
          ,wlc.json_meta_keywords=@json_meta_keywords
          ,wlc.json_template=@json_template
          ,wlc.json_info_title=@json_info_title
          ,wlc.json_info_description=@json_info_description
          ,wlc.json_info_cnpj=@json_info_cnpj
          ,wlc.json_info_companyname=@json_info_companyname
          ,wlc.scss_colors_primary=@scss_colors_primary
          ,wlc.scss_colors_secondary=@scss_colors_secondary
    FROM CI_MIDDLEWAY..whitelabelcontent wlc
    WHERE id=@id
END
ELSE
BEGIN
    INSERT INTO CI_MIDDLEWAY..whitelabelcontent (id_partner,uniquename,json_meta_description
                                                ,json_meta_keywords,json_template,json_info_title
                                                ,json_info_description,json_info_cnpj,json_info_companyname
                                                ,scss_colors_primary,scss_colors_secondary)
    VALUES (@id_partner,@uniquename,@json_meta_description
                                                ,@json_meta_keywords,@json_template,@json_info_title
                                                ,@json_info_description,@json_info_cnpj,@json_info_companyname
                                                ,@scss_colors_primary,@scss_colors_secondary)
END
