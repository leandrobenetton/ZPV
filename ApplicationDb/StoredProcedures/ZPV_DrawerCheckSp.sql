/****** Object:  StoredProcedure [dbo].[ZPV_DrawerCheckSp]    Script Date: 16/01/2015 03:13:13 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_DrawerCheckSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_DrawerCheckSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_DrawerCheckSp]    Script Date: 16/01/2015 03:13:13 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_DrawerCheckSp] (
	@Drawer			varchar(15),
	@CheckInUser	UsernameType,
	@Infobar	InfobarType   OUTPUT
)
AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

DECLARE
  @Severity             INT
SET @Severity = 0
SET @Infobar  = NULL


IF NOT EXISTS(SELECT 1 FROM zpv_drawer drw 
			WHERE	drw.drawer		= @Drawer
				AND drw.check_in	= 0) --Caja Abierta
BEGIN
	IF NOT EXISTS(SELECT 1 FROM zpv_drawer drw 
			WHERE	drw.drawer		= @Drawer
				AND drw.check_in	= 1
				AND drw.check_in_user = @CheckInUser) --Ver usuario
	BEGIN
		SET @Severity = 16
		SET @Infobar = 'La caja está abierta por otro usuario, no se puede utilizar'
	END
END	

RETURN @Severity
GO
