ALTER PROCEDURE dbo.pr_user_resetpass (@login VARCHAR(1000), @uniquename VARCHAR(100))

AS

-- DECLARE @login VARCHAR(1000) = 'blcoccaro@gmail.com', @uniquename VARCHAR(100)='localhost'
SET NOCOUNT ON;

DECLARE @id_cliente INT = NULL
        ,@fb VARCHAR(1000) = NULL
        ,@name VARCHAR(1000) = NULL 
        ,@email VARCHAR(1000) = NULL

SELECT TOP 1 @id_cliente = id_cliente, @fb = token_fb, @name = ds_nome, @email = cd_email_login FROM CI_MIDDLEWAY..mw_cliente WHERE cd_email_login=@login AND uniquename_partner=@uniquename

IF @id_cliente IS NULL
BEGIN
    SELECT 0 success
            ,0 showerror
            ,'Não foi possível achar o e-mail informado' msg
            ,'' token
            ,'' [name]
            ,'' email
    RETURN; 
END

IF @id_cliente IS NOT NULL AND (@fb != '')
BEGIN
    SELECT 0 success
            ,1 showerror
            ,'Login por facebook' msg
            ,'' token
            ,'' [name]
            ,'' email
    RETURN; 
END

DECLARE @token VARCHAR(1000) = REPLACE(CONVERT(VARCHAR(100),NEWID()),'-','') + REPLACE(CONVERT(VARCHAR(100),NEWID()),'-','') + REPLACE(CONVERT(VARCHAR(100),NEWID()),'-','') + REPLACE(CONVERT(VARCHAR(100),NEWID()),'-','')

UPDATE CI_MIDDLEWAY..mw_cliente SET token_reset=@token WHERE id_cliente=@id_cliente

SELECT 1 success
        ,0 showerror
        ,'Sucesso' msg
        ,@token token
        ,@name [name]
        ,@email email