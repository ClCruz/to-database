ALTER FUNCTION dbo.fnc_baserename (@sql VARCHAR(1000))

RETURNS VARCHAR(1000)

AS
BEGIN
    DECLARE @RET VARCHAR(1000) = @sql;

    IF LOWER(@sql) = 'ci_localhost'
        SET @RET = 'localhost'
    IF LOWER(@sql) = 'sazarteingressos'
        SET @RET = 'sazarte'
    IF LOWER(@sql) = 'antigos'
        SET @RET = 'sazarte'
    IF LOWER(@sql) = 'construcaoteatral'
        SET @RET = 'ingressoparatodos'


    RETURN @RET;
END