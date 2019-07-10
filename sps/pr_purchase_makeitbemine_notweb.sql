CREATE PROCEDURE dbo.pr_purchase_makeitbemine_notweb (@session VARCHAR(1000), @id_client INT)

AS

-- DECLARE @session VARCHAR(1000) = 'HSM6QRO3IGOO87Q', @id_client INT = 19344

SET NOCOUNT ON;

DECLARE @id_client_isok BIT = 0
        ,@session_isok BIT = 0
        ,@sessiondb VARCHAR(1000) = ''

IF OBJECT_ID('tempdb.dbo.#bases', 'U') IS NOT NULL
    DROP TABLE #bases; 

SELECT TOP 1 @session_isok=1 FROM CI_MIDDLEWAY..mw_reserva WHERE id_session=@session


IF @session_isok = 1
BEGIN
    SELECT DISTINCT e.id_base, 0 as done
    INTO #bases
    FROM CI_MIDDLEWAY..MW_EVENTO E
    INNER JOIN CI_MIDDLEWAY..MW_APRESENTACAO A ON A.ID_EVENTO = E.ID_EVENTO
    INNER JOIN CI_MIDDLEWAY..MW_RESERVA R ON R.ID_APRESENTACAO = A.ID_APRESENTACAO
    WHERE R.id_session = @session    

    DECLARE @has BIT = 0
            ,@newid VARCHAR(1000) = @session-- REPLACE(CONVERT(VARCHAR(100),newid()),'-','')
            
    SELECT TOP 1 @has=1 FROM CI_MIDDLEWAY..current_session_client WHERE id_cliente=@id_client
    
    IF @has = 1
    BEGIN
        UPDATE CI_MIDDLEWAY..current_session_client SET created=GETDATE(), id_session=@newid WHERE id_cliente=@id_client
    END
    ELSE
    BEGIN
        INSERT INTO CI_MIDDLEWAY..current_session_client (id_cliente, id_session)
        SELECT @id_client,@newid
    END

    SELECT 1 success
            ,'' msg
            ,@newid [session]

    RETURN;
END

SELECT 0 success
        ,'Não foi possível encontrar a sessão ou o cliente.' msg
