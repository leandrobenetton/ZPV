/****** Object:  StoredProcedure [dbo].[ZPV_UpdateCoBlnProcessSp]    Script Date: 16/01/2015 03:12:45 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_UpdateCoBlnProcessSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_UpdateCoBlnProcessSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_UpdateCoBlnProcessSp]    Script Date: 16/01/2015 03:12:45 p.m. ******/
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
CREATE PROCEDURE [dbo].[ZPV_UpdateCoBlnProcessSp] (
  @CoNum		CoNumType
, @Infobar InfobarType OUTPUT
)
AS

DISABLE TRIGGER co_mst.co_mstIup ON co_mst;

DECLARE
  @Severity     INT
, @InfobarText  InfobarType

SELECT
  @Severity = 0

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

BEGIN TRANSACTION;

BEGIN TRY
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
		@CoPriceF		AmountType,
		@CoSalesTax1	AmountType,
		@CoSalesTax2	AmountType,
		@CoDisc			AmountType,
		@CoFreight		AmountType,
		@CoOrderFreight		AmountType,
		@CoDiscFreight decimal(18,4),
		@CoFrtSalesTax1	AmountType,
		@CoFrtSalesTax2	AmountType,
		@CoMisc			AmountType,
		@CoMiscSalesTax1	AmountType,
		@CoMiscSalesTax2	AmountType,
		@ParmsSite		SiteType
	
	
   	select 
		@CoNum			= co.co_num,
		@CoCuit			= co.zpv_bill_cuit,
		@CoDate			= co.order_date,
		@CoCustNum		= co.cust_num,
		@CoTaxCode1		= co.tax_code1,
		@CoTaxCode2		= co.tax_code2,
		@CoFrtTaxCode1	= co.frt_tax_code1,
		@CoFrtTaxCode2	= co.frt_tax_code2,
		@CoMiscTaxCode1 = co.msc_tax_code1,
		@CoMiscTaxCode2 = co.msc_tax_code2,
		@CoFreight		= isnull(co.freight,0),
		@CoOrderFreight = isnull(co.zpv_order_freight,0),
		@CoDiscFreight  = isnull(co.zpv_disc_freight,0)
	from co
	where co.co_num = @CoNum
	
	--Precio Total Orden
	select @CoPrice = (select round(sum((isnull(co_bln.cont_price_conv,0) - isnull(co_bln.zpv_total_disc,0)) * isnull(co_bln.blanket_qty_conv,0)),2) from co_bln where co_bln.co_num = @CoNum)
	--Total Impuestos 1 (IVA)
	select @CoSalesTax1 = (select sum(isnull(co_bln.zpv_sales_tax,0)) from co_bln where co_bln.co_num = @CoNum)
	--Total Descuentos
	select @CoDisc = (select round(sum(isnull(co_bln.zpv_total_disc,0) * isnull(co_bln.blanket_qty_conv,0)),2) from co_bln where co_bln.co_num = @CoNum)
	
	

	set @CoPriceF = @CoPrice + @CoFreight
	
	

	--Total Impuestos 2 (Percepciones)
	EXEC	[dbo].[ZPV_CoTotalPercSp]
		@CoNum = @CoNum,
		@Amount = @CoPriceF,
		@SalesTax1 = @CoSalesTax1,
		@Cuit = @CoCuit,
		@OrderDate = @CoDate,
		@TaxAmount = @CoSalesTax2 OUTPUT
		
	

	set @CoFreight = round(@CoOrderFreight - round(@CoOrderFreight * (@CoDiscFreight / 100),5),5)


	--Total Impuestos 1 (IVA) Flete
	EXEC	[dbo].[ZPV_CoTotalTaxSp]
		@Type = N'O',
		@CustNum = @CoCustNum,
		@CustSeq = 0,
		@CoNum = @CoNum,
		@TaxCode1 = @CoFrtTaxCode1,
		@TaxCode2 = @CoFrtTaxCode2,
		@TaxRate = @CoFrtTaxRate OUTPUT
	
	If @CoFrtTaxRate = 0
		set @CoFrtSalesTax1 = 0
	else
		set @CoFrtSalesTax1 = isnull(round(@CoFreight * (@CoFrtTaxRate / 100),5),0)

    
	select @CoPrice
	
	

	update co_mst
		set price				= round(@CoPrice,5),
			zla_for_price		= round(@CoPrice,5),
			sales_tax			= round(@CoSalesTax1 + @CoFrtSalesTax1,5),
			zla_for_sales_tax	= round(@CoSalesTax1 + @CoFrtSalesTax1,5),
			sales_tax_2			= round(@CoSalesTax2,5),
			zla_for_sales_tax_2	= round(@CoSalesTax2,5),
			disc_amount			= round(@CoDisc,5),
			zla_for_disc_amount	= round(@CoDisc,5),
			zpv_order_freight	= round(@CoOrderFreight,5),
			freight				= round(@CoFreight,5),
			zpv_disc_freight	= round(@CoDiscFreight,5),
			zla_for_freight		= round(@CoOrderFreight,5)
	where
		co_num = @CoNum

	
			
END TRY
BEGIN CATCH
	SELECT 
         ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
	     ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
	COMMIT TRANSACTION;

ENABLE TRIGGER co_mst.co_mstIup ON co_mst;

GO

