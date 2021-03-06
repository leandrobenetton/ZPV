/****** Object:  StoredProcedure [dbo].[ZPV_DeleteCoBlnProcessSp]    Script Date: 10/29/2014 12:25:04 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_DeleteCoBlnProcessSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_DeleteCoBlnProcessSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_DeleteCoBlnProcessSp]    Script Date: 10/29/2014 12:25:04 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/* $Header: /ApplicationDB/Stored Procedures/CoUpdateCommSlsmanSp.sp 11    3/04/10 10:28a Dahn $ */
/*
***************************************************************
*                                                             *
*                           NOTICE                            *
*                                                             *
*   THIS SOFTWARE IS THE PROPERTY OF AND CONTAINS             *
*   CONFIDENTIAL INFORMATION OF INFOR AND/OR ITS AFFILIATES   *
*   OR SUBSIDIARIES AND SHALL NOT BE DISCLOSED WITHOUT PRIOR  *
*   WRITTEN PERMISSION. LICENSED CUSTOMERS MAY COPY AND       *
*   ADAPT THIS SOFTWARE FOR THEIR OWN USE IN ACCORDANCE WITH  *
*   THE TERMS OF THEIR SOFTWARE LICENSE AGREEMENT.            *
*   ALL OTHER RIGHTS RESERVED.                                *
*                                                             *
*   (c) COPYRIGHT 2010 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
*************************************************************** 
*/
/* $Archive: /ApplicationDB/Stored Procedures/CoUpdateCommSlsmanSp.sp $
 *
 * SL8.02 11 rs4588 Dahn Thu Mar 04 10:28:55 2010
 * RS4588 Copyright header changes
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_DeleteCoBlnProcessSp] (
  @CoNum   CoNumType
, @CoLine  CoLineType
, @Infobar InfobarType OUTPUT
)
AS

-- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
IF OBJECT_ID(N'dbo.EXTGEN_ZPV_DeleteCoBlnProcessSp') IS NOT NULL
BEGIN
  DECLARE @EXTGEN_SpName sysname
  SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_DeleteCoBlnProcessSp'
  -- Invoke the ETP routine, passing in (and out) this routine's parameters:
  DECLARE @EXTGEN_Severity int
  EXEC @EXTGEN_Severity = @EXTGEN_SpName
     @CoNum
     , @CoLine
     , @Infobar OUTPUT

  -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
  IF @EXTGEN_Severity <> 1
     RETURN @EXTGEN_Severity
END
-- End of Generic External Touch Point code.
 
DECLARE
  @Severity     INT
, @InfobarText  InfobarType

SELECT
  @Severity = 0

declare 
	@CoCuit			varchar(20),
	@CoCustNum		CustNumType,
	@CoTaxCode1		TaxCodeType,
	@CoTaxCode2		TaxCodeType,
	@CoFrtTaxCode1	TaxCodeType,
	@CoFrtTaxCode2	TaxCodeType,
	@CoMiscTaxCode1 TaxCodeType,
	@CoMiscTaxCode2 TaxCodeType,
	@CoFrtTaxRate	TaxRateType,
	@CoMiscTaxRate	TaxRateType,
	@CoDate			DateType,
	@CoPrice		AmountType,
	@CoSalesTax1	AmountType,
	@CoSalesTax2	AmountType,
	@CoDisc			AmountType,
	@CoFreight		AmountType,
	@CoFrtSalesTax1	AmountType,
	@CoFrtSalesTax2	AmountType,
	@CoMisc			AmountType,
	@CoMiscSalesTax1	AmountType,
	@CoMiscSalesTax2	AmountType
		

BEGIN
	if not exists(select 1 from coitem where coitem.co_num = @CoNum and coitem.co_line = @CoLine and coitem.qty_shipped > 0)
	begin
		DELETE FROM zla_coitem_tax
			WHERE
				co_num  = @CoNum and
				co_line = @CoLine
				
		DELETE FROM coitem
			WHERE
				co_num  = @CoNum and
				co_line = @CoLine
	end	
	else
	begin
		set @Infobar = 'Existen cantidades entregadas de esta linea, no se puede eliminar'
	end		
END

return @severity	


GO

