/****** Object:  StoredProcedure [dbo].[ZPV_ArinvTaxCalcSp]    Script Date: 10/29/2014 12:24:42 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ArinvTaxCalcSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_ArinvTaxCalcSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ArinvTaxCalcSp]    Script Date: 10/29/2014 12:24:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_ArinvTaxCalcSp]
(
 @CustNum CustNumType
,@InvNum InvNumType
,@InvSeq InvSeqType
,@Infobar InfobarType OUTPUT
)
AS
DECLARE @ZlaArTypeId ZlaArTypeIdType

DECLARE
  @ArinvRowPointer RowPointerType
 ,@ArinvCustNum CustNumType
 ,@ArinvInvNum InvNumType
 ,@ArinvType ArinvTypeType
 ,@ArinvPostFromCo ListYesNoType
 ,@ArinvCoNum CoNumType
 ,@ArinvInvDate DateType
 ,@ArinvTaxCode1 TaxCodeType
 ,@ArinvTaxCode2 TaxCodeType
 ,@ArinvTermsCode TermsCodeType
 ,@ArinvAcct AcctType
 ,@ArinvAcctUnit1 UnitCode1Type
 ,@ArinvAcctUnit2 UnitCode2Type
 ,@ArinvAcctUnit3 UnitCode3Type
 ,@ArinvAcctUnit4 UnitCode4Type
 ,@ArinvRef ReferenceType
 ,@ArinvDescription DescriptionType
 ,@ArinvExchRate ExchRateType
 ,@ArinvUseExchRate ListYesNoType
 ,@ArinvFixedRate ListYesNoType
 ,@ArinvPayType CustPayTypeType
 ,@ArinvDraftPrintFlag ListYesNoType
 ,@ArinvDueDate DateType
 ,@ArinvInvSeq ArInvSeqType
 ,@ArinvSalesTax AmountType
 ,@ArinvSalesTax1 AmountType
 ,@ArinvSalesTax2 AmountType
 ,@ArinvZlaForSalesTax1 AmountType
 ,@ArinvZlaForSalesTax2 AmountType
 ,@ArinvMiscCharges AmountType
 ,@ArinvFreight AmountType
 ,@ArinvAmount AmountType
 ,@ArinvApprovalStatus ListPendingApprovedRejectedType
 
DECLARE
  @ArinvdRowPointer RowPointerType
 ,@ArinvdAmount AmountType
 ,@ArinvdCustNum CustNumType
 ,@ArinvdInvNum InvNumType
 ,@ArinvdInvSeq ArInvSeqType
 ,@ArinvdDistSeq ArDistSeqType
 ,@ArinvdAcct AcctType
 ,@ArinvdAcctUnit1 UnitCode1Type
 ,@ArinvdAcctUnit2 UnitCode2Type
 ,@ArinvdAcctUnit3 UnitCode3Type
 ,@ArinvdAcctUnit4 UnitCode4Type
 ,@ArinvdTaxSystem TaxSystemType
 ,@ArinvdTaxCode TaxCodeType
 ,@ArinvdTaxCodeE TaxCodeType
 ,@ArinvdTaxBasis AmountType
 ,@ArInvDateDay WeekDayType
 ,@ArInvDueDateDay WeekDayType
 ,@ArinvdRefType RefTypeOType
 ,@ArinvdRefNum CoNumType
 ,@ArinvdRefLineSuf CoLineType
 ,@ArinvdRefRelease CoReleaseType

DECLARE
  @CustAddrCurrCode CurrCodeType
 ,@CustAddrState	StateType
 ,@Severity int

DECLARE
  @tax_type_id varchar(15)
 ,@tax_group_id varchar(15)
 ,@base_amount decimal(15,2)
 ,@base_amount_country decimal(15,2)
 ,@tax_amount decimal(15,2)
 ,@tax_amount_country decimal(15,2)
 ,@tax_percent decimal(6,3)

-- Declare Temp Tables
IF OBJECT_ID(N'dbo.#temp_ar_tax_in') IS NOT NULL
  DROP TABLE #temp_ar_tax_in

CREATE TABLE #temp_ar_tax_in
(
  [tax_type_id] nvarchar(15) NULL
 ,[tax_group_id] nvarchar(15) NULL
 ,[acct] nvarchar(12) NULL
 ,[amount] decimal(21,8) NULL
 ,[vat_amount] decimal(21,8) NULL
 ,[vat_acct] nvarchar(12) NULL
 ,[state] nvarchar(5) NULL
)


IF OBJECT_ID(N'dbo.#temp_ar_tax_out') IS NOT NULL
  DROP TABLE temp_ar_tax_out

CREATE TABLE #temp_ar_tax_out
(
  [tax_type_id] varchar(15)
 ,[tax_group_id] varchar(15)
 ,[base_amount] decimal(15,2)
 ,[base_amount_country] decimal(15,2)
 ,[tax_amount] decimal(15,2)
 ,[tax_amount_country] decimal(15,2)
 ,[tax_percent] decimal(6,3)
)



SELECT
  @CustAddrCurrCode = curr_code
 ,@CustAddrState = state
FROM
  custaddr
WHERE
cust_num = @CustNum
AND cust_seq = 0

-- Get default information from Invoice  record
SELECT TOP 1
  @ArinvInvDate = arinv.inv_date
 ,@ZlaArTypeId = zla_ar_type_id
 ,@ArinvExchRate = zla_for_exch_rate
FROM
  arinv
WHERE
cust_num = @CustNum
AND inv_num = @InvNum
AND inv_seq = @InvSeq
AND post_from_co = 0

IF @@ROWCOUNT = 0
  BEGIN
    SET @Infobar = NULL
    EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=CmdFailed1', '@%co/tax-calc',
    '@arinv', '@arinv.inv_num', @InvNum

    RETURN @Severity
  END

INSERT INTO
  #temp_ar_tax_in
  (
    [tax_type_id]
  ,[tax_group_id]
  ,[acct]
  ,[amount]
  ,[vat_amount]
  ,[vat_acct]
  ,[state]
  )
  SELECT
    TGrp.tax_type_id
   ,TGrp.group_id
   ,AriBase.acct
   ,AriTax.zla_for_tax_basis
   ,AriTax.zla_for_amount
   ,AriTax.Acct
   ,NULL
  FROM
    zla_arinvd_tax Tax
    INNER JOIN zla_tax_group TGrp ON TGrp.GROUP_ID = tax.tax_group_id

    INNER JOIN arinvd AriTax ON AriTax.cust_num = tax.cust_num
					    AND AriTax.inv_num = tax.Inv_num
					    AND AriTax.inv_seq = tax.inv_seq
					    AND AriTax.dist_seq = tax.dist_seq

   INNER JOIN arinvd AriBase 
  ON AriBase.cust_num = AriTax.cust_num
     AND AriBase.inv_num = AriTax.Inv_num
     AND AriBase.inv_seq = AriTax.inv_seq
     AND AriBase.dist_seq = AriTax.zla_base_dist_seq 
  WHERE
  tax.cust_num = @CustNum
  AND tax.Inv_num = @InvNum
  AND tax.inv_seq = @InvSeq


-- Call MUCI Tax Calculation
EXECUTE [ZLA_MuciSp] 'AR', @ArinvInvDate, @CustNum, @CustaddrCurrCode, @ZlaArTypeId,@ArinvExchRate, NULL


DELETE  FROM
        arinvd
WHERE
cust_num = @CustNum
AND inv_num = @InvNum
AND inv_seq = @InvSeq
AND tax_system = 2


SET @ArinvSalesTax1 = 0
SET @ArinvSalesTax2  = 0
SET @ArinvZlaForSalesTax1 = 0
SET @ArinvZlaForSalesTax2 = 0


 SELECT @ArinvdDistSeq = MAX(dist_seq)
From arinvd
WHERE
cust_num = @CustNum
AND inv_num = @InvNum
AND inv_seq = @InvSeq


IF EXISTS ( SELECT
              1
            FROM
              #temp_ar_tax_out )
  BEGIN

     DECLARE ZlaTaxOutCur CURSOR LOCAL STATIC
      FOR SELECT
            [tax_type_id]
           ,[tax_group_id]
           ,[base_amount]
           ,[base_amount_country]
           ,[tax_amount]
           ,[tax_amount_country]
           ,[tax_percent]
          FROM
            #temp_ar_tax_out

    OPEN ZlaTaxOutCur
    WHILE 1 = 1
      BEGIN

        FETCH ZlaTaxOutCur INTO @tax_type_id 
        ,@tax_group_id 
        ,@base_amount 
        ,@base_amount_country
        ,@tax_amount 
        ,@tax_amount_country 
        ,@tax_percent

        IF @@FETCH_STATUS <> 0
          BREAK

				
			 
        SELECT
          @ArinvdAcct = ACCOUNT_ID
	    , @ArinvdTaxSystem = tax_system
	    , @ArinvdTaxCode  = tax_code
        FROM
          zla_tax_group
        WHERE
        group_id = @tax_group_id


	 IF ( EXISTS(SELECT 1 from tax_system 
			Where tax_system = @ArinvdTaxSystem
			And record_zero = 1 ) And  @tax_amount = 0 )
			OR @tax_amount <> 0
	 BEGIN 

	 -- Set Defauult Sequence for Tax System 2 Distributio
	 SET @ArinvdDistSeq = @ArinvdDistSeq + 5

	 -- Accumulate Tax System 2 Taxes in @TSalesTax2
	   SET @ArinvSalesTax2 = @ArinvSalesTax2 + @tax_amount



        INSERT INTO
          arinvd
          (
            [cust_num]
          ,[inv_num]
          ,[inv_seq]
          ,[dist_seq]
          ,[acct]
          ,[amount]
          ,[tax_code]
          ,[tax_basis]
          ,[tax_system]
          ,[zla_for_tax_basis] 
          ,[zla_for_amount] 
				 	, zla_tax_group_id
				   , zla_tax_rate
             )
        VALUES
          (
            @CustNum
          ,@InvNum
          ,@InvSeq
          ,@ArinvdDistSeq
          ,@ArinvdAcct
          ,@tax_amount_country
          ,@ArinvdTaxCode
          ,@base_amount_country
          ,@ArinvdTaxSystem
          ,@base_amount
          ,@tax_amount
				 	,@tax_group_id
				 	, @tax_percent
          )
	 END
      END


    CLOSE ZlaTaxOutCur
    DEALLOCATE ZlaTaxOutCur



  END
  
  Select @ArinvSalesTax1 = SUM(arinvd.amount),
			@arinvZlaForSalesTax1 = SUM(arinvd.zla_for_amount)
	FROM arinvd 
	WHERE 
    cust_num = @CustNum
    and arinvd.inv_num = @InvNum
    And inv_seq = @InvSeq
    And tax_system = 1
    
  Select @ArinvSalesTax2 = SUM(arinvd.amount),
	   @arinvZlaForSalesTax2 = SUM(arinvd.zla_for_amount)
	FROM arinvd 
	WHERE 
    cust_num = @CustNum
    and arinvd.inv_num = @InvNum
    And inv_seq = @InvSeq
    And tax_system = 2

		 
      UPDATE arinv 
       SET sales_tax = ISNULL(@ArinvSalesTax1,0)
       ,sales_tax_2 = ISNULL(@ArinvSalesTax2,0)
       ,zla_for_sales_tax = ISNULL(@ArinvZlaForSalesTax1,0)
       ,zla_for_sales_tax_2 = ISNULL(@ArinvZlaForSalesTax2,0)
      WHERE
    cust_num = @CustNum
    and inv_num = @InvNum
    And inv_seq = @InvSeq

 
-- ZLA End


GO

