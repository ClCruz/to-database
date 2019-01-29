ALTER PROCEDURE pr_ticketoffice_user_add_base (@id UNIQUEIDENTIFIER)

AS

-- DECLARE @id UNIQUEIDENTIFIER = 'FEEF6152-0886-449D-A7B9-0CBE89DD60CD'

SET NOCOUNT ON;

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

DECLARE @has BIT = 0
        ,@active BIT = 0

SELECT TOP 1 @has = 1 FROM CI_MIDDLEWAY..ticketoffice_user_base WHERE id_ticketoffice_user=@id AND id_base=@id_base

SELECT TOP 1 @active = active FROM CI_MIDDLEWAY..to_admin_user_base WHERE id_to_admin_user=@id AND id_base=@id_base

IF @has = 1
BEGIN
    UPDATE CI_MIDDLEWAY..ticketoffice_user_base SET active=@active WHERE id_ticketoffice_user=@id AND id_base=@id_base
    RETURN;
END


DECLARE @tou_login VARCHAR(1000), @tou_name VARCHAR(1000), @tou_email VARCHAR(1000)

SELECT TOP 1
@tou_login = tou.[login]
,@tou_name = tou.name
,@tou_email = tou.email
FROM CI_MIDDLEWAY..ticketoffice_user tou
WHERE tou.id=@id AND tou.active=1

DECLARE @CodCaixa INT, @TipCaixa VARCHAR(1)='C', @StaCaixa VARCHAR(1) = 'A', @Maquina VARCHAR(30) = SUBSTRING(REPLACE(CONVERT(VARCHAR(36),newid()),'-','') ,1,30), @id_canal_venda INT=1, @DescrCaixa VARCHAR(50)=SUBSTRING(@tou_login,1,50)
        ,@CodUsuario INT, @NomUsuario VARCHAR(30)=SUBSTRING(@tou_login,1,30), @Login VARCHAR(10)=SUBSTRING(REPLACE(CONVERT(VARCHAR(36),newid()),'-','') ,1,10), @SenUsuario VARCHAR(25)=SUBSTRING(REPLACE(CONVERT(VARCHAR(36),newid()),'-','') ,1,25), @CodCargo VARCHAR(1)='G', @StaUsuario INT=1

SELECT TOP 1 @CodCaixa=id 
FROM CI_MIDDLEWAY..ticketoffice_base_idhelper WHERE id not in (SELECT CodCaixa FROM tabCaixa)

SELECT TOP 1 @CodUsuario=id 
FROM CI_MIDDLEWAY..ticketoffice_base_idhelper WHERE id not in (SELECT CodUsuario FROM tabUsuario)

IF @CodCaixa IS NOT NULL AND @CodUsuario IS NOT NULL
BEGIN

    INSERT INTO tabCaixa (CodCaixa, TipCaixa, StaCaixa, Maquina, id_canal_venda, DescrCaixa)
    SELECT @codCaixa, @TipCaixa, @StaCaixa, @Maquina, @id_canal_venda, @DescrCaixa

    INSERT INTO tabUsuario (CodUsuario, NomUsuario, Login,  SenUsuario, CodCargo)
    VALUES (@CodUsuario, @NomUsuario,  @Login, @SenUsuario, @CodCargo)

    INSERT INTO CI_MIDDLEWAY..ticketoffice_user_base (id_ticketoffice_user, id_base, codCaixa, codUsuario)
    SELECT @id, @id_base, @codCaixa, @codUsuario


END

SELECT @CodCaixa codCaixa, @CodUsuario codUsuario