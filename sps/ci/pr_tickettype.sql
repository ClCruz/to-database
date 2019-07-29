ALTER PROCEDURE dbo.pr_tickettype (@CodPeca   INT, @id_apresentacao INT) 

AS

-- use ci_localhost
-- use teatroumc
-- DECLARE @CodPeca INT = 25--45
-- 		,@id_apresentacao INT = 179913--179691
-- DECLARE @CodPeca INT = 45
-- 		,@id_apresentacao INT = 179691

SET NOCOUNT ON;

DECLARE @DatApresentacao  smalldatetime
        ,@id_base INT

SELECT @id_base=id_base FROM CI_MIDDLEWAY..mw_base where ds_nome_base_sql=DB_NAME()

SELECT @DatApresentacao=ap.dt_apresentacao
FROM CI_MIDDLEWAY..mw_apresentacao ap
WHERE ap.id_apresentacao=@id_apresentacao


SELECT
	a.CodTipBilhete, 
	(CASE WHEN a.id_promocao_controle IS NOT NULL AND pc.id_patrocinador=1 THEN a.ds_nome_site
		  ELSE  a.TipBilhete END) TipBilhete, 
	a.PerDesconto,
	(CASE WHEN a.id_promocao_controle IS NOT NULL AND pc.id_patrocinador=1 THEN 1
		  ELSE  0 END) in_obriga_cpf, 
	(CASE WHEN a.id_promocao_controle IS NOT NULL AND pc.id_patrocinador=1 THEN 1
		  ELSE  0 END) in_obriga_cartao, 
	acrdscperc = isnull((Select sum(case cx.icDebCre when 'D' then isnull(c.valor,0) else isnull(c.valor,0)*-1 end)
			From	tabTipBilhTipLcto	c
			INNER JOIN
				tabTipLanctoBilh	cx
				ON  cx.codtiplct     = c.codtiplct
				and cx.icpercvlr     = 'P'
				and cx.icusolcto    != 'B'
				and cx.inativo       = 'A'
			Where
			    c.codtipbilhete = a.codtipbilhete
			and c.dtinivig      = (Select max(c1.dtinivig) 
						 from tabTipBilhTipLcto  c1,
						      tabTipLanctoBilh   d1
						where c1.codtipbilhete = c.codtipbilhete
						  and c1.codtiplct     = c.codtiplct
						  and c1.dtinivig     <= getdate()
						  and c1.inativo       = 'A'
						  and d1.codtiplct     = c1.codtiplct
						  and d1.icpercvlr     = 'P'
						  and d1.icusolcto    != 'B'
						  and d1.inativo       = 'A')
			and c.inativo        = 'A'),0),
	acrdscvlr = isnull((Select sum(case cx.icDebCre when 'D' then isnull(c.valor,0) else isnull(c.valor,0)*-1 end)
			From	tabTipBilhTipLcto	c
			INNER JOIN
				tabTipLanctoBilh	cx
				ON  cx.codtiplct     = c.codtiplct
				and cx.icpercvlr     = 'V'
				and cx.icusolcto    != 'B'
				and cx.inativo       = 'A'
			Where
			    c.codtipbilhete = a.codtipbilhete
			and c.dtinivig      = (Select max(c1.dtinivig) 
						 from tabTipBilhTipLcto  c1,
						      tabTipLanctoBilh   d1
						where c1.codtipbilhete = c.codtipbilhete
						  and c1.codtiplct     = c.codtiplct
						  and c1.dtinivig     <= getdate()
						  and c1.inativo       = 'A'
						  and d1.codtiplct     = c1.codtiplct
						  and d1.icpercvlr     = 'V'
						  and d1.icusolcto    != 'B'
						  and d1.inativo       = 'A')
			and c.inativo        = 'A'),0),
	a.vl_preco_fixo
	,ISNULL(a.StaTipBilhMeiaEstudante, 'N') AS StaTipBilhMeiaEstudante
--	sum(case cx.icDebCre when 'D' then isnull(c.valor,0) else isnull(c.valor,0)*-1 end) as acrdscperc,
--	sum(case ex.icDebCre when 'D' then isnull(e.valor,0) else isnull(e.valor,0)*-1 end) as acrdscvlr
FROM
	tabTipBilhete 		a
LEFT JOIN CI_MIDDLEWAY..MW_PROMOCAO_CONTROLE PC
	ON PC.ID_PROMOCAO_CONTROLE = A.ID_PROMOCAO_CONTROLE
WHERE
	exists (Select 1 from tabValBilhete 		b
			Where b.CodTipBilhete = a.CodTipBilhete
			and   b.CodPeca       = @CodPeca 
			AND   @DatApresentacao BETWEEN b.DatIniDesconto AND b.DatFinDesconto)
AND 	(a.TipCaixa      = 'A')-- OR a.TipCaixa = @TipCaixa)
AND		a.StaTipBilhete  = 'A'
AND		(ISNULL(a.StaTipBilhMeia, 'N')	= 'N')
--AND		(a.codtipbilhete = @CodTipBilhete or @CodTipBilhete is null)
AND		(A.ID_PROMOCAO_CONTROLE IS NULL OR PC.CODTIPPROMOCAO IN (4, 5, 7))
ORDER BY
	a.TipBilhete

