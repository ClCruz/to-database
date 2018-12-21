CREATE PROCEDURE dbo.pr_state_select

AS

SELECT
e.id_estado
,e.ds_estado
,e.sg_estado
FROM CI_MIDDLEWAY..mw_estado e
ORDER BY e.ds_estado