/****** Object:  StoredProcedure [dbo].[ZPV_GenerateProgCreditMemoSp]    Script Date: 16/01/2015 03:13:51 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GenerateProgCreditMemoSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_GenerateProgCreditMemoSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GenerateProgCreditMemoSp]    Script Date: 16/01/2015 03:13:51 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/* $Archive: /ApplicationDB/Stored Procedures/CoUpdateCommSlsmanSp.sp $
 *
 * SL8.02 11 rs4588 Dahn Thu Mar 04 10:28:55 2010
 * RS4588 Copyright header changes
 *
 * $NoKeywords: $
 */

CREATE PROCEDURE [dbo].[ZPV_GenerateProgCreditMemoSp] (
	@CoNum   CoNumType,
	@ZlaArTypeId	varchar(20),
	@ZlaDocId		varchar(10),
	@ApplyToInvNum	InvNumType,
	@Infobar InfobarType OUTPUT
)
AS

DECLARE
  @Severity			INT
, @InfobarText		InfobarType
, @BeginTranCount	INT
, @SessionId        RowPointerType

DECLARE
	@InvDate		DateType,
	@StartCustomer	CustNumType,
	@EndCustomer	CustNumType,
	@StartOrderNum	CoNumType,
	@EndOrderNum	CoNumType,
	@StartLine		CoLineType,
	@EndLine		CoLineType
	
SELECT
  @Severity = 0

DECLARE
	@ProgBillCoNum		CoNumType
,	@ProgBillCoLine		CoLineType
,	@ProgBillInvcFlag	ProgBillInvoiceFlagType
,	@ProgBillBittDate	DateType
,	@ProgBillDescription	DescriptionType
,	@ProgBillBillAmt		AmountType
,	@ProgBillInvNum		InvNumType
,	@ProgBillSeq		ProgBillSeqType
,	@ProgBillPosted		ListYesNoType

DECLARE
	@CobCoLine			CoLineType
,	@CobBlanketQty		QtyUnitType
,	@CobBlanketQtyConv	QtyUnitType
,	@CobPromiseDate		DateType
,	@CobContPriceConv	AmountType
,	@CobZpvTotal		AmountType
,	@CobZpvTotalDisc	AmountType
,	@CobZpvTaxCode1		TaxCodeType
,	@CobZpvTaxCode2		TaxCodeType
,	@CobZpvQtyReturned	QtyUnitType
,	@CobZpvUnitPrice	AmountType
,	@CobZpvSalesTax		AmountType
,	@CobZpvSalesTax2	AmountType

DECLARE
	@CobTaxBase			AmountType
,	@CoZpvStatInternal	varchar(5)
,	@CustCustType		CustTypeType
,	@GenCustType		CustTypeType

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

BEGIN TRANSACTION;

BEGIN TRY
   
	SET @SessionId = dbo.SessionIDSp()   

	BEGIN
		SELECT
			@InvDate		= GETDATE()
		,	@StartCustomer	= co.cust_num
		,	@EndCustomer	= co.cust_num
		,	@StartOrderNum	= co.co_num
		,	@EndOrderNum	= co.co_num
		,	@StartLine		= ISNULL(@StartLine , dbo.LowAnyInt('CoLineType'))
		,	@EndLine		= ISNULL(@EndLine , dbo.HighAnyInt('CoLineType'))
		,	@CoZpvStatInternal = co.zpv_stat_internal
		FROM co
		WHERE
			co.co_num		= @CoNum

		SELECT
			@CustCustType	= cus.cust_type
		FROM customer cus
		WHERE	cus.cust_num = @StartCustomer
			and	cus.cust_seq = 0		

		SELECT
			@GenCustType	= par.generic_cust_type
		FROM zpv_parms par
		WHERE	par.parms_key = 0

		IF EXISTS(SELECT 1 FROM progbill_mst prg WHERE prg.co_num = @CoNum and prg.invc_flag = 'Y')
		BEGIN
			DELETE FROM progbill_mst WHERE co_num = @CoNum and invc_flag = 'Y'
		END
		
		declare CurCoBln cursor for
		SELECT
			bln.co_num
		,	bln.co_line
		,	'Y'
		,	getdate()
		,	'Nota de Credito Pedido por Mostrador'
		,	(select 
				round(sum((bln1.zpv_qty_returned * (bln1.cont_price_conv - isnull(bln1.zpv_total_disc,0)))),2) * -1
			from co_bln_mst bln1	
			where
				bln1.co_num		= bln.co_num and
				bln1.co_line	= bln.co_line)
		,	null
		,	(select count(bill.seq) + 1 from progbill_mst bill where bill.co_num = bln.co_num and bill.co_line = bln.co_line)
		,	0
		FROM co_bln bln
		WHERE
			bln.stat		= 'O' and
			bln.co_num		= @CoNum and
			(bln.blanket_qty_conv * bln.cont_price_conv) > isnull(bln.zpv_prg_bill_tot,0)
		open CurCoBln
		fetch next from CurCoBln
		into
			@ProgBillCoNum		
		,	@ProgBillCoLine		
		,	@ProgBillInvcFlag	
		,	@ProgBillBittDate	
		,	@ProgBillDescription
		,	@ProgBillBillAmt	
		,	@ProgBillInvNum		
		,	@ProgBillSeq		
		,	@ProgBillPosted		
		while @@fetch_status = 0
		begin
			INSERT INTO progbill(
				co_num,
				co_line,
				invc_flag,
				bill_date,
				[description],
				bill_amt,
				inv_num,
				seq,
				posted)
			VALUES(
				@ProgBillCoNum		
			,	@ProgBillCoLine		
			,	@ProgBillInvcFlag	
			,	@ProgBillBittDate	
			,	@ProgBillDescription
			,	@ProgBillBillAmt	
			,	@ProgBillInvNum		
			,	@ProgBillSeq		
			,	@ProgBillPosted)	

			fetch next from CurCoBln
			into
				@ProgBillCoNum		
			,	@ProgBillCoLine		
			,	@ProgBillInvcFlag	
			,	@ProgBillBittDate	
			,	@ProgBillDescription
			,	@ProgBillBillAmt	
			,	@ProgBillInvNum		
			,	@ProgBillSeq		
			,	@ProgBillPosted			
		end
		close CurCoBln
		deallocate CurCoBln

		if not exists(select * from progbill where co_num = @CoNum)
		begin
			set @Infobar = 'No Existen Lineas por facturar'
			ROLLBACK TRANSACTION
			return 0
		end
	
		EXEC @Severity = [dbo].[ZPV_InvoicingBGSp]
			@SessionID = @SessionId,
			@InvoiceType = N'O',
			@BGTaskName = 'ZLA_OrderInvoiceReport',
			@InvType = N'P',
			@InvCred = N'C',
			@InvDate = @InvDate,
			@StartCustomer = @StartCustomer,
			@EndCustomer = @EndCustomer,
			@StartOrderNum = @StartOrderNum,
			@EndOrderNum = @EndOrderNum,
			@StartLine = @StartLine,
			@EndLine = @EndLine,
			@StartRelease = NULL,
			@EndRelease = NULL,
			@StartLastShipDate = NULL,
			@EndLastShipDate = NULL,
			@StartPackNum = NULL,
			@EndPackNum = NULL,
			@CreateFromPackSlip = NULL,
			@pMooreForms = N'L',
			@pNonDraftCust = 0,
			@SelectedStartInvNum = NULL,
			@CheckShipItemActiveFlag = 0,
			--@StartInvNum = @StartInvNum OUTPUT,
			--@EndInvNum = @EndInvNum OUTPUT,
			@PrintItemCustomerItem = N'CI',
			@TransToDomCurr = 0,
			@PrintSerialNumbers = 1,
			@PrintPlanItemMaterial = 0,
			@PrintConfigurationDetail = N'E',
			@PrintEuro = 0,
			@PrintCustomerNotes = 1,
			@PrintOrderNotes = 1,
			@PrintOrderLineNotes = 1,
			@PrintOrderBlanketLineNotes = 1,
			@PrintProgressiveBillingNotes = 0,
			@PrintInternalNotes = 0,
			@PrintExternalNotes = 1,
			@PrintItemOverview = 0,
			@DisplayHeader = 0,
			@PrintLineReleaseDescription = 1,
			@PrintStandardOrderText = 1,
			@PrintBillToNotes = 1,
			@LangCode = NULL,
			@PrintDiscountAmt = 0,
			@BatchId = NULL,
			@BGSessionId = NULL,
			@UserId = 2,
			--@Infobar = @Infobar OUTPUT,
			@LCRVar = NULL,
			@pBegDoNum = NULL,
			@pEndDoNum = NULL,
			@pBegCustPo = NULL,
			@pEndCustPo = NULL,
			--@DoHdrList = @DoHdrList OUTPUT,
			@PItemTypeCust = NULL,
			@PItemTypeItem = NULL,
			--@PrintConInvReport = @PrintConInvReport OUTPUT,
			@PInvNum = NULL,
			@POrderNums = NULL,
			@PMiscCharges = NULL,
			@PSalesTax = NULL,
			@PFreight = NULL,
			@TCustPT = NULL,
			@PApplyToInvNum = @ApplyToInvNum,
			@TOpt = NULL,
			@UseProfile = 1,
			@Mode = N'PROCESS',
			@PrintLotNumbers = 1,
			@StartInvDate = NULL,
			@EndInvDate = NULL,
			@CurrentCultureName = 'es-ES',
			@StartingShipment = NULL,
			@EndingShipment = NULL,
			@InvoiceTypeJP = S,
			@CalledFrom = NULL,
			@InvoicBuilderProcessID = NULL,
			@ZlaArTypeId = @ZlaArTypeId,
			@CoCoNum = @CoNum

		if @Severity <> 0
		begin
			ROLLBACK TRANSACTION
			return 0
		end		
		
		declare CurCoBln cursor for
		select
			cob.co_line
		,	cob.blanket_qty
		,	cob.blanket_qty_conv	
		,	cob.promise_date
		,	cob.cont_price_conv
		,	cob.zpv_total
		,	cob.zpv_total_disc
		,	cob.zpv_tax_code1
		,	cob.zpv_tax_code2
		,	cob.zpv_qty_returned
		,	cob.zpv_unit_price
		,	cob.zpv_sales_tax
		,	cob.zpv_sales_tax2
		from co_bln cob
		where	cob.co_num = @CoNum	
		open CurCoBln
		fetch next from CurCoBln
		into
			@CobCoLine			
		,	@CobBlanketQty		
		,	@CobBlanketQtyConv	
		,	@CobPromiseDate		
		,	@CobContPriceConv	
		,	@CobZpvTotal		
		,	@CobZpvTotalDisc	
		,	@CobZpvTaxCode1		
		,	@CobZpvTaxCode2		
		,	@CobZpvQtyReturned	
		,	@CobZpvUnitPrice	
		,	@CobZpvSalesTax		
		,	@CobZpvSalesTax2	
		while @@FETCH_STATUS = 0
		begin
			SET		@CobBlanketQty		= @CobBlanketQty - isnull(@CobZpvQtyReturned,0)
			SET		@CobBlanketQtyConv	= @CobBlanketQtyConv - isnull(@CobZpvQtyReturned,0)

			IF @CobBlanketQtyConv	> 0
			BEGIN
				SET		@CobTaxBase			= round(@CobBlanketQtyConv * (@CobContPriceConv - @CobZpvTotalDisc),5)

				EXEC	@Severity = [dbo].[CalcSalesTaxSp]
						@PTaxSystem = 1,
						@PTaxCode = @CobZpvTaxCode1,
						@PTaxBasis = @CobTaxBase,
						@PVendNum = null,
						@PSalesTax = @CobZpvSalesTax OUTPUT

				EXEC	@Severity = [dbo].[CalcSalesTaxSp]
						@PTaxSystem = 2,
						@PTaxCode = @CobZpvTaxCode2,
						@PTaxBasis = @CobTaxBase,
						@PVendNum = null,
						@PSalesTax = @CobZpvSalesTax2 OUTPUT
			
				SET		@CobZpvTotal		= @CobTaxBase + @CobZpvSalesTax + @CobZpvSalesTax2
				SET		@CobZpvUnitPrice	= @CobZpvTotal / @CobBlanketQtyConv

			END
			ELSE
			BEGIN
				SET		@CobTaxBase			= 0
				SET		@CobZpvSalesTax		= 0
				SET		@CobZpvSalesTax2	= 0
				SET		@CobZpvTotal		= 0
				SET		@CobZpvUnitPrice	= 0
			END

			UPDATE co_bln
				SET		co_bln.blanket_qty			= @CobBlanketQty
					,	co_bln.blanket_qty_conv		= @CobBlanketQtyConv
					,	co_bln.zpv_total			= round(@CobZpvTotal,2)
					,	co_bln.zpv_qty_returned		= 0
					,	co_bln.zpv_unit_price		= @CobZpvUnitPrice
					,	co_bln.zpv_sales_tax		= @CobZpvSalesTax
					,	co_bln.zpv_sales_tax2		= @CobZpvSalesTax2
			WHERE	co_bln.co_num	= @CoNum
				and	co_bln.co_line	= @CobCoLine

			fetch next from CurCoBln
			into
				@CobCoLine			
			,	@CobBlanketQty		
			,	@CobBlanketQtyConv	
			,	@CobPromiseDate		
			,	@CobContPriceConv	
			,	@CobZpvTotal		
			,	@CobZpvTotalDisc	
			,	@CobZpvTaxCode1		
			,	@CobZpvTaxCode2		
			,	@CobZpvQtyReturned	
			,	@CobZpvUnitPrice	
			,	@CobZpvSalesTax		
			,	@CobZpvSalesTax2	
		end
		close CurCoBln
		deallocate CurCoBln

		exec @Severity = [dbo].[ZPV_UpdateCoBlnProcessSp]
				@CoNum = @CoNum,
				@Infobar = @Infobar OUTPUT


		--Actualiza Status de Lineas de CO a Facturado		
		if @CustCustType = @GenCustType
		begin
			if @CoZpvStatInternal	= 'X99'
				update co
					set co.zpv_stat_internal = 'M04',
						co.stat = 'O',
						co.zpv_stat = 'F00' 
				where
					co.co_num = @CoNum	
		
		end				

		/* Cliente CtaCte */
		
	END

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


GO

