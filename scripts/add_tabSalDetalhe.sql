-- select * from tabSala where CodSala in (5,6)
-- select * from tabSetor where CodSala in (5,6)
-- 5:
-- 23 linhas 1-23 (69)
-- 11 colunas A-J

-- 6:
-- 69 linhas 1-68
-- 11 colunas A-J

DECLARE @keepLoopCol BIT = 1
        ,@keepLoopLine BIT = 1
        ,@countCol INT = 1
        ,@countLine INT = 1
        ,@maxLine INT = 23
        ,@maxCol INT = 11
        ,@howtoAddExibition INT = 68
        ,@indice INT
        ,@NomObjeto VARCHAR(100)
        ,@codSala INT = 5
        ,@codSetor INT = 1
        

-- IF OBJECT_ID('tempdb.dbo.#colsstring', 'U') IS NOT NULL
--     DROP TABLE #colsstring; 

-- CREATE TABLE #colsstring (id INT, [name] varchar(100));

-- INSERT INTO #colsstring (1,'A')

-- select * from tabSalDetalhe where CodSala=6
--delete from tabSalDetalhe where CodSala=6


WHILE (@keepLoopCol = 1)
BEGIN  
    SET @countCol = @countCol + 1;
    SET @countLine = 1;
    SET @keepLoopLine = 1;
    WHILE (@keepLoopLine = 1)
    BEGIN  
        SET @countLine = @countLine + 1;

        SELECT @indice = max(sd.Indice)+1 FROM tabSalDetalhe sd;

        SET @NomObjeto = CONVERT(VARCHAR(10),((@countLine+@howtoAddExibition)-1))+'-'+Char(64 + @countCol-1)

        -- PRINT 'Name: ' + @NomObjeto + ' / X:' + CONVERT(VARCHAR(10),@countLine) + ' / Y:' + CONVERT(VARCHAR(10),@countCol);
        INSERT INTO tabSalDetalhe (Indice,NomObjeto,ConObjeto,CodSala,CodSetor,PosX,PosY,TipObjeto,PosXSite,PosYSite,ClasseObj,ImgVisaoLugar,ImgVisaoLugarFoto)
        SELECT @indice, @NomObjeto, 'con', @codSala, @codSetor, @countLine, @countCol,'C', NULL, NULL, NULL,NULL, NULL


        IF @countLine>=@maxLine
            SET @keepLoopLine = 0
    END

    -- select @countCol, @maxCol

    IF @countCol>=@maxCol
        SET @keepLoopCol = 0

END