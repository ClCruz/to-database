ALTER TABLE dbo.tabTipBilhete ADD
	isFixed bit NULL,
	isPrincipal bit NULL,
    isOld bit NULL,
	isHalf bit NULL,
	isDiscount bit NULL,
	isPlus bit NULL,
	isAllotment bit NULL,
	isNoValue bit NULL,
	isPOS bit NULL,
	hasImage bit NULL,
	allowweb bit NULL,
	allowticketoffice bit NULL,
	allowapi bit NULL,
	nameWeb VARCHAR(1000),
	nameTicketOffice VARCHAR(1000),
	nameAPI VARCHAR(1000),
	[description] VARCHAR(3000)
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isFixed DEFAULT 0 FOR isFixed
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isPrincipal DEFAULT 0 FOR isPrincipal
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isOld DEFAULT 0 FOR isOld
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isHalf DEFAULT 0 FOR isHalf
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isDiscount DEFAULT 0 FOR isDiscount
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isPlus DEFAULT 0 FOR isPlus
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isPOS DEFAULT 0 FOR isPOS
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_isNoValue DEFAULT 0 FOR isNoValue
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_hasImage DEFAULT 0 FOR hasImage
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_allowweb DEFAULT 1 FOR allowweb
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_allowticketoffice DEFAULT 1 FOR allowticketoffice
GO
ALTER TABLE dbo.tabTipBilhete ADD CONSTRAINT
	DF_tabTipBilhete_allowapi DEFAULT 1 FOR allowapi
GO


UPDATE tabTipBilhete SET isPOS=0,isNoValue=0,isFixed=0,isPrincipal=0,isOld=0,isHalf=0,isDiscount=0,isPlus=0,isAllotment=0,hasImage=0,allowticketoffice=1,allowweb=1,allowapi=1;

UPDATE tabTipBilhete SET nameWeb=TipBilhete, nameTicketOffice=TipBilhete, nameAPI=TipBilhete;

UPDATE tabTipBilhete SET isFixed=1 WHERE CodTipBilhete=7;
UPDATE tabTipBilhete SET isPrincipal=1 WHERE CodTipBilhete=1;
UPDATE tabTipBilhete SET isHalf=1 WHERE CodTipBilhete=4;
UPDATE tabTipBilhete SET isAllotment=1 WHERE CodTipBilhete=5;
UPDATE tabTipBilhete SET isOld=1 WHERE CodTipBilhete in (0,2,3,6);

ALTER TABLE dbo.tabTipBilhete
	DROP CONSTRAINT UKtabTipBilhete