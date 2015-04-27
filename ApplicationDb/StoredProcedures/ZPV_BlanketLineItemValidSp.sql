/****** Object:  StoredProcedure [dbo].[ZPV_BlanketLineItemValidSp]    Script Date: 10/29/2014 12:13:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_BlanketLineItemValidSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_BlanketLineItemValidSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_BlanketLineItemValidSp]    Script Date: 10/29/2014 12:13:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- Converted from cs/v-co-bln.w procedure: LEAVE-co-bln_item
-- This routine validates a blanket line item.  The item unit of measure,
-- and description are returned.  A default customer item  is also
-- returned.
/* $Header: /ApplicationDB/Stored Procedures/BlanketLineItemValidSp.sp 18    9/12/11 10:33p Jpan2 $ */
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

CREATE PROCEDURE [dbo].[ZPV_BlanketLineItemValidSp] (
   @CoNum          CoNumType,
   @Item           ItemType,
   @CustNum        CustNumType,
   @ShipSite       SiteType         OUTPUT,
   @CurrCode       CurrCodeType,
   @ItemUM         UMType           OUTPUT,
   @ItemDesc       DescriptionType  OUTPUT,
   @CustItem       CustItemType     OUTPUT,
   @FeatStr        FeatStrType      OUTPUT,
   @ItemPlanFlag   Flag             OUTPUT,
   @ItemFeatTempl  FeatTemplateType OUTPUT,
   @ItemItem       ItemType         OUTPUT,
   @Kit            ListYesNoType   OUTPUT,
   @PrintKitComponents  ListYesNoType   OUTPUT,
   @ItemSerialTracked   ListYesNoType  OUTPUT,
   @TaxCode1		TaxCodeType		OUTPUT,
   @TaxCode2		TaxCodeType		OUTPUT,	
   @Infobar        Infobar          OUTPUT
)
AS

 
DECLARE
  @Severity INT
, @NonInventoryItem ListYesNoType

IF @ShipSite IS NULL
BEGIN
	SELECT @ShipSite = [Site] FROM [Site]
END


SELECT
   @ItemItem     = NULL,
   @ItemUM       = NULL,
   @ItemDesc     = NULL,
   @FeatStr      = NULL,
   @ItemPlanFlag = NULL,
   @Severity     = 0
 , @NonInventoryItem  = 0

--
select @ItemItem = item.item
   from item_all item WITH (READUNCOMMITTED)
   where item.item = @Item
     AND item.site_ref = @ShipSite
if @ItemItem is null
BEGIN
   set @ItemItem = @Item
   set @NonInventoryItem = 1 
END

SELECT
	@TaxCode1 = item.tax_code1,
	@TaxCode2 = item.tax_code2
FROM item
WHERE
	item.item = @Item 
	
set @ItemFeatTempl = dbo.ItemFeatTempl(@Item)

IF @Severity = 0 AND @NonInventoryItem <> 1
BEGIN
   EXEC @Severity = CoBlnChangedItemSp
      @CoNum        = @CoNum,
      @Item         = @Item,
      @CustNum      = @CustNum,
      @CustCurrCode = @CurrCode,
      @ShipSite     = @ShipSite      OUTPUT,
      @CustItem     = @CustItem      OUTPUT,
      @FeatStr      = @FeatStr       OUTPUT,
      @ItemUM       = @ItemUM        OUTPUT,
      @ItemDesc     = @ItemDesc      OUTPUT,
      @ItemPlanFlag = @ItemPlanFlag  OUTPUT,
      @Kit          = @Kit           OUTPUT,
      @PrintKitComponents = @PrintKitComponents   OUTPUT,
      @ItemSerialTracked = @ItemSerialTracked   OUTPUT,
      @Infobar      = @Infobar       OUTPUT

   EXEC @Severity = ObsSlowSp
      @Item              = @Item,
      @WarnIfSlowMoving  = 0,
      @ErrorIfSlowMoving = 0,
      @WarnIfObsolete    = 0,
      @ErrorIfObsolete   = 1,
      @Infobar           = @Infobar  OUTPUT,
      @Site              = @ShipSite

END
ELSE
BEGIN
	SET		@ItemItem = null
	SET		@Infobar  = 'El producto cargado no existe'
	SET		@Severity = 16
END

RETURN @Severity



GO

