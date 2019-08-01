-- exec sp_executesql N'EXEC pr_city_list @P1,@P2,@P3',N'@P1 nvarchar(4000),@P2 nvarchar(4000),@P3 nvarchar(4000)',N'',N'1',N'500'

ALTER PROCEDURE dbo.pr_city_list (@text VARCHAR(100) = NULL, @currentPage INT = 1, @perPage INT = 10)

AS


SELECT 
  m.id_municipio
  ,RTRIM(LTRIM(m.ds_municipio)) ds_municipio
  ,m.id_estado
  ,e.ds_estado
  ,e.sg_estado
  ,m.img
  ,m.img_extra
  ,@currentPage currentPage
  ,COUNT(*) OVER() totalCount
FROM CI_MIDDLEWAY..mw_municipio m
INNER JOIN CI_MIDDLEWAY..mw_estado e ON m.id_estado=e.id_estado
WHERE ((@text IS NULL OR m.ds_municipio like '%'+@text+'%')
        OR (@text IS NULL OR e.ds_estado like '%'+@text+'%')
        OR (@text IS NULL OR e.sg_estado like '%'+@text+'%')
        )
ORDER BY RTRIM(LTRIM(m.ds_municipio))
OFFSET (@currentPage-1)*@perPage ROWS
  FETCH NEXT @perPage ROWS ONLY;