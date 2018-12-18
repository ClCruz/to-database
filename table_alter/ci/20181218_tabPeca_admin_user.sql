ALTER TABLE dbo.tabPeca ADD
	id_to_admin_user uniqueidentifier NULL


ALTER TABLE dbo.tabPeca ADD
	created datetime NULL
GO
ALTER TABLE dbo.tabPeca ADD CONSTRAINT
	DF_tabPeca_created DEFAULT getdate() FOR created
GO