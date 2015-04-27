/****** Object:  StoredProcedure [dbo].[ZPV_SetDefaultShipToSp]    Script Date: 11/07/2014 12:51:50 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_SetDefaultShipToSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_SetDefaultShipToSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_SetDefaultShipToSp]    Script Date: 11/07/2014 12:51:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_SetDefaultShipToSp] (
	@CoNum		CoNumType,
	@CustNum	CustNumType,
	@CustSeq	CustSeqType,
	@Infobar	InfobarType   OUTPUT
)
AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_SetDefaultShipToSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_SetDefaultShipToSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @CoNum
         , @CustNum
         , @CustSeq
         , @Infobar OUTPUT
 
      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

IF @CustSeq is not null and @CustSeq <> 0
BEGIN
	update coitem	
		set coitem.cust_seq = @CustSeq
	where coitem.co_num = @CoNum
END

return @severity

GO

