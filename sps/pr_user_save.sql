ALTER PROCEDURE dbo.pr_user_save (@firstname VARCHAR(50), @lastname VARCHAR(50), @gender VARCHAR(50)
        , @birthdate DATETIME, @document VARCHAR(50), @documenttype INT
        , @brazilian_rg VARCHAR(22), @phone_ddd VARCHAR(2), @phone_number VARCHAR(15)
        , @zipcode VARCHAR(50), @city_state VARCHAR(50), @city VARCHAR(50)
        , @neighborhood VARCHAR(70), @address VARCHAR(150), @address_number VARCHAR(15)
        , @address_more VARCHAR(50), @login VARCHAR(100), @pass VARCHAR(32)
        , @newsletter BIT, @agree BIT, @fb VARCHAR(50)
        , @isforeign BIT, @uniquename VARCHAR(1000), @isadd BIT
        , @token VARCHAR(1000), @loggedtoken VARCHAR(1000) = NULL)

AS

SET NOCOUNT ON;

DECLARE @has BIT = 0
        ,@hasEmail BIT = 0
        ,@id_cliente INT = 0
        ,@id_estado INT = 0
        ,@cpf VARCHAR(50)
        ,@foreign VARCHAR(50)


SET @document=REPLACE(@document,'.', '')
SET @document=REPLACE(@document,'-', '')
SET @zipcode=REPLACE(@zipcode,'-', '')

IF (@loggedtoken = '')
    SET @loggedtoken = NULL;
ELSE
    SET @token = @loggedtoken;


IF @isforeign=1
BEGIN
    SELECT @has = 1, @id_cliente=c.id_cliente FROM CI_MIDDLEWAY..mw_cliente c WHERE c.uniquename_partner=@uniquename AND c.cd_rg=@document
    SET @brazilian_rg=@document;
    SET @document = '';
END
ELSE
BEGIN
    SET @documenttype = NULL;
    SET @cpf = @document;
    SELECT @has = 1, @id_cliente=c.id_cliente FROM CI_MIDDLEWAY..mw_cliente c WHERE c.uniquename_partner=@uniquename AND c.cd_cpf=@document
END

IF @isadd = 1 AND @has = 1 AND @loggedtoken IS NULL
BEGIN
    SELECT 0 success
            ,'Já existe cadastro para esse documento.' msg
            ,0 id
            ,@firstname + ' ' + @lastname [name]
            ,@login [login]
            ,@token token
    RETURN;
END

SELECT @hasEmail = 1 FROM CI_MIDDLEWAY..mw_cliente c WHERE c.uniquename_partner=@uniquename AND c.cd_email_login=@login


IF @isadd = 1 AND @hasEmail = 1 AND @loggedtoken IS NULL
BEGIN
    SELECT 0 success
            ,'Já existe cadastro para esse e-mail.' msg
            ,0 id
            ,@firstname + ' ' + @lastname [name]
            ,@login [login]
            ,@token token
    RETURN;
END


SELECT @id_estado=id_estado FROM CI_MIDDLEWAY..mw_estado WHERE lower(sg_estado)=lower(@city_state)

DECLARE @in_recebe_info VARCHAR(1) = 'N'

IF @newsletter = 1
    SET @in_recebe_info='S'

DECLARE @isnew BIT = 1

IF @has = 1
BEGIN
    UPDATE d
    SET d.ds_nome=@firstname
        ,d.ds_sobrenome=@lastname
        ,d.dt_nascimento=@birthdate
        ,d.ds_ddd_telefone=@phone_ddd
        ,d.ds_telefone=@phone_number
        ,d.ds_ddd_celular=@phone_ddd
        ,d.ds_celular=@phone_number
        ,d.cd_rg=@brazilian_rg
        ,d.cd_cpf=@cpf
        ,d.ds_endereco=@address
        ,d.ds_compl_endereco=@address_more
        ,d.ds_bairro=@neighborhood
        ,d.ds_cidade=@city
        ,d.cd_cep=@zipcode
        ,d.cd_email_login=@login
        ,d.cd_password=(CASE WHEN @pass = '' OR @pass IS NULL THEN d.cd_password ELSE @pass END)
        ,d.in_recebe_info=@in_recebe_info
        ,d.id_estado=@id_estado
        ,d.in_sexo=@gender
        ,d.id_doc_estrangeiro=@documenttype
        ,d.nr_endereco=@address_number
        ,d.token_fb=@fb
    FROM CI_MIDDLEWAY..mw_cliente d
    WHERE d.id_cliente=@id_cliente

    SET @isnew = 0;
END
ELSE
BEGIN
    SET @isnew = 1;
    SELECT @id_cliente=max(id_cliente)+1 FROM CI_MIDDLEWAY..mw_cliente;

    IF @isforeign=1
    BEGIN
        SET @document = RIGHT('00000000000000000'+CONVERT(VARCHAR(10),@id_cliente),11);
    END
--  SELECT @id_cliente, @firstname, @lastname
--                                                 ,@birthdate, @phone_ddd, @phone_number
--                                                 ,@phone_ddd, @phone_number, @brazilian_rg
--                                                 ,@cpf, @address, @address_more
--                                                 ,@neighborhood, @city, @zipcode
--                                                 ,@login, @pass, @in_recebe_info
--                                                 ,'N', 'S', @id_estado
--                                                 ,GETDATE(), @gender, @documenttype
--                                                 ,'N', @address_number, NULL
--                                                 ,NULL, @fb, @uniquename
    INSERT INTO CI_MIDDLEWAY..mw_cliente (id_cliente,ds_nome,ds_sobrenome
                                            ,dt_nascimento,ds_ddd_telefone,ds_telefone
                                            ,ds_ddd_celular,ds_celular,cd_rg
                                            ,cd_cpf,ds_endereco,ds_compl_endereco
                                            ,ds_bairro,ds_cidade,cd_cep
                                            ,cd_email_login,cd_password,in_recebe_info
                                            ,in_recebe_sms,in_concorda_termos,id_estado
                                            ,dt_inclusao,in_sexo,id_doc_estrangeiro
                                            ,in_assinante,nr_endereco,token
                                            ,dt_token_valid,token_fb,uniquename_partner)
    SELECT @id_cliente, @firstname, @lastname
                                                ,@birthdate, @phone_ddd, @phone_number
                                                ,@phone_ddd, @phone_number, @brazilian_rg
                                                ,@cpf, @address, @address_more
                                                ,@neighborhood, @city, @zipcode
                                                ,@login, @pass, @in_recebe_info
                                                ,'N', 'S', @id_estado
                                                ,GETDATE(), @gender, @documenttype
                                                ,'N', @address_number, NULL
                                                ,NULL, @fb, @uniquename

    UPDATE CI_MIDDLEWAY..mw_cliente SET token=@token, dt_token_valid=DATEADD(minute,30,GETDATE()) WHERE id_cliente=@id_cliente
END


SELECT 1 success
    ,'Cadastro efetuado com sucesso.' msg
    ,@firstname + ' ' + @lastname [name]
    ,@firstname firstname
    ,@lastname lastname
    ,@login [login]
    ,@id_cliente id
    ,@token token
    ,@isnew isnew