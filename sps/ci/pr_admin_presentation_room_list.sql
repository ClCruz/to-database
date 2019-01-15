
ALTER PROCEDURE dbo.pr_admin_presentation_room_list 

AS

-- DECLARE @codPeca INT = 147

SET NOCOUNT ON;

DECLARE @id_base INT
SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT
    s.CodSala
    ,s.NomSala
    ,ISNULL((SELECT TOP 1 1 FROM tabSalDetalhe sub WHERE sub.CodSala=s.CodSala AND sub.TipObjeto = 'C'),0) isconfigured
FROM tabSala s
ORDER BY s.NomSala