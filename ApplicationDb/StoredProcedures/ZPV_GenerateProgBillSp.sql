/****** Object:  StoredProcedure [dbo].[ZPV_GenerateProgBillSp]    Script Date: 16/01/2015 03:13:32 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GenerateProgBillSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GenerateProgBillSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GenerateProgBillSp]    Script Date: 16/01/2015 03:13:32 p.m. ******/
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

CREATE PROCEDURE [dbo].[ZPV_GenerateProgBillSp] (
	@CoNum   CoNumType,
	@ZlaArTypeId	varchar(20)
,	@Infobar InfobarType OUTPUT
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
	@ArinvCustNum		CustNumType
,	@ArinvInvNum		InvNumType
,	@ArinvInvSeq		int
,	@PostExtFin			ListYesNoType
,	@ExtFinOperationCounter  OperationCounterType

SELECT
  @Severity = 0

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

BEGIN TRANSACTION;

BEGIN TRY
   
	SET @SessionId = dbo.SessionIDSp()   

	BEGIN
		IF EXISTS(SELECT 1 FROM co WHERE co.co_num = @CoNum AND co.zpv_stat_internal = 'M03')
		BEGIN
			UPDATE co_bln
				SET stat = 'O'
			WHERE co_num = @CoNum
		END

		SELECT
			@InvDate		= GETDATE(),
			@StartCustomer	= co.cust_num,
			@EndCustomer	= co.cust_num,
			@StartOrderNum	= co.co_num,
			@EndOrderNum	= co.co_num,
			@StartLine		= ISNULL(@StartLine , dbo.LowAnyInt('CoLineType')),
			@EndLine		= ISNULL(@EndLine , dbo.HighAnyInt('CoLineType'))
		FROM co_mst co
		WHERE
			co.co_num		= @CoNum
	
		IF EXISTS(SELECT 1 FROM progbill prg WHERE prg.co_num = @CoNum and prg.invc_flag = 'Y')
		BEGIN
			DELETE FROM progbill WHERE co_num = @CoNum and invc_flag = 'Y'
		END
	
		declare CurCoBln cursor for
		SELECT
			bln.co_num
		,	bln.co_line
		,	'Y'
		,	getdate()
		,	'Facturacion de Pedido por Mostrador'
		,	(select 
				round(sum((bln1.blanket_qty_conv * (bln1.cont_price_conv - isnull(bln1.zpv_total_disc,0))) - isnull(bln1.zpv_prg_bill_tot,0)),2) 
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
				co_num
			,	co_line
			,	invc_flag
			,	bill_date
			,	[description]
			,	bill_amt
			,	inv_num
			,	seq
			,	posted)
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
		
		if not exists(select 1 from progbill where co_num = @CoNum)
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
			@InvCred = N'I',
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
			@PApplyToInvNum = NULL,
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
	
		-- Posteo de Facturas
		if @Severity = 0
		begin
			declare CurArinv cursor for
			select
				ar.cust_num
			,	ar.inv_num
			,	ar.inv_seq
			from arinv ar
			where	ar.co_num		= @CoNum
				and	ar.cust_num		= @StartCustomer
			open CurArinv
			fetch next from CurArinv
			into
				@ArinvCustNum
			,	@ArinvInvNum
			,	@ArinvINvSeq
			while @@FETCH_STATUS = 0
			begin
				EXEC	@Severity = [dbo].[ZPV_InvPostingSp]
					@PSessionID = @SessionId,
					@PCustNum = @ArinvCustNum,
					@PInvNum = @ArinvInvNum,
					@PInvSeq = @ArinvInvSeq,
					@PJHeaderRowPointer = NULL,
					@PostExtFin = @PostExtFin OUTPUT,
					@ExtFinOperationCounter = @ExtFinOperationCounter OUTPUT,
					@Infobar = @Infobar OUTPUT,
					@ToSite = @Site,
					@PostSite = @Site
				
				fetch next from CurArinv
				into
					@ArinvCustNum
				,	@ArinvInvNum
				,	@ArinvINvSeq
			end
			close CurArinv
			deallocate CurArinv
		end

		--Actualiza Status de Lineas de CO a Facturado
		update co
			set co.zpv_stat_internal = 'M04' --Ver cual es el codigo de estado correcto
		where
			co.co_num = @CoNum				


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

