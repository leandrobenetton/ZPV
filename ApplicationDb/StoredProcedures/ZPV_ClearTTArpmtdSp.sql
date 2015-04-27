/****** Object:  StoredProcedure [dbo].[ZPV_ClearTTArpmtdSp]    Script Date: 16/01/2015 03:11:25 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ClearTTArpmtdSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_ClearTTArpmtdSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ClearTTArpmtdSp]    Script Date: 16/01/2015 03:11:25 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_ClearTTArpmtdSp] (
	@pUser			UsernameType
)
AS

begin
	DELETE FROM zpv_tt_arpmtd where CreatedBy = @pUser
end

GO

