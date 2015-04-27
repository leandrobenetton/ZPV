/****** Object:  StoredProcedure [dbo].[ZPV_CLM_BankImportTransactionsSp]    Script Date: 19/02/2015 15:50:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_RetailCOSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_RetailCOSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_RetailCOSp]    Script Date: 19/02/2015 15:50:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_CLM_RetailCOSp](
	@pPathFile		varchar(500)	= null
,	@pCustNum		CustNumType		= null
,	@pUserName		UsernameType	= null
,	@pSlsman		SlsmanType		= null
,	@pPOS			varchar(20)		= null
,	@Infobar		InfobarType		= null OUTPUT)
 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

EXEC sp_configure 'Show Advanced Options', 1
RECONFIGURE

EXEC sp_configure 'Ad Hoc Distributed Queries', 1
RECONFIGURE

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@Severity		int
,	@Path			varchar(255)
,	@PathCompleto	varchar(255)

set @Severity = 0

declare @tt_trans table(
		tt_f12				numeric(12) 
	,	tt_ponum			varchar(100)
	,	tt_emit_date		DateType
	,	tt_receptor			varchar(100)
	,	tt_addr_recep		varchar(100)
	,	tt_comuna_recep		varchar(100)
	,	tt_local			varchar(100)
	,	tt_ship_to			varchar(100)
	,	tt_obs				varchar(4000)
	,	tt_sku				numeric(8)
	,	tt_description		varchar(100)
	,	tt_qty				QtyUnitType
	,	tt_price1			AmountType
	,	tt_price2			AmountType
	,	tt_dni				varchar(100)
	,	tt_ship_date		DateType)
	
	declare
		@SQL				LongListType
	,	@File				LongListType
	,	@File1				LongListType
	,	@File2				LongListType
	,	@File3				LongListType
	,	@TB2BF12			numeric(12)	 
	,	@TB2BPonum			varchar(100)
	,	@TB2BEmit_date		DateType
	,	@TB2BReceptor		varchar(100) 
	,	@TB2BAddr_recep		varchar(200)
	,	@TB2BComuna_recep	varchar(100)	
	,	@TB2BLocal			varchar(100)
	,	@TB2BShip_to		varchar(100)	
	,	@TB2BObs			varchar(4000)	
	,	@TB2BSku			varchar(10)
	,	@TB2BDescription	varchar(100)
	,	@TB2BQty			QtyUnitType
	,	@TB2BPrice1			AmountType
	,	@TB2BPrice2			AmountType
	,	@TB2BDni			varchar(100)
	,	@TB2BShip_date		DateType
	
	declare
		@CoType				varchar(1)
	,	@CoCoNum			CoNumType
	,	@CoCustNum			CustNumType
	,	@CoCustPo			CustPoType
	,	@CoCustSeq			int
	,	@CoOrderDate		DateType
	,	@CoTakenBy			UsernameType
	,	@CoTermsCode		TermsCodeType
	,	@CoShipCode			ShipCodeType
	,	@CoPrice			AmountType
	,	@CoStat				varchar(1)
	,	@CoSlsman			SlsmanType
	,	@CoEffDate			DateType
	,	@CoWhse				WhseType
	,	@CoDiscountType		varchar(1)
	,	@CoDiscAmount		AmountType
	,	@CoDisc				OrderDiscType
	,	@CoPriceCode		PriceCodeType
	,	@CoShipPartial		ListYesNoType
	,	@CoShipEarly		ListYesNoType
	,	@CoEndUserType		EndUserTypeType
	,	@CoExchRate			ExchRateType
	,	@CoOrigSite			SiteType
	,	@CoProjectedDate	DateType
	,	@CoConvertType		varchar(1)
	,	@CoConsolidate		ListYesNoType
	,	@CoInvFreq			varchar(1)
	,	@CoSummarize		ListYesNoType
	,	@CoConsignment		ListYesNoType
	,	@CoShipmentApprovalRequired	ListYesNoType
	,	@CoPortaOrder		ListYesNoType
	,	@CoShipHold			ListYesNoType
	,	@CoPaymentMethod	varchar(1)
	,	@CoZlaForCurrCode	CurrCodeType
	,	@CoZlaForExchRate	ExchRateType
	,	@CoZlaForPrice		AmountType
	,	@CoZlaArTypeId		ZlaArTypeIdType
	,	@CoZlaDocId			ZlaDocumentIdType
	--------------------ZPV-------------------------
	,	@CoZpvBillFiscalName	varchar(100)
	,	@CoZpvBillAddr1			varchar(100)
	,	@CoZpvBillAddr2			varchar(100)
	,	@CoZpvBillAddr3			varchar(100)
	,	@CoZpvBillAddr4			varchar(100)
	,	@CoZpvBillCity			CityType
	,	@CoZpvBillState			StateType
	,	@CoZpvBillZip			PostalCodeType
	,	@CoZpvBillCounty		CountyType
	,	@CoZpvBillCountry		CountryType
	,	@CoZpvBillCuit			varchar(30)
	,	@CoZpvStat				varchar(3)
	,	@CoZpvStatInternal		varchar(3)
	,	@CoZpvInvNum			InvNumType
	,	@CoZpvBillEmail			varchar(100)
	,	@CoZpvPhone				PhoneType
	,	@CoZpvSlsman			SlsmanType
	,	@CoZpvPos				varchar(15)
	,	@CoZpvBillTypeDoc		varchar(10)
	,	@CoZpvUser				UsernameType
	,	@CoZpvConvenio			varchar(15)
	,	@CoZpvFollow			varchar(15)
	,	@CoSalesTax				AmountType
	,	@CoSalesTax2			AmountType
	,	@CoF12					numeric(12)
		
	declare
		@CoBlnCoNum				CoNumType
	,	@CoBlnCoLine			CoLineType
	,	@CoBlnItem				ItemType
	,	@CoBlnDescription		DescriptionType
	,	@CoBlnCustItem			CustItemType
	,	@CoBlnBlanketQty		QtyUnitType
	,	@CoBlnContPrice			AmountType
	,	@CoBlnStat				varchar(1)
	,	@CoBlnPromiseDate		DateType
	,	@CoBlnUM				UMType
	,	@CoBlnBlanketQtyConv	QtyUnitType
	,	@CoBlnContPriceConv		AmountType
	,	@CoBlnShipSite			SiteType
	,	@CoBlnCostConv			AmountType
	,	@CoBlnZpvTotal			AmountType
	,	@CoBlnZpvTotalDisc		AmountType
	,	@CoBlnZpvTaxCode1		TaxCodeType
	,	@CoBlnZpvTaxCode2		TaxCodeType
	,	@CoBlnZpvQtyShipped		QtyUnitType
	,	@CoBlnZpvQtyReturned	QtyUnitType
	,	@CoBlnZpvQtyInvoiced	QtyUnitType
	,	@CoBlnZpvUnitPrice		AmountType
	,	@CoBlnZpvCoDisc			AmountType
	,	@CoBlnZpvSalesTax		AmountType
	,	@CoBlnZpvSalesTax2		AmountType

	declare
		@TaxCode1Rate			TaxRateType
	,	@TaxCode2Rate			TaxRateType
	,	@ShipCustSeq			CustSeqType
	,	@NextCoNum				CoNumType

select 
	@Path = par.data_import_path
from zpv_parms par
where par.parms_key = 0

if @pPathFile is not null and @Path is not null
begin

	BEGIN TRANSACTION;

	BEGIN TRY
		set @PathCompleto = @Path + @pPathFile
		
		set @File1 = '''Microsoft.ACE.OLEDB.12.0'''
		set @File2 = '''Excel 12.0 Xml;HDR=YES;Database=' + @PathCompleto + ''''
		set @File3 = '''SELECT * FROM [b2b$]'''

		set @File = @File1 + ',' + @File2 + ',' + @File3
 
		-- Process
		BEGIN
 			set @SQL = 'select * from OPENROWSET(' + @File + ')'

			insert into @tt_trans(
							tt_f12			
						,	tt_ponum		
						,	tt_emit_date	
						,	tt_receptor		
						,	tt_addr_recep	
						,	tt_comuna_recep	
						,	tt_local		
						,	tt_ship_to		
						,	tt_obs		
						,	tt_sku	
						,	tt_description
						,	tt_qty
						,	tt_price1
						,	tt_price2
						,	tt_dni	
						,	tt_ship_date)
				
  
			EXECUTE sp_executesql @SQL
	
		END

		declare CurB2B cursor for
		select
			tt_f12			
		,	tt_ponum		
		,	tt_emit_date	
		,	tt_receptor		
		,	tt_addr_recep	
		,	tt_comuna_recep	
		,	tt_local		
		,	tt_ship_to		
		,	tt_obs		
		,	tt_sku	
		,	tt_description
		,	tt_qty
		,	tt_price1
		,	tt_price2
		,	tt_dni	
		,	tt_ship_date
		from @tt_trans 
		open CurB2B
		fetch next from CurB2B
		into
			@TB2BF12		
		,	@TB2BPonum		
		,	@TB2BEmit_date	
		,	@TB2BReceptor	
		,	@TB2BAddr_recep	
		,	@TB2BComuna_recep
		,	@TB2BLocal		
		,	@TB2BShip_to	
		,	@TB2BObs		
		,	@TB2BSku		
		,	@TB2BDescription
		,	@TB2BQty		
		,	@TB2BPrice1		
		,	@TB2BPrice2		
		,	@TB2BDni		
		,	@TB2BShip_date

		while @@FETCH_STATUS = 0
		begin
			select
				@CoTermsCode		= cus.terms_code
			,	@CoPriceCode		= cus.pricecode
			,	@CoEndUserType		= cus.end_user_type
			,	@CoZlaForCurrCode	= cad.curr_code
			from customer cus
			inner join custaddr cad on cad.cust_num = cus.cust_num and cad.cust_seq = 0
			where	cus.cust_num = @pCustNum and cus.cust_seq = 0

			select top 1
				@CoShipCode		= ship.ship_code
			from shipcode ship
			where	ship.transport = 'F'

			select 
				@CoWhse			= usl.whse
			from UserNames usr
			inner join user_local usl on usl.UserId = usr.UserId
			where	usr.Username = @pUserName
			if @CoWhse is null
			select
				@CoWhse			= invp.def_whse
			from invparms invp
			where invp.parm_key = 0
		
			select 
				@CoZlaDocId		= coc.doc_id
			from zpv_co_codes coc
			where	coc.end_user_type = @CoEndUserType

			select 
				@CoZlaArTypeId	= etype.ar_type_id
			from zla_ar_endtype etype
			where	etype.end_user_type = @CoEndUserType 
				and	etype.type = 'I'
		
			EXEC	@Severity = [dbo].[ZPV_NextKeyCOSp]
				@POS = @pPOS,
				@NextCoNum = @NextCoNum OUTPUT,
				@Infobar = @Infobar OUTPUT

			select
				@CoType				= 'B'
			,	@CoCoNum			= @NextCoNum 
			,	@CoCustPo			= @TB2BPonum
			,	@CoCustNum			= @pCustNum
			,	@CoCustSeq			= 0
			,	@CoOrderDate		= @TB2BEmit_date
			,	@CoTakenBy			= @pUserName
			--,	@CoTermsCode		TermsCodeType
			--,	@CoShipCode			ShipCodeType
			,	@CoPrice			= 0
			,	@CoStat				= 'P'
			,	@CoSlsman			= null --@pSlsman
			,	@CoEffDate			= @TB2BEmit_date
			--,	@CoWhse				= WhseType
			,	@CoDiscountType		= 'P'
			,	@CoDiscAmount		= 0
			,	@CoDisc				= 0
			--,	@CoPriceCode		PriceCodeType
			,	@CoShipPartial		= 1
			,	@CoShipEarly		= 1
			--,	@CoEndUserType		EndUserTypeType
			,	@CoExchRate			= 1
			,	@CoOrigSite			= @Site
			,	@CoProjectedDate	= @TB2BEmit_date
			,	@CoConvertType		= 'O'
			,	@CoConsolidate		= 0
			,	@CoInvFreq			= 'W'
			,	@CoSummarize		= 0
			,	@CoConsignment		= 0
			,	@CoShipmentApprovalRequired	= 0
			,	@CoPortaOrder		= 0
			,	@CoShipHold			= 0
			,	@CoPaymentMethod	= 'A'
			--,	@CoZlaForCurrCode	CurrCodeType
			,	@CoZlaForExchRate	= 1
			,	@CoZlaForPrice		= 0
			--,	@CoZlaArTypeId		ZlaArTypeIdType
			--,	@CoZlaDocId			ZlaDocumentIdType
			--------------------ZPV-------------------------
			,	@CoZpvBillFiscalName	= @TB2BReceptor
			,	@CoZpvBillAddr1			= SUBSTRING(@TB2BAddr_recep,1,50)
			,	@CoZpvBillAddr2			= SUBSTRING(@TB2BAddr_recep,51,100)
			,	@CoZpvBillAddr3			= SUBSTRING(@TB2BAddr_recep,101,150)
			,	@CoZpvBillAddr4			= SUBSTRING(@TB2BAddr_recep,151,200)
			,	@CoZpvBillCity			= @TB2BComuna_recep
			,	@CoZpvBillState			= null
			,	@CoZpvBillZip			= null
			,	@CoZpvBillCounty		= null
			,	@CoZpvBillCountry		= 'COLOMBIA'
			,	@CoZpvBillCuit			= @TB2BDni
			,	@CoZpvStat				= 'E00'
			,	@CoZpvStatInternal		= 'E00'
			,	@CoZpvInvNum			= null
			,	@CoZpvBillEmail			= null --ver de tenerlo
			,	@CoZpvPhone				= null --ver de tenerlo
			,	@CoZpvSlsman			= null
			,	@CoZpvPos				= @pPOS
			,	@CoZpvBillTypeDoc		= null
			,	@CoZpvUser				= @pUserName
			,	@CoZpvConvenio			= null
			,	@CoZpvFollow			= null
			,	@CoF12					= @TB2BF12

			if not exists(select 1 from co where co.co_num = @CoCoNum and co.zpv_f12 = @TB2BF12)
			begin
				-- Genera CO
				insert into co(
					Type		  
				,	co_num  
				,	cust_num
				,	cust_seq		  
				,	order_date	  
				,	taken_by		  
				,	terms_code	  
				,	ship_code	  
				,	Price		  
				,	Stat		  
				,	Slsman		  
				,	eff_date		  
				,	Whse		  
				,	discount_type  
				,	disc_amount	  
				,	Disc		  
				,	PriceCode	  
				,	ship_partial	  
				,	ship_early	  
				,	end_user_type	  
				,	exch_rate	  
				,	orig_site	  
				,	projected_date 
				,	convert_type	  
				,	Consolidate	  
				,	inv_freq		  
				,	Summarize	  
				,	Consignment	  
				,	shipment_approval_required 
				,	portal_order	   
				,	ship_hold	   
				,	payment_method  
				,	zla_for_curr_code 
				,	zla_for_exch_rate 
				,	zla_for_price	   
				,	zla_ar_type_id	   
				,	zla_doc_id	   
					-------------ZPV-------------------------
				,	zpv_bill_fiscal_name	
				,	zpv_bill_addr1		
				,	zpv_bill_addr2		
				,	zpv_bill_addr3		
				,	zpv_bill_addr4		
				,	zpv_bill_city			
				,	zpv_bill_state		
				,	zpv_bill_zip			
				,	zpv_bill_county		
				,	zpv_bill_country		
				,	zpv_bill_cuit			
				,	zpv_stat				
				,	zpv_stat_internal		
				,	zpv_inv_num			
				,	zpv_bill_email		
				,	zpv_phone			
				,	zpv_slsman			
				,	zpv_pos				
				,	zpv_bill_type_doc		
				,	zpv_user				
				,	zpv_convenio			
				,	zpv_follow
				,	zpv_f12
				,	cust_po)
				values(
					@CoType                   
				,   @CoCoNum                  
				,   @CoCustNum                
				,   @CoCustSeq                
				,   @CoOrderDate              
				,   @CoTakenBy                
				,   @CoTermsCode              
				,   @CoShipCode               
				,   @CoPrice                  
				,   @CoStat                   
				,   @CoSlsman                 
				,   @CoEffDate                
				,   @CoWhse                   
				,   @CoDiscountType           
				,   @CoDiscAmount             
				,   @CoDisc                   
				,   @CoPriceCode              
				,   @CoShipPartial            
				,   @CoShipEarly              
				,   @CoEndUserType            
				,   @CoExchRate               
				,   @CoOrigSite               
				,   @CoProjectedDate          
				,   @CoConvertType            
				,   @CoConsolidate            
				,   @CoInvFreq                
				,   @CoSummarize              
				,   @CoConsignment            
				,   @CoShipmentApprovalRequired
				,   @CoPortaOrder             
				,   @CoShipHold               
				,   @CoPaymentMethod          
				,   @CoZlaForCurrCode         
				,   @CoZlaForExchRate         
				,   @CoZlaForPrice            
				,   @CoZlaArTypeId            
				,   @CoZlaDocId               
				--------------------ZPV-------
				,   @CoZpvBillFiscalName      
				,   @CoZpvBillAddr1           
				,   @CoZpvBillAddr2           
				,   @CoZpvBillAddr3           
				,   @CoZpvBillAddr4           
				,   @CoZpvBillCity            
				,   @CoZpvBillState           
				,   @CoZpvBillZip             
				,   @CoZpvBillCounty          
				,   @CoZpvBillCountry         
				,   @CoZpvBillCuit            
				,   @CoZpvStat                
				,   @CoZpvStatInternal        
				,   @CoZpvInvNum              
				,   @CoZpvBillEmail           
				,   @CoZpvPhone               
				,   @CoZpvSlsman              
				,   @CoZpvPos                 
				,   @CoZpvBillTypeDoc         
				,   @CoZpvUser                
				,   @CoZpvConvenio            
				,   @CoZpvFollow
				,	@CoF12
				,	@CoCustPo)   

				select 
					@CoBlnItem			= itc.item
				,	@CoBlnDescription	= item.description
				,	@CoBlnZpvTaxCode1	= item.tax_code1
				,	@CoBlnZpvTaxCode2	= item.tax_code2
				,	@CoBlnUM			= itc.u_m
				from itemcust itc
				inner join item on item.item = itc.item
				where	itc.cust_item		= @TB2BSku
					and itc.cust_item_seq	= 1

				select
					@TaxCode1Rate	= taxcode.tax_rate
				from taxcode
				where	taxcode.tax_code = @CoBlnZpvTaxCode1

				select
					@TaxCode2Rate	= taxcode.tax_rate
				from taxcode
				where	taxcode.tax_code = @CoBlnZpvTaxCode2

				if @TaxCode1Rate is null set @TaxCode1Rate = 0
				if @TaxCode2Rate is null set @TaxCode2Rate = 0

				--EXEC @Severity = ZPV_CalculateCoitemPriceSp
				--	@CoNum         = @CoCoNum
				--	, @CustNum     = @CoCustNum
				--	, @Item        = @CoBlnItem
				--	, @ItemUM      = @CoBlnUM output
				--	, @CustItem    = null
				--	, @ShipSite    = @Site
				--	, @OrderDate   = @CoOrderDate
				--	, @InQtyConv   = @TB2BQty
				--	, @CurrCode    = @CoZlaForCurrCode
				--	, @ItemPriceCode = null
				--	, @PriceConv     = @CoBlnContPrice output
				--	, @Infobar       = @Infobar output
				--	, @CoLine        = 1
				--	, @DispMsg       = 0 
				--	, @ItemWhse      = @CoWhse
				--	, @LineDisc      = 0 
				--	, @TaxInPriceDiff = 0 
				--	, @PromotionCode  = NULL

				set @CoBlnContPrice = @TB2BPrice2

				if @CoBlnContPrice is null 
				begin
					select 
						@CoBlnContPrice = price.unit_price1
					from itemprice price
					where	price.item = @CoBlnItem
						and	price.effect_date <= @CoOrderDate
				end

				if @CoBlnContPrice is null set @CoBlnContPrice = 0
		
				select
					@CoBlnZpvSalesTax	= round(@CoBlnContPrice * (@TaxCode1Rate / 100),2)
				,	@CoBlnZpvSalesTax2	= round(@CoBlnContPrice * (@TaxCode2Rate / 100),2)		

				select
					@CoBlnCoNum				= @CoCoNum	
				,	@CoBlnCoLine			= 1
				--,	@CoBlnItem				
				--,	@CoBlnDescription	
				,	@CoBlnCustItem			= null	
				,	@CoBlnBlanketQty		= @TB2BQty
				--,	@CoBlnContPrice			= 
				,	@CoBlnStat				= 'P'
				,	@CoBlnPromiseDate		= @TB2BShip_date
				--,	@CoBlnUM				
				,	@CoBlnBlanketQtyConv	= @TB2BQty
				,	@CoBlnContPriceConv		= @CoBlnContPrice
				,	@CoBlnShipSite			= @Site
				,	@CoBlnCostConv			= 0
				,	@CoBlnZpvTotal			= (@CoBlnContPrice + @CoBlnZpvSalesTax + @CoBlnZpvSalesTax2) * @CoBlnBlanketQty
				,	@CoBlnZpvTotalDisc		= 0
				--,	@CoBlnZpvTaxCode1		= 0
				--,	@CoBlnZpvTaxCode2		= 0
				,	@CoBlnZpvQtyShipped		= 0
				,	@CoBlnZpvQtyReturned	= 0
				,	@CoBlnZpvQtyInvoiced	= 0
				,	@CoBlnZpvUnitPrice		= (@CoBlnContPrice + @CoBlnZpvSalesTax + @CoBlnZpvSalesTax2)
				,	@CoBlnZpvCoDisc			= 0
				--,	@CoBlnZpvSalesTax		= 
				--,	@CoBlnZpvSalesTax2		= 
		
				insert into co_bln(
					co_num
				,	co_line
				,	item
				,	description
				,	cust_item
				,	blanket_qty
				,	cont_price
				,	stat
				,	promise_date
				,	u_m
				,	blanket_qty_conv
				,	cont_price_conv
				,	ship_site
				,	cost_conv
				,	zpv_total
				,	zpv_total_disc
				,	zpv_tax_code1
				,	zpv_tax_code2
				,	zpv_qty_shipped
				,	zpv_qty_returned
				,	zpv_qty_invoiced
				,	zpv_unit_price
				,	zpv_co_disc
				,	zpv_sales_tax
				,	zpv_sales_tax2
				,	zpv_res_whse
				,	zpv_ship_whse)
				values(
					@CoBlnCoNum				
				,	@CoBlnCoLine			
				,	@CoBlnItem				
				,	@CoBlnDescription	
				,	@CoBlnCustItem			
				,	@CoBlnBlanketQty		
				,	@CoBlnContPrice			
				,	@CoBlnStat				
				,	@CoBlnPromiseDate		
				,	@CoBlnUM				
				,	@CoBlnBlanketQtyConv	
				,	@CoBlnContPriceConv		
				,	@CoBlnShipSite			
				,	@CoBlnCostConv			
				,	@CoBlnZpvTotal			
				,	@CoBlnZpvTotalDisc		
				,	@CoBlnZpvTaxCode1		
				,	@CoBlnZpvTaxCode2		
				,	@CoBlnZpvQtyShipped		
				,	@CoBlnZpvQtyReturned	
				,	@CoBlnZpvQtyInvoiced	
				,	@CoBlnZpvUnitPrice		
				,	@CoBlnZpvCoDisc			
				,	@CoBlnZpvSalesTax		
				,	@CoBlnZpvSalesTax2
				,	@CoWhse
				,	@CoWhse)

				select 
					@CoPrice	= round(sum(cob.cont_price * cob.blanket_qty),2)
				,	@CoSalesTax	= round(sum(cob.zpv_sales_tax * cob.blanket_qty),2)
				from co_bln cob
				where	cob.co_num = @CoCoNum

				exec @Severity = [dbo].[ZPV_CoTotalPercSp]
					@CoNum		= @CoCoNum
				,	@Amount		= @CoPrice
				,	@SalesTax1	= @CoSalesTax
				,	@Cuit		= null
				,	@OrderDate	= @CoOrderDate
				,	@TaxAmount	= @CoSalesTax2	output

				if @CoSalesTax2 is null set @CoSalesTax2 = 0

				update co
					set co.price		= @CoPrice
					,	co.sales_tax	= @CoSalesTax
					,	co.sales_tax_2	= @CoSalesTax2
				where co.co_num = @CoCoNum

				exec @Severity = [dbo].[ZPV_GenerateShipToSp]
					@pCoNum		= @CoCoNum
				,	@Infobar    = @Infobar        OUTPUT

				select
					@ShipCustSeq = co.cust_seq
				from co
				where co.co_num = @CoCoNum

				update custaddr
					set custaddr.zpv_obs = @TB2BObs
				where	custaddr.cust_num = @CoCustNum
					and	custaddr.cust_seq = @ShipCustSeq
			end
						
			fetch next from CurB2B
			into
				@TB2BF12		
			,	@TB2BPonum		
			,	@TB2BEmit_date	
			,	@TB2BReceptor	
			,	@TB2BAddr_recep	
			,	@TB2BComuna_recep
			,	@TB2BLocal		
			,	@TB2BShip_to	
			,	@TB2BObs		
			,	@TB2BSku		
			,	@TB2BDescription
			,	@TB2BQty		
			,	@TB2BPrice1		
			,	@TB2BPrice2		
			,	@TB2BDni		
			,	@TB2BShip_date
		end
		close CurB2B
		deallocate CurB2B

	END TRY
	BEGIN CATCH
		SET @Infobar = 'No se encuentra el archivo, el path es incorrecto, el archivo está abierto o existe un problema con el formato del mismo'
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
end


GO

