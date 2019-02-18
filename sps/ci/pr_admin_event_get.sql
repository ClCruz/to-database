ALTER PROCEDURE dbo.pr_admin_event_get (@id_user UNIQUEIDENTIFIER, @id_evento INT)

AS

SET NOCOUNT ON;

DECLARE @id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()
SELECT
    p.CodPeca
    ,e.id_evento
    ,e.id_base
    ,p.id_produtor
    ,p.NomPeca
    ,p.CodTipPeca
    ,eei.id_genre
    ,p.TemDurPeca
    ,p.CenPeca
    ,p.id_local_evento
    ,le.id_municipio
    ,m.id_estado
    ,p.ValIngresso
    ,eei.[description]
    ,eei.meta_description
    ,eei.meta_keyword
    ,eei.showInBanner
    ,eei.bannerDescription
    ,eei.cardbigimage
    ,eei.imageoriginal
    ,eei.cardimage
    ,eei.free_installments
    ,eei.max_installments
    ,eei.interest_rate
    ,eei.opening_time
    ,eei.insurance_policy
    ,eei.uri
    ,p.QtIngrPorPedido
    ,p.qt_ingressos_por_cpf
    ,p.in_obriga_cpf
    ,eei.ticketoffice_askemail
    ,CONVERT(VARCHAR(10),p.DatIniPeca,103) DatIniPeca
    ,CONVERT(VARCHAR(10),p.DatFinPeca,103) DatFinPeca
    ,ISNULL((SELECT TOP 1 1 FROM tabApresentacao sub WHERE sub.CodPeca=p.CodPeca),0) hasPresentantion
FROM tabPeca p
INNER JOIN CI_MIDDLEWAY..mw_evento e ON p.CodPeca=e.CodPeca AND e.id_base=@id_base
INNER JOIN CI_MIDDLEWAY..mw_evento_extrainfo eei ON e.id_evento=eei.id_evento
INNER JOIN CI_MIDDLEWAY..to_admin_user_base taub ON taub.id_base=e.id_base AND taub.id_to_admin_user=@id_user AND taub.active=1
INNER JOIN CI_MIDDLEWAY..mw_local_evento le ON p.id_local_evento=le.id_local_evento
INNER JOIN CI_MIDDLEWAY..mw_municipio m ON le.id_municipio=m.id_municipio
WHERE e.id_evento=@id_evento