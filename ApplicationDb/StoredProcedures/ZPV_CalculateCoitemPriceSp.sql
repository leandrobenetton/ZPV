/****** Object:  StoredProcedure [dbo].[CalculateCoitemPriceSp]    Script Date: 09/01/2015 03:29:58 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CalculateCoitemPriceSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CalculateCoitemPriceSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CalculateCoitemPriceSp]    Script Date: 09/01/2015 03:29:58 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ZPV_CalculateCoitemPriceSp.sp 37    3/21/13 11:56 sruffing $  */
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
*   (c) COPYRIGHT 2008 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
***************************************************************
*/


CREATE PROCEDURE [dbo].[ZPV_CalculateCoitemPriceSp] (
  @CoNum         CoNumType
, @CustNum       CustNumType
, @Item          ItemType
, @ItemUM        UMType output
, @CustItem      ItemType
, @ShipSite      SiteType
, @OrderDate     GenericDateType
, @InQtyConv     QtyUnitType -- BlanketQtyConv
, @CurrCode      CurrCodeType
, @ItemPriceCode PriceCodeType
, @PriceConv     AmountType  OUTPUT
, @Infobar       Infobar     OUTPUT
, @CoLine        CoLineType
, @DispMsg       ListYesNoType = 0 OUTPUT
, @ItemWhse      WhseType = null
, @LineDisc      LineDiscType = 0 OUTPUT
, @TaxInPriceDiff ListYesNoType = 0 OUTPUT
, @PromotionCode  PromotionCodeType = NULL
)
AS

  
DECLARE
  @Severity       INT
, @QtyConv        QtyUnitType
, @QtyList        QtyUnitType
, @PriceList      QtyUnitType
, @UomConvFactor  UMConvFactorType
, @BaseQty        QtyUnitNoNegType
, @Site           SiteType
, @Rsvd1          ListYesNoType
, @ExchRate       ExchRateType
, @Price          AmountType
, @IncludeTaxFlg  ListYesNoType
, @IncludeTaxInPrice ListYesNoType
, @Infobar2       InfobarType
, @ConfigString   FeatStrType
, @ShipTo         CustSeqType
, @ItemExists     ListYesNoType
, @CustItemUM UMType

SET @IncludeTaxFlg = 0
SET @IncludeTaxInPrice = 0
SET @ItemExists = 0
SET @Severity = 0

SET @DispMsg = ISNULL(@DispMsg,0)

SELECT @IncludeTaxFlg = include_tax_in_price
, @ExchRate = exch_rate
, @ShipTo = isnull(cust_seq, 0)
FROM co WITH (READUNCOMMITTED)
WHERE co_num = @CoNum

WHILE @Severity = 0
BEGIN
   SELECT
     @QtyConv = ISNULL (@InQtyConv, 0)
   , @Severity = 0
   , @Price = ISNULL(@PriceConv,0)
   , @Infobar = NULL

   IF @Item IS NULL
   BEGIN
      SET @PriceConv = 0
      RETURN 0
   END

   -- Get appropriate Site to use.
   SELECT
     @Site = site
   , @Rsvd1 = rsvd1
   FROM  parms with (readuncommitted)
   WHERE parm_key = 0

   IF @Rsvd1 = 0 -- false
      SET @Site = @ShipSite
   
   -- Check if item exists in item table
   IF EXISTS(SELECT 1 FROM item_all (READUNCOMMITTED) WHERE item = @Item and site_ref = @Site)
      SET @ItemExists = 1

   -- From get-base-quantity proc.
   IF @ItemExists = 1
      EXEC @Severity = dbo.GetumcfSp
        @OtherUM    = @ItemUM
      , @Item       = @Item
      , @VendNum    = @CustNum
      , @Area       = 'C'
      , @ConvFactor = @UomConvFactor OUTPUT
      , @Infobar    = @Infobar       OUTPUT
      , @Site       = @Site

   IF @Severity <> 0
      BREAK

   SET @BaseQty = dbo.UomConvQty(@QtyConv,
                                 @UomConvFactor,
                                 'To Base')
   -- End get-base-quantity proc.
   
   -- Find LineDiscount Added for ESales WebService Call
   DECLARE 
   @CustomerCustType AS CustTypeType,
   @CustomerRowPointer AS RowPointerType,
   @ItemProductCode AS ProductCodeType,
   @ItemRowPointer AS RowPointerType
   
   SELECT
     @ItemProDuctCode = item.product_code,
     @ItemRowPointer = item.RowPointer
   FROM item WITH (READUNCOMMITTED)
   WHERE item = @Item
   
   SELECT
     @CustomerCustType = customer.cust_type,
     @CustomerRowPointer = customer.RowPointer
   FROM customer
   WHERE customer.cust_num = @CustNum
    AND customer.cust_seq = 0

   IF @ItemRowPointer IS NOT NULL AND
      @CustomerRowPointer IS NOT NULL AND @PromotionCode IS NULL
   SELECT
     @LineDisc = discount.disc_pct
   FROM discount
   WHERE discount.cust_type = @CustomerCustType
     AND discount.product_code = @ItemProductCode
   -- End LineDiscount

   IF @PromotionCode IS NOT NULL
      SET @LineDisc = 0 --If PromotionCode is not null, then set Disc to zero.
      
   -- Converted from call to calculate-price
   -- Note, We don't capture the @Severity return
   -- in this context because we want to continue
   -- regardless.

   EXEC @Severity = dbo.DefineVariableSp
        @VariableName  = 'IncludeTaxInPrice'
      , @VariableValue = 0
      , @Infobar       = @Infobar2

   select top 1 @ConfigString = feat_str
   from coitem
   where co_num = @CoNum
   and co_line = @CoLine

   IF @ItemExists = 1
      EXEC @Severity = dbo.PriceCalSp
        @PShowMatrix       = 0
      , @PItem             = @Item
      , @PCustNum          = @CustNum
      , @PCustItem         = @CustItem
      , @PEffDate          = @OrderDate
      , @PExpDate          = @OrderDate
      , @PQtyOrdered       = @BaseQty
      , @POrderPriceCode   = @ItemPriceCode
      , @PCurrCode         = @CurrCode
      , @PConfigString     = @ConfigString
      , @PRate             = @ExchRate
      , @PUnitPrice        = @Price     OUTPUT
      , @PQtyList##1       = @QtyList   OUTPUT
      , @PPriceList##1     = @PriceList OUTPUT
      , @Infobar           = @Infobar   OUTPUT
      , @Site              = @Site
      , @PCoLine           = @CoLine
      , @ItemUM            = @ItemUM
      , @ItemWhse          = @ItemWhse
      , @ShipTo            = @ShipTo
      , @LineDisc          = @LineDisc OUTPUT
      , @CustItemUM = @CustItemUM output
      , @PromotionCode = @PromotionCode
      , @CoNum = @CoNum 


   IF @Price is null or @Price = 0
   Begin
		set @Severity = 16
		RETURN @Severity
   end   
  
   IF @DispMsg = 1
       SET @Infobar = NULL

   IF @DispMsg = 0 AND @Severity <> 0
      RETURN @Severity 
   
   IF @Infobar IS NOT NULL
      SET @DispMsg = 1

   EXEC @Severity = dbo.GetVariableSp
         @VariableName   = 'IncludeTaxInPrice'
       , @DefaultValue   = '0'
       , @DeleteVariable = 1
       , @VariableValue  = @IncludeTaxInPrice OUTPUT
       , @Infobar        = @Infobar    OUTPUT

   IF @CoNum IS NULL       
      SELECT @IncludeTaxFlg = include_tax_in_price
      FROM customer WITH (READUNCOMMITTED)
      WHERE cust_num = @CustNum AND cust_seq = 0

   IF @IncludeTaxFlg = 1 and @IncludeTaxInPrice = 0 and @InQtyConv <> 0 and @DispMsg = 0
   BEGIN
       EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT,
           '@!ItemwithTaxInPrice'
       SET @DispMsg = 1
       SET @TaxInPriceDiff = 1
   END

   IF @IncludeTaxFlg = 0 and @IncludeTaxInPrice = 1 and @InQtyConv <> 0 and @DispMsg = 0
   BEGIN
       EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT,
           '@!ItemFlaggedAsIncPrice'
       SET @DispMsg = 1
       SET @TaxInPriceDiff = 1
   END

   SET @PriceConv = @Price
   IF @ItemExists = 1
   begin
      EXEC @Severity = dbo.CoitmConvertUnitPriceSp
        @ItemUM    = @ItemUM
      , @Item      = @Item
      , @CustNum   = @CustNum
      , @CurrCode  = @CurrCode
      , @ConvertTo = 'ORDER'
      , @Site      = @Site
      , @PriceConv = @PriceConv OUTPUT
      , @Price     = @Price     OUTPUT
      , @Infobar   = @Infobar   OUTPUT
   end

   SET @Severity = 0

   SELECT @PriceConv = round(@PriceConv, currency.places_cp)
   FROM currency with (readuncommitted)
   WHERE curr_code =  @CurrCode

   BREAK
END

RETURN @Severity
GO

