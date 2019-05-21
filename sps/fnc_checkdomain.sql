CREATE FUNCTION dbo.fnc_checkdomain (@domainsite VARCHAR(100), @domainbase VARCHAR(100))

RETURNS BIT

AS
BEGIN
    DECLARE @RET BIT = 0;

    IF LOWER(@domainsite) = LOWER(@domainbase)
        SET @RET = 1

    IF @domainsite = 'localhost' AND @RET = 0
    BEGIN
        IF @domainbase = 'ci_localhost'
            SET @RET = 1
    END

    IF @domainsite = 'sazarte' AND @RET = 0
    BEGIN
        IF @domainbase = 'sazarteingressos'
            SET @RET = 1
    END

    RETURN @RET;
END