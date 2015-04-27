/****** Object:  StoredProcedure [dbo].[ZPV_GetGenericCustTypeSp]    Script Date: 10/29/2014 12:27:37 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GetGenericCustTypeSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GetGenericCustTypeSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GetGenericCustTypeSp]    Script Date: 10/29/2014 12:27:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/* $Header: /ApplicationDB/Stored Procedures/GetVendorParmSp.sp 7     3/04/10 1:23p Dahn $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZAR_GetVendorInfoSp.sp $
 *
 * SL9.00 7 ljb LBenetton Thu Apr 17 13:00:00 2014
 * Initial Program
 *
 */
CREATE PROCEDURE [dbo].[ZPV_GetGenericCustTypeSp]  (
	@GenericCustType	CustTypeType output
,	@BigRetailCustType	CustTypeType output
,	@ZlaArPayType		varchar(10) output
,	@Infobar			InfobarType output
) 
AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_GetGenericCustTypeSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_GetGenericCustTypeSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      EXEC @EXTGEN_SpName
		@GenericCustType output
		,@BigRetailCustType output
		,@ZlaArPayType output
		,@Infobar output
      -- ETP routine must take over all desired functionality of this standard routine:
      RETURN 0
   END
   -- End of Generic External Touch Point code.
 
DECLARE
  @Severity INT

SET  @Severity = 0

SELECT 
	@GenericCustType	= zpv_parms.generic_cust_type 
,	@BigRetailCustType	= zpv_parms.big_retail_cust_type
,	@ZlaArPayType		= zpv_parms.lasttran_id
FROM zpv_parms
WHERE
	zpv_parms.parms_key = 0	


RETURN @Severity



GO
