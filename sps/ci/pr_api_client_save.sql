-- exec sp_executesql N'EXEC pr_api_client_save @P1,@P2,@P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'65214422873',N'Matt Murdock',N'mattmurdock@gmail.com'
-- exec sp_executesql N'EXEC pr_api_client_save @P1,@P2,@P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'65214422873',N'Matt Murdock',N'mattmurdock@gmail.com'

CREATE PROCEDURE dbo.pr_api_client_save (@document VARCHAR(100), @name VARCHAR(4000), @email VARCHAR(4000))

AS

-- DECLARE @document VARCHAR(100) = '352673495'
--         ,@name VARCHAR(4000) = 'Matt Murdock'
--         ,@email VARCHAR(4000) = 'mattmurdock@gmail.com'


    
SET NOCOUNT ON;

DECLARE @Codigo INT
        ,@added BIT = 0

SET @document=REPLACE(REPLACE(@document, '-', ''), '.', '')

SELECT
    @Codigo=c.Codigo
FROM tabCliente c
WHERE c.CPF=@document

IF @Codigo IS NULL
BEGIN
    --SELECT @Codigo = (SELECT COALESCE(MAX(Codigo),0)+1 FROM tabCliente)
    SET @added = 1;
    INSERT INTO tabCliente (Nome,Sexo,DatNascimento
                            ,RG,CPF,Endereco,Numero
                            ,Complemento,Bairro,Cidade,UF
                            ,CEP,DDD,Telefone,Ramal
                            ,DDDCelular,Celular,DDDComercial,TelComercial
                            ,RamComercial,MalDireta,EMail,StaCliente,Assinatura,CardBin
                            ,id_quotapartner)
    VALUES (@name, NULL, NULL
            , NULL, @document, NULL, NULL
            , NULL, NULL, NULL, NULL
            , NULL,NULL, NULL, NULL
            , NULL, NULL, NULL, NULL
            , NULL, NULL, @email, 'A', NULL, NULL
            , NULL)
    SET @Codigo = SCOPE_IDENTITY()
END
ELSE
BEGIN
    SET @added = 0;
    UPDATE tabCliente SET Nome=@name,EMail=@email,StaCliente='A' WHERE Codigo=@Codigo
END


SELECT @Codigo id