ALTER TABLE dbo.tabSala ADD
	id_local_evento INT NULL

ALTER TABLE dbo.tabSala ADD
	nameonsite varchar(1000) NULL

ALTER TABLE dbo.tabSala ADD
	isLegacy BIT NULL

UPDATE dbo.tabSala SET isLegacy = 1

-- select * from CI_MIDDLEWAY..mw_apresentacao where id_apresentacao=167593
-- select * from CI_MIDDLEWAY..mw_evento where id_evento=22727
-- select * from CI_MIDDLEWAY..mw_base where id_base=219
-- select * from tabSalDetalhe
ALTER TABLE dbo.tabSalDetalhe ADD
	active BIT NULL
GO
ALTER TABLE dbo.tabSalDetalhe ADD CONSTRAINT
	DF_tabSalDetalhe_active DEFAULT 1 FOR active
GO

ALTER TABLE dbo.tabSalDetalhe ADD
	allowweb BIT NULL
ALTER TABLE dbo.tabSalDetalhe ADD CONSTRAINT
	DF_tabSalDetalhe_allowweb DEFAULT 1 FOR allowweb
GO



ALTER TABLE dbo.tabSalDetalhe ADD CONSTRAINT
	DF_tabSalDetalhe_allowticketoffice DEFAULT 1 FOR allowticketoffice
GO
