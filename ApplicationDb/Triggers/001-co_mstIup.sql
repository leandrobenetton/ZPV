/****** Object:  Trigger [co_mstIup]    Script Date: 29/12/2014 01:57:53 a.m. ******/
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'co_mstIup' AND xtype = 'TR')
DROP TRIGGER [dbo].[co_mstIup]
GO

/****** Object:  Trigger [dbo].[co_mstIup]    Script Date: 29/12/2014 01:57:53 a.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE TRIGGER [dbo].[co_mstIup]
on [dbo].[co_mst]
FOR INSERT, UPDATE
AS

DECLARE @Site SiteType
, @InsertFlag tinyint
, @MrpParmReqSrc MrpReqSrcType

SELECT @Site = prm.site
FROM parms AS prm with (readuncommitted)
WHERE prm.parm_key = 0
SELECT
  @InsertFlag = CASE
    WHEN EXISTS ( SELECT 1 FROM deleted ) THEN 0
      ELSE 1
    END

DECLARE
  @Severity  INT
, @Infobar    InfobarType
, @Partition uniqueidentifier
, @ActionExpression NVARCHAR(60)

SET @Severity = 0

/*========   CURSOR PROCESSING SECTION    ========*/
DECLARE
  @CoNum          CoNumType
, @CoLine         CoLineType
, @InCoNum        CoNumType
, @CustPo         CustPoType
, @OldCustPo      CustPoType
, @CustNum        CustNumType
, @OldCustNum     CustNumType
, @CustSeq        CustSeqType
, @OldCustSeq     CustSeqType
, @Slsman         SlsmanType
, @OldSlsman      SlsmanType
, @OrderDate      DateType
, @OldOrderDate   DateType
, @PrepaidAmt     AmountType
, @OldPrepaidAmt  AmountType
, @Freight        AmountType
, @OldFreight     AmountType
, @MiscCharges    AmountType
, @OldMiscCharges AmountType
, @SalesTax       AmountType
, @OldSalesTax    AmountType
, @SalesTax2      AmountType
, @OldSalesTax2   AmountType
, @SalesTaxT      AmountType
, @OldSalesTaxT   AmountType
, @SalesTaxT2     AmountType
, @OldSalesTaxT2  AmountType
, @Disc           OrderDiscType
, @OldDisc        OrderDiscType
, @DiscAmount     AmountType
, @OldDiscAmount  AmountType
, @DiscountType   ListAmountPercentType
, @UseExchRate    Flag
, @OldUseExchRate Flag
, @CheckUseExchRate Flag
, @ExchRate       ExchRateType
, @OldExchRate    ExchRateType
, @TaxCode1       TaxCodeType
, @OldTaxCode1    TaxCodeType
, @TaxCode2       TaxCodeType
, @OldTaxCode2    TaxCodeType
, @Status         CoStatusType
, @OldStatus      CoStatusType
, @LcrNum         LcrNumType
, @OldLcrNum      LcrNumType
, @TotalPrice     AmountType
, @OldTotalPrice  AmountType
, @NegOldTotalPrice  AmountType
, @Adjust         AmountType
, @Type           CoTypeType
, @OldType        CoTypeType
, @EndUserType    EndUserTypeType
, @OldEndUserType EndUserTypeType
, @CreditHold     ListYesNoType
, @OldCreditHold  ListYesNoType
, @CreditHoldReason ReasonCodeType
, @OldCreditHoldReason ReasonCodeType
, @RowPointer     RowPointerType
, @EstSetLineStat ListYesNoType
, @OrigSite       SiteType
, @ShipSite       SiteType
, @ShipSiteList   Infobar
, @CurrCode       CurrCodeType
, @iEntry         INT
, @iNumEntries    INT
, @PlannedDiscountOffset AmountType
--, @TraceMsg       Infobar
, @Consolidate       ListYesNoType
, @UseMultiDueDate   ListYesNoType
, @TermsCode         TermsCodeType
, @UpdateOrderBalance  ListYesNoType
, @WhereClause          LongListType
, @OppId          OpportunityIDType
, @FCItem         ItemType
, @Priority       ApsSmallIntType
, @OldPriority    ApsSmallIntType
, @IsExternal     ListYesNoType

Declare @ZrtStatInternal varchar(5)

SELECT
    @CoNum = ii.co_num
    , @CustPo = ii.cust_po
    , @OldCustPo = dd.cust_po
    , @CustNum = ii.cust_num
    , @OldCustNum = dd.cust_num
    , @CustSeq = ii.cust_seq
    , @OldCustSeq = dd.cust_seq
    , @Slsman = ii.slsman
    , @OldSlsman = dd.slsman
    , @PrepaidAmt = ii.prepaid_amt
    , @OldPrepaidAmt = dd.prepaid_amt
    , @Freight = ii.freight
    , @OldFreight = dd.freight
    , @MiscCharges = ii.misc_charges
    , @OldMiscCharges = dd.misc_charges
    , @SalesTax = ii.sales_tax
    , @OldSalesTax = dd.sales_tax
    , @SalesTax2 = ii.sales_tax_2
    , @OldSalesTax2 = dd.sales_tax_2
    , @SalesTaxT = ii.sales_tax_t
    , @OldSalesTaxT = dd.sales_tax_t
    , @SalesTaxT2 = ii.sales_tax_t2
    , @OldSalesTaxT2 = dd.sales_tax_t2
    , @Disc = ii.disc
    , @OldDisc = dd.disc
    , @DiscAmount = ii.disc_amount
    , @OldDiscAmount = dd.disc_amount
    , @DiscountType = ii.discount_type
    , @UseExchRate = ii.use_exch_rate
    , @OldUseExchRate = dd.use_exch_rate
    , @ExchRate = ii.exch_rate
    , @OldExchRate = dd.exch_rate
    , @TaxCode1 = ii.tax_code1
    , @OldTaxCode1 = dd.tax_code1
    , @TaxCode2 = ii.tax_code2
    , @OldTaxCode2 = dd.tax_code2
    , @Status = ii.stat
    , @OldStatus = dd.stat
    , @LcrNum = ii.lcr_num
    , @OldLcrNum = dd.lcr_num
    , @TotalPrice = ii.price
    , @OldTotalPrice = dd.price
    , @Type = ii.type
    , @OldType = dd.type
    , @OrderDate = ii.order_date
    , @OldOrderDate = dd.order_date
    , @EndUserType = ii.end_user_type
    , @OldEndUserType = dd.end_user_type
    , @CreditHold = ii.credit_hold
    , @OldCreditHold = dd.credit_hold
    , @CreditHoldReason = ii.credit_hold_reason
    , @OldCreditHoldReason = dd.credit_hold_reason
    , @OrigSite = ii.orig_site
    , @RowPointer = ii.RowPointer
    , @LcrNum = ii.lcr_num
    , @Consolidate = ii.consolidate
    , @TermsCode  = ii.terms_code  
    , @OppId = ii.opp_id
    , @Priority = ii.priority
    , @OldPriority = dd.priority
    , @IsExternal = ii.is_external
	, @ZrtStatInternal = ii.zpv_stat_internal
    FROM inserted ii
    LEFT OUTER JOIN deleted AS dd ON
    dd.RowPointer = ii.RowPointer

	-- ZRT
	if @InsertFlag = 1
	begin
		DELETE FROM zla_co_tax_mst
			WHERE
				co_num = @CoNum			
					
		DECLARE
		@TaxGroupId	varchar(20),
		@CoCoNum	CoNumType,
		@CoCustNum	CustNumType,
		@SiteRef	SiteType
				
		declare CoCur cursor for
		select 
			ii.cust_num,
			ii.co_num,
			ii.site_ref
		from inserted ii
		open CoCur
		fetch next from CoCur
		into
			@CoCustNum,
			@CoCoNum,
			@SiteRef
		while @@FETCH_STATUS = 0
		begin
			declare TaxCur cursor for
			select
				tax.tax_group_id
			from zla_tax_customer_mst tax
			where
				tax.cust_num = @CoCustNum
			open TaxCur
			fetch next from TaxCur
			into
				@TaxGroupId
				while @@FETCH_STATUS = 0
				begin
					insert into zla_co_tax_mst(
						site_ref,
						co_num,
						[type],
						tax_group_id)
					values(
						@SiteRef,
						@CoNum,
						'O',
						@TaxGroupId)
					fetch next from TaxCur
					into
						@TaxGroupId
				end	
			close TaxCur
			deallocate TaxCur				
			fetch next from CoCur
			into
				@CoCustNum,
				@CoCoNum,
				@SiteRef
		end
		close CoCur
		deallocate CoCur						
	end
	-- ZRT
   


GO
EXEC sp_settriggerorder @triggername=N'[dbo].[co_mstIup]', @order=N'First', @stmttype=N'INSERT'
GO
EXEC sp_settriggerorder @triggername=N'[dbo].[co_mstIup]', @order=N'First', @stmttype=N'UPDATE'