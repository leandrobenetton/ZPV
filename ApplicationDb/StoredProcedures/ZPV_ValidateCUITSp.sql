/****** Object:  StoredProcedure [dbo].[ZPV_ValidateCUITSp]    Script Date: 10/29/2014 12:24:24 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ValidateCUITSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_ValidateCUITSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ValidateCUITSp]    Script Date: 10/29/2014 12:24:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_ValidateCUITSp] (
	@CUIT		varchar(30),
	@Infobar    Infobar        OUTPUT
)
AS

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

BEGIN
	if not exists(select * from zrt_rg1817 where cuit = @Cuit)
	begin
		set @Severity = 16
		set @Infobar = 'CUIT Ingresado no valido'
		return @Severity
	end
END

return @severity



GO

