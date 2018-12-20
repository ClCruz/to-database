CREATE PROCEDURE dbo.pr_genre_select

AS

SET NOCOUNT ON;

SELECT
g.id
,g.[name]
,g.active
FROM CI_MIDDLEWAY..genre g
WHERE g.active=1
ORDER BY [name]