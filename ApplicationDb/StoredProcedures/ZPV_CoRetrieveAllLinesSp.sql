/****** Object:  StoredProcedure [dbo].[ZPV_CoRetrieveAllLinesSp]    Script Date: 16/01/2015 03:14:24 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CoRetrieveAllLinesSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CoRetrieveAllLinesSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CoRetrieveAllLinesSp]    Script Date: 16/01/2015 03:14:24 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ZPV_CoRetrieveAllLinesSp] (
	@NewCoNum		CoNumType,
	@OldCoNum		CoNumType,
	@Infobar    Infobar        OUTPUT
)
AS

declare	@Severity		int

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

set @Infobar	= null
set @Severity	= 0

declare
	@CoBlnCoNum					CoNumType
,	@CoBlnCoLine				CoLineType
,	@CoBlnItem					ItemType
,	@CoBlnDescription			DescriptionType
,	@CoBlnCustItem				CustItemType
,	@CoBlnFeatStr				FeatStrType	
,	@CoBlnBlanketQty			QtyTotlType
,	@CoBlnEffDate				DateType
,	@CoBlnExpDate				DateType
,	@CoBlnContPrice				AmountType
,	@CoBlnStat					CoBlnStatusType
,	@CoBlnPromiseDate			DateType
,	@CoBlnPricecode				PriceCodeType
,	@CoBlnUM					UMType
,	@CoBlnBlanketQtyConv		QtyTotlType
,	@CoBlnContPriceConv			CostPrcType
,	@CoBlnShipSite				SiteType
,	@CoBlnPrintKitComponents	ListYesNoType	
,	@CoBlnNonInvAcct			AcctType
,	@CoBlnNonInvAcctUnit1		UnitCode1Type
,	@CoBlnNonInvAcctUnit2		UnitCode2Type
,	@CoBlnNonInvAcctUnit3		UnitCode3Type
,	@CoBlnNonInvAcctUnit4		UnitCode4Type
,	@CoBlnCostConv				CostPrcType
,	@CoBlnDaysShippedBeforeDueDateTolerance	ToleranceDaysType
,	@CoBlnDaysShippedAfterDueDateTolerance	ToleranceDaysType
,	@CoBlnShippedOverOrderedQtyTolerance	ToleranceDaysType
,	@CoBlnShippedUnderOrderedQtyTolerance	ToleranceDaysType
,	@CoBlnManufacturerId		ManufacturerIdType
,	@CoBlnManufacturerItem		ManufacturerItemType
,	@CoBlnZpvShip_Whse			WhseType
,	@CoBlnZpvRes_Whse			WhseType
,	@CoBlnZpvShiptype			varchar(4)
,	@CoBlnZpvLot				LotType
,	@CoBlnZpvTotal				AmountType
,	@CoBlnZpvTotalDisc			AmountType
,	@CoBlnZpvTaxCode1			TaxCodeType
,	@CoBlnZpvTaxCode2			TaxCodeType
,	@CoBlnZpvQtyShipped			QtyTotlType
,	@CoBlnZpvQtyReturned		QtyTotlType
,	@CoBlnZpvQtyInvoiced		QtyTotlType
,	@CoBlnZpvPrgBillTot			AmountType
,	@CoBlnZpvPrgBillApp			AmountType
,	@CoBlnZpvStat				varchar(5)
,	@CoBlnZpvPromotionCode		varchar(10)
,	@CoBlnZpvUnitPrice			AmountType
,	@CoBlnZpvPromotionDisc		decimal(11,3)
,	@CoBlnZpvCoDisc				decimal(11,3)
,	@CoBlnZpvSalesTax			AmountType
,	@CoBlnZpvSalesTax2			AmountType
,	@CoBlnZpvLoc				varchar(15)
,	@CoBlnZpvResTemp			ListYesNoType


-- Revisa que exista la CO pedida y que la misma tenga lineas
if	not exists(select 1 from co where co.co_num = @OldCoNum) or
	not exists(select 1 from co_bln where co_bln.co_num = @OldCoNum)
begin
	set @Infobar = 'El Pedido ingresado no existe o no tiene lineas cargadas'
	return @Severity
end

-- Elimina todas las Lineas de la Orden actual
if	not exists(select 1 from co_bln co where co.co_num = @NewCoNum and co.stat <> 'P')
begin
	delete from coitem where stat = 'P' and co_num = @NewCoNum
	delete from co_bln where stat = 'P' and co_num = @NewCoNum
	delete from zpv_cobln_retention where co_num = @NewCoNum
	delete from zla_coitem_tax_mst where co_num = @NewCoNum
end
else
begin
	set @Infobar = 'El Pedido actual tiene Lineas en estado Ordenado, no se pueden reemplazar'
	return @Severity
end

declare CurCoBln cursor for
select
	@NewCoNum
,	bln.co_line
,	bln.item
,	bln.[description]
,	bln.cust_item
,	bln.feat_str
,	bln.blanket_qty
,	bln.eff_date
,	bln.exp_date
,	bln.cont_price
,	'P'
,	bln.promise_date
,	bln.pricecode
,	bln.u_m
,	bln.blanket_qty_conv
,	bln.cont_price_conv
,	bln.ship_site
,	bln.print_kit_components
,	bln.non_inv_acct
,	bln.non_inv_acct_unit1
,	bln.non_inv_acct_unit2
,	bln.non_inv_acct_unit3
,	bln.non_inv_acct_unit4
,	bln.cost_conv
,	bln.days_shipped_before_due_date_tolerance
,	bln.days_shipped_after_due_date_tolerance
,	bln.shipped_over_ordered_qty_tolerance
,	bln.shipped_under_ordered_qty_tolerance
,	bln.manufacturer_id
,	bln.manufacturer_item
,	bln.zpv_ship_whse
,	bln.zpv_res_whse
,	bln.zpv_shiptype
,	bln.zpv_lot
,	bln.zpv_total
,	bln.zpv_total_disc
,	bln.zpv_tax_code1
,	bln.zpv_tax_code2
,	0
,	0
,	0
,	0
,	0
,	'E00'
,	bln.zpv_promotion_code
,	bln.zpv_unit_price
,	bln.zpv_promotion_disc
,	bln.zpv_co_disc
,	bln.zpv_sales_tax
,	bln.zpv_sales_tax2
,	bln.zpv_loc		
,	bln.zpv_res_temp	
from co_bln_mst bln
where
	bln.co_num = @OldCoNum	
open CurCoBln
fetch next from CurCoBln
into
	@CoBlnCoNum		
,	@CoBlnCoLine	
,	@CoBlnItem		
,	@CoBlnDescription
,	@CoBlnCustItem	
,	@CoBlnFeatStr	
,	@CoBlnBlanketQty
,	@CoBlnEffDate	
,	@CoBlnExpDate	
,	@CoBlnContPrice	
,	@CoBlnStat		
,	@CoBlnPromiseDate
,	@CoBlnPricecode	
,	@CoBlnUM		
,	@CoBlnBlanketQtyConv
,	@CoBlnContPriceConv	
,	@CoBlnShipSite		
,	@CoBlnPrintKitComponents
,	@CoBlnNonInvAcct		
,	@CoBlnNonInvAcctUnit1	
,	@CoBlnNonInvAcctUnit2	
,	@CoBlnNonInvAcctUnit3	
,	@CoBlnNonInvAcctUnit4	
,	@CoBlnCostConv			
,	@CoBlnDaysShippedBeforeDueDateTolerance
,	@CoBlnDaysShippedAfterDueDateTolerance	
,	@CoBlnShippedOverOrderedQtyTolerance	
,	@CoBlnShippedUnderOrderedQtyTolerance	
,	@CoBlnManufacturerId	
,	@CoBlnManufacturerItem	
,	@CoBlnZpvShip_Whse		
,	@CoBlnZpvRes_Whse		
,	@CoBlnZpvShiptype		
,	@CoBlnZpvLot			
,	@CoBlnZpvTotal			
,	@CoBlnZpvTotalDisc		
,	@CoBlnZpvTaxCode1		
,	@CoBlnZpvTaxCode2		
,	@CoBlnZpvQtyShipped		
,	@CoBlnZpvQtyReturned	
,	@CoBlnZpvQtyInvoiced	
,	@CoBlnZpvPrgBillTot		
,	@CoBlnZpvPrgBillApp		
,	@CoBlnZpvStat			
,	@CoBlnZpvPromotionCode	
,	@CoBlnZpvUnitPrice		
,	@CoBlnZpvPromotionDisc	
,	@CoBlnZpvCoDisc			
,	@CoBlnZpvSalesTax		
,	@CoBlnZpvSalesTax2		
,	@CoBlnZpvLoc			
,	@CoBlnZpvResTemp		
while @@FETCH_STATUS = 0
begin
	
	INSERT INTO co_bln
		([co_num]
		,[co_line]
		,[item]
		,[description]
		,[cust_item]
		,[feat_str]
		,[blanket_qty]
		,[eff_date]
		,[exp_date]
		,[cont_price]
		,[stat]
		,[promise_date]
		,[pricecode]
		,[u_m]
		,[blanket_qty_conv]
		,[cont_price_conv]
		,[ship_site]
		,[print_kit_components]
		,[non_inv_acct]
		,[non_inv_acct_unit1]
		,[non_inv_acct_unit2]
		,[non_inv_acct_unit3]
		,[non_inv_acct_unit4]
		,[cost_conv]
		,[days_shipped_before_due_date_tolerance]
		,[days_shipped_after_due_date_tolerance]
		,[shipped_over_ordered_qty_tolerance]
		,[shipped_under_ordered_qty_tolerance]
		,[manufacturer_id]
		,[manufacturer_item]
		,[zpv_ship_whse]
		,[zpv_res_whse]
		,[zpv_shiptype]
		,[zpv_lot]
		,[zpv_total]
		,[zpv_total_disc]
		,[zpv_tax_code1]
		,[zpv_tax_code2]
		,[zpv_qty_shipped]
		,[zpv_qty_returned]
		,[zpv_qty_invoiced]
		,[zpv_prg_bill_tot]
		,[zpv_prg_bill_app]
		,[zpv_stat]
		,[zpv_promotion_code]
		,[zpv_unit_price]
		,[zpv_promotion_disc]
		,[zpv_co_disc]			
		,[zpv_sales_tax]		
		,[zpv_sales_tax2]		
		,[zpv_loc]			
		,[zpv_res_temp])
	values(
		@CoBlnCoNum		
	,	@CoBlnCoLine	
	,	@CoBlnItem		
	,	@CoBlnDescription
	,	@CoBlnCustItem	
	,	@CoBlnFeatStr	
	,	@CoBlnBlanketQty
	,	@CoBlnEffDate	
	,	@CoBlnExpDate	
	,	@CoBlnContPrice	
	,	@CoBlnStat		
	,	@CoBlnPromiseDate
	,	@CoBlnPricecode	
	,	@CoBlnUM		
	,	@CoBlnBlanketQtyConv
	,	@CoBlnContPriceConv	
	,	@CoBlnShipSite		
	,	@CoBlnPrintKitComponents
	,	@CoBlnNonInvAcct		
	,	@CoBlnNonInvAcctUnit1	
	,	@CoBlnNonInvAcctUnit2	
	,	@CoBlnNonInvAcctUnit3	
	,	@CoBlnNonInvAcctUnit4	
	,	@CoBlnCostConv			
	,	@CoBlnDaysShippedBeforeDueDateTolerance
	,	@CoBlnDaysShippedAfterDueDateTolerance	
	,	@CoBlnShippedOverOrderedQtyTolerance	
	,	@CoBlnShippedUnderOrderedQtyTolerance	
	,	@CoBlnManufacturerId	
	,	@CoBlnManufacturerItem	
	,	@CoBlnZpvShip_Whse		
	,	@CoBlnZpvRes_Whse		
	,	@CoBlnZpvShiptype		
	,	@CoBlnZpvLot			
	,	@CoBlnZpvTotal			
	,	@CoBlnZpvTotalDisc		
	,	@CoBlnZpvTaxCode1		
	,	@CoBlnZpvTaxCode2		
	,	@CoBlnZpvQtyShipped		
	,	@CoBlnZpvQtyReturned	
	,	@CoBlnZpvQtyInvoiced	
	,	@CoBlnZpvPrgBillTot		
	,	@CoBlnZpvPrgBillApp		
	,	@CoBlnZpvStat			
	,	@CoBlnZpvPromotionCode	
	,	@CoBlnZpvUnitPrice		
	,	@CoBlnZpvPromotionDisc	
	,	@CoBlnZpvCoDisc			
	,	@CoBlnZpvSalesTax		
	,	@CoBlnZpvSalesTax2		
	,	@CoBlnZpvLoc			
	,	@CoBlnZpvResTemp)		
						
fetch next from CurCoBln
into
	@CoBlnCoNum		
,	@CoBlnCoLine	
,	@CoBlnItem		
,	@CoBlnDescription
,	@CoBlnCustItem	
,	@CoBlnFeatStr	
,	@CoBlnBlanketQty
,	@CoBlnEffDate	
,	@CoBlnExpDate	
,	@CoBlnContPrice	
,	@CoBlnStat		
,	@CoBlnPromiseDate
,	@CoBlnPricecode	
,	@CoBlnUM		
,	@CoBlnBlanketQtyConv
,	@CoBlnContPriceConv	
,	@CoBlnShipSite		
,	@CoBlnPrintKitComponents
,	@CoBlnNonInvAcct		
,	@CoBlnNonInvAcctUnit1	
,	@CoBlnNonInvAcctUnit2	
,	@CoBlnNonInvAcctUnit3	
,	@CoBlnNonInvAcctUnit4	
,	@CoBlnCostConv			
,	@CoBlnDaysShippedBeforeDueDateTolerance
,	@CoBlnDaysShippedAfterDueDateTolerance	
,	@CoBlnShippedOverOrderedQtyTolerance	
,	@CoBlnShippedUnderOrderedQtyTolerance	
,	@CoBlnManufacturerId	
,	@CoBlnManufacturerItem	
,	@CoBlnZpvShip_Whse		
,	@CoBlnZpvRes_Whse		
,	@CoBlnZpvShiptype		
,	@CoBlnZpvLot			
,	@CoBlnZpvTotal			
,	@CoBlnZpvTotalDisc		
,	@CoBlnZpvTaxCode1		
,	@CoBlnZpvTaxCode2		
,	@CoBlnZpvQtyShipped		
,	@CoBlnZpvQtyReturned	
,	@CoBlnZpvQtyInvoiced	
,	@CoBlnZpvPrgBillTot		
,	@CoBlnZpvPrgBillApp		
,	@CoBlnZpvStat			
,	@CoBlnZpvPromotionCode	
,	@CoBlnZpvUnitPrice		
,	@CoBlnZpvPromotionDisc	
,	@CoBlnZpvCoDisc			
,	@CoBlnZpvSalesTax		
,	@CoBlnZpvSalesTax2		
,	@CoBlnZpvLoc			
,	@CoBlnZpvResTemp		
end
close CurCoBln
deallocate CurCoBln

set @Infobar = 'Pedido Recuperado Correctamente'
return @severity



GO

