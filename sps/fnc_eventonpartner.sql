CREATE FUNCTION dbo.fnc_eventonpartner (@id_evento INT, @uniquename VARCHAR(1000))

RETURNS BIT

AS
BEGIN
    DECLARE @has BIT = 0

    SELECT @has = 1
    FROM CI_MIDDLEWAY..mw_evento e
    INNER JOIN CI_MIDDLEWAY..partner_database pd ON e.id_base=pd.id_base
    INNER JOIN CI_MIDDLEWAY..[partner] p ON pd.id_partner=p.id
    WHERE e.id_evento=@id_evento AND p.uniquename=@uniquename
    
    RETURN @has;
END