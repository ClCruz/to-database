CREATE PROCEDURE dbo.pr_genre_get (@id INT)

AS

SET NOCOUNT ON;

SELECT
g.id
,g.[name]
,g.active
FROM CI_MIDDLEWAY..genre g
WHERE g.id=@id