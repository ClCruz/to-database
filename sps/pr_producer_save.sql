exec sp_executesql N'EXEC pr_producer_save @P1, @P2, @P3, @P4, @P5, @P6, @P7, @P8, @P9, @P10, @P11',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000),@P4 nvarchar(4000),@P5 nvarchar(4000),@P6 nvarchar(4000),@P7 nvarchar(4000),@P8 nvarchar(4000),@P9 nvarchar(4000),@P10 nvarchar(4000),@P11 nvarchar(4000)',N'F2177E5E-F727-4906-948D-4EEA9B9BBD0E',N'',N'12640243470',N'email@email.com',N'13',N'444444444',N'22',N'22222222222222',N'endereço da pessoa',N'nome da pessoa',N'1'

ALTER PROCEDURE dbo.pr_producer_save (@id_user UNIQUEIDENTIFIER
    ,@id_produtor INT
    ,@cd_cpf_cnpj VARCHAR(14)
    ,@cd_email VARCHAR(100)
    ,@ds_ddd_celular VARCHAR(2)
    ,@ds_celular VARCHAR(100)
    ,@ds_ddd_telefone VARCHAR(2)
    ,@ds_telefone VARCHAR(100)
    ,@ds_endereco VARCHAR(1000)
    ,@ds_razao_social VARCHAR(250)
    ,@in_ativo BIT
    )

AS

-- DECLARE @id_user UNIQUEIDENTIFIER = 'F2177E5E-F727-4906-948D-4EEA9B9BBD0E'
--     ,@id_produtor INT = ''
--     ,@cd_cpf_cnpj VARCHAR(14) = '126.402.434-70'
--     ,@cd_email VARCHAR(100) = 'email@email.com'
--     ,@ds_ddd_celular VARCHAR(2) = '13'
--     ,@ds_celular VARCHAR(100) = '444444444'
--     ,@ds_ddd_telefone VARCHAR(2) = '13'
--     ,@ds_telefone VARCHAR(100) = '22222222'
--     ,@ds_endereco VARCHAR(1000) = 'endereço da pessoa'
--     ,@ds_razao_social VARCHAR(250) = 'nome da pessoa'
--     ,@in_ativo BIT = '1'

SET NOCOUNT ON;

IF @id_produtor = ''
    SET @id_produtor = NULL

IF @cd_cpf_cnpj IS NOT NULL
    SET @cd_cpf_cnpj = REPLACE(REPLACE(REPLACE(@cd_cpf_cnpj, '-', ''), '/', ''), '.', '')

IF @id_produtor IS NULL
BEGIN
    SELECT @id_produtor=id_produtor FROM CI_MIDDLEWAY..mw_produtor WHERE cd_cpf_cnpj=@cd_cpf_cnpj
END

IF @id_produtor IS NULL
BEGIN
    INSERT INTO CI_MIDDLEWAY..mw_produtor (ds_razao_social,cd_cpf_cnpj,ds_nome_contato
                                            ,cd_email,ds_ddd_telefone,ds_telefone
                                            ,ds_ddd_celular,ds_celular,in_ativo
                                            ,id_gateway,ds_endereco)
    VALUES (@ds_razao_social, @cd_cpf_cnpj, ''
            ,@cd_email, @ds_ddd_telefone, @ds_telefone
            ,@ds_ddd_celular, @ds_celular, @in_ativo
            ,6, @ds_endereco)
    
    SET @id_produtor = SCOPE_IDENTITY()
END
ELSE
BEGIN
    UPDATE p
        SET p.cd_email=@cd_email
            ,p.ds_celular=@ds_celular
            ,p.ds_ddd_celular=@ds_ddd_celular
            ,p.ds_ddd_telefone=@ds_ddd_telefone
            ,p.ds_endereco=@ds_endereco
            ,p.ds_razao_social=@ds_razao_social
            ,p.ds_telefone=@ds_telefone
            ,p.in_ativo=@in_ativo
    FROM CI_MIDDLEWAY..mw_produtor p
    WHERE p.id_produtor=@id_produtor
END

DECLARE @has BIT = 0

SELECT @has=1 FROM CI_MIDDLEWAY..producer_user WHERE id_produtor=@id_produtor AND id_admin_user=@id_user

IF @has = 0
BEGIN
    INSERT INTO CI_MIDDLEWAY..producer_user (id_produtor,id_admin_user) VALUES (@id_produtor, @id_user);
END