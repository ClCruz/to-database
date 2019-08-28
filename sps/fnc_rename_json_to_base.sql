ALTER FUNCTION dbo.fnc_rename_json_to_base (@sql VARCHAR(1000))

RETURNS VARCHAR(1000)

AS
BEGIN
    DECLARE @RET VARCHAR(1000) = @sql;

    IF LOWER(@sql) = 'localhost'
        SET @RET = 'ci_localhost'
    IF LOWER(@sql) = 'sazarte'
        SET @RET = 'sazarteingressos'
    IF LOWER(@sql) = 'ingressoparatodos'
        SET @RET = 'construcaoteatral'


    RETURN @RET;
END