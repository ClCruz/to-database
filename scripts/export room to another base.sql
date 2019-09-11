begin tran
commit


DECLARE @codSala INT = 0
        ,@indice INT = 0

SELECT @codSala=MAX(sub.CodSala)+1 FROM viveringressos.dbo.tabSala sub
SELECT @indice=MAX(sub.indice)+1 FROM viveringressos.dbo.tabSalDetalhe sub
-- SELECT MAX(sub.indice) FROM viveringressos.dbo.tabSalDetalhe sub

INSERT INTO viveringressos.dbo.tabSala(CodSala,NomSala,NomRedSala
,CadNumerada,StaSala,Altura
,Largura,CodEmpresa,NomeImagemSite
,AlturaSite,LarguraSite,IngressoNumerado
,in_venda_mesa,DescTitulo,DescComplemento
,TamanhoLugar,FotoImagemSite,id_local_evento
,nameonsite,isLegacy)
select @codSala,s.NomSala,s.NomRedSala
,s.CadNumerada,s.StaSala,s.Altura
,s.Largura,s.CodEmpresa,s.NomeImagemSite
,s.AlturaSite,s.LarguraSite,s.IngressoNumerado
,s.in_venda_mesa,s.DescTitulo,s.DescComplemento
,s.TamanhoLugar,s.FotoImagemSite,s.id_local_evento
,s.nameonsite,s.isLegacy from tabsala s where s.CodSala=2;


-- sp_help tabsaldetalhe
INSERT INTO viveringressos.dbo.tabSetor (CodSala,CodSetor,NomSetor
,PerDesconto,CorSetor,[Status])
select @codSala,CodSetor,NomSetor,PerDesconto,CorSetor,[Status] from tabSetor where CodSala=2

INSERT INTO viveringressos..tabSalDetalhe (Indice,NomObjeto,ConObjeto
                                            ,CodSala,CodSetor,PosX
                                            ,PosY,TipObjeto,PosXSite
                                            ,PosYSite,ClasseObj,ImgVisaoLugar
                                            ,ImgVisaoLugarFoto,active,allowweb
                                            ,allowticketoffice)
SELECT number,t.NomObjeto,t.ConObjeto
,@codSala,t.CodSetor,t.PosX
,t.PosY,t.TipObjeto,t.PosXSite
,t.PosYSite,t.ClasseObj,t.ImgVisaoLugar
,t.ImgVisaoLugarFoto,t.active,t.allowweb
,t.allowticketoffice FROM (SELECT
sd.Indice,sd.NomObjeto,sd.ConObjeto
,sd.CodSala,sd.CodSetor,sd.PosX
,sd.PosY,sd.TipObjeto,sd.PosXSite
,sd.PosYSite,sd.ClasseObj,sd.ImgVisaoLugar
,sd.ImgVisaoLugarFoto,sd.active,sd.allowweb
,sd.allowticketoffice
,ROW_NUMBER() OVER (order by sd.indice)+@indice [number]
FROM tabSalDetalhe sd 
WHERE sd.CodSala=2) as t
INNER JOIN CI_MIDDLEWAY..loop_numbers ln ON t.number=ln.n
