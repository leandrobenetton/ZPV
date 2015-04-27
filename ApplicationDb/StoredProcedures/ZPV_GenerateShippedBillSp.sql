/****** Object:  StoredProcedure [dbo].[ZPV_GenerateShippedBillSp]    Script Date: 30/12/2014 10:48:36 a.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GenerateShippedBillSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GenerateShippedBillSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GenerateShippedBillSp]    Script Date: 30/12/2014 10:48:36 a.m. ******/
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

CREATE PROCEDURE [dbo].[ZPV_GenerateShippedBillSp] (
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

declare 
	@TotalOrdered	decimal(18,4),
	@TotalShipped	decimal(18,4),
	@TotalInvoiced	decimal(18,4),
	@TotalOrderedAmt	AmountType,
	@TotalPaymentAmt	AmountType

DECLARE
	@ArinvCustNum		CustNumType
,	@ArinvInvNum		InvNumType
,	@ArinvInvSeq		int
,	@PostExtFin			ListYesNoType
,	@ExtFinOperationCounter  OperationCounterType

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT
		
SELECT
  @Severity = 0

set @BeginTranCount = @@trancount
if @BeginTranCount = 0
   BEGIN TRANSACTION
   
SET @SessionId = dbo.SessionIDSp()   

BEGIN
	
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

	EXEC @Severity = [dbo].[ZPV_InvoicingBGSp]
		@SessionID = @SessionId,
		@InvoiceType = N'O',
		@BGTaskName = 'ZLA_OrderInvoiceReport',
		@InvType = N'B',
		@InvCred = N'I',
		@InvDate = @InvDate,
		@StartCustomer = @StartCustomer,
		@EndCustomer = @EndCustomer,
		@StartOrderNum = @StartOrderNum,
		@EndOrderNum = @EndOrderNum,
		@StartLine = @StartLine,
		@EndLine = @EndLine,
		@StartRelease = 1,
		@EndRelease = 9999,
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
		@ZlaArTypeId = @ZlaArTypeId

	if @Severity <> 0
	begin
		ROLLBACK TRANSACTION
		return 0
	end		

	set @TotalInvoiced	= 0
	set @TotalOrdered	= 0
	set @TotalShipped	= 0
	
	select 
		@TotalOrdered	= SUM(isnull(coi.qty_ordered,0)),
		@TotalShipped	= SUM(isnull(coi.qty_shipped,0)),
		@TotalInvoiced	= SUM(isnull(coi.qty_invoiced,0))
	from coitem coi
	where
		coi.co_num = @CoNum

	--Actualiza Status de Lineas de CO a Facturado
	if @TotalOrdered = @TotalInvoiced and @TotalOrdered =  @TotalShipped
	update co_mst
		set co_mst.zpv_stat_internal = 'D04' --Ver cual es el codigo de estado correcto
	where
		co_mst.co_num = @CoNum

	if @TotalOrdered > @TotalInvoiced and @TotalOrdered = @TotalShipped
	update co_mst
		set co_mst.zpv_stat_internal = 'D02' --Ver cual es el codigo de estado correcto
	where
		co_mst.co_num = @CoNum

	if @TotalOrdered > @TotalInvoiced and @TotalOrdered > @TotalShipped and @TotalShipped > 0
	update co_mst
		set co_mst.zpv_stat_internal = 'D03' --Ver cual es el codigo de estado correcto
	where
		co_mst.co_num = @CoNum

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
END

if @BeginTranCount = 0
   if @Severity > 0
      ROLLBACK TRANSACTION
   else
      COMMIT TRANSACTION
	

RETURN @Severity
GO

