ALTER TABLE dbo.tabSala ADD
	id_local_evento INT NULL

ALTER TABLE dbo.tabSala ADD
	isLegacy BIT NULL

UPDATE dbo.tabSala SET isLegacy = 1

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

ALTER TABLE dbo.tabSalDetalhe ADD
	allowticketoffice BIT NULL
ALTER TABLE dbo.tabSalDetalhe ADD CONSTRAINT
	DF_tabSalDetalhe_allowticketoffice DEFAULT 1 FOR allowticketoffice
GO
