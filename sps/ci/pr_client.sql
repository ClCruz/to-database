
ALTER PROCEDURE dbo.pr_client (@nin VARCHAR(14), @rg VARCHAR(15),@name VARCHAR(50),@email VARCHAR(150), @cardbin VARCHAR(6),@phoneddd VARCHAR(10),@phonenumber VARCHAR(20),@phoneramal VARCHAR(4),@makeCode BIT,@partner BIT, @id_quotapartner UNIQUEIDENTIFIER = NULL)

AS

--DECLARE @nin VARCHAR(14), @rg VARCHAR(15),@name VARCHAR(50),@email VARCHAR(150),@phoneddd VARCHAR(10),@phonenumber VARCHAR(20),@phoneramal VARCHAR(4)

SET NOCOUNT ON;

DECLARE @Codigo INT
        ,@codReserva VARCHAR(10)
        ,@cpfAux VARCHAR(14)
        ,@added BIT = 0

SET @cpfAux=REPLACE(REPLACE(@nin, '-', ''), '.', '')

IF @partner = 1
BEGIN
    IF @id_quotapartner IS NOT NULL AND @id_quotapartner != '00000000-0000-0000-0000-000000000000'
    BEGIN
        SELECT
            @Codigo=c.Codigo
        FROM tabCliente c
        WHERE c.id_quotapartner=@id_quotapartner
    END
    ELSE
    BEGIN
        SELECT
            @Codigo=c.Codigo
        FROM tabCliente c
        WHERE lower(c.Nome)=lower(@name) COLLATE SQL_Latin1_General_CP1_CI_AI
    END
END
ELSE
BEGIN
    SELECT
        @Codigo=c.Codigo
    FROM tabCliente c
    WHERE c.CPF=@cpfAux
END

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
            , @rg, @cpfAux, NULL, NULL
            , NULL, NULL, NULL, NULL
            , NULL,@phoneddd, @phonenumber, @phoneramal
            , NULL, NULL, NULL, NULL
            , NULL, NULL, @email, 'A', NULL, @cardbin
            , @id_quotapartner)
    SET @Codigo = SCOPE_IDENTITY()
END
ELSE
BEGIN
    SET @added = 0;
    UPDATE tabCliente SET Nome=@name, RG=@rg, DDD=@phoneddd, Telefone=@phonenumber, CardBin=@cardbin, Ramal=@phoneramal, EMail=@email
    , StaCliente='A', id_quotapartner=@id_quotapartner WHERE Codigo=@Codigo
END

IF @makeCode = 1
BEGIN
    IF OBJECT_ID('tempdb.dbo.#codReserva', 'U') IS NOT NULL
        DROP TABLE #codReserva; 

    CREATE TABLE #codReserva (codReserva VARCHAR(10));

    INSERT INTO #codReserva EXEC CI_MIDDLEWAY..seqCodReserva @Codigo;

    SELECT @codReserva=codReserva FROM #codReserva
END

DECLARE @cpfDB VARCHAR(100)
SELECT @cpfDB = c.CPF FROM tabCliente c WHERE c.Codigo=@Codigo

SELECT @Codigo codigo
        ,@codReserva codReserva
        ,(CASE WHEN @cpfDB IS NULL THEN 0 ELSE 1 END) hasCPF
        ,@added added