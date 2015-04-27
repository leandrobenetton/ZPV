/****** Object:  StoredProcedure [dbo].[ZPV_CreateGlBankSp]    Script Date: 16/01/2015 03:12:28 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CreateGlBankSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CreateGlBankSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CreateGlBankSp]    Script Date: 16/01/2015 03:12:28 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ZLA_CreateGlBankSp.sp 14    5/17/10 2:07p pcoate $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZLA_CreateGlBankSp.sp $
 *
 * SL8.02 14 129280 pcoate Mon May 17 14:07:10 2010
 * The same returned check can be processed again and again
 * Issue 129280 - Corrected the glbank.type value for new glbank rows created.
 *
 * SL8.02 13 130333 pcoate Fri May 14 09:30:41 2010
 * glbank.type is getting populated with an incorrect value.
 * Issue 130333 - Changed logic to set glbank.type to 'D' (deposit) instead of 'C' (check).
 *
 * SL8.02 12 130203 pcoate Tue May 11 12:56:45 2010
 * There is some code that needs corrected.
 * Issue 130203 - Changed code to only populate glbank.cust_check_num when posting a payment of type "Check".
 *
 * SL8.02 11 130164 pcoate Mon May 10 14:50:08 2010
 * The design for RS4021 did not take mulit-currency into account.
 * Issue 130164 - Changed logic to handle updating the glbank.amount column with a value that is of the same currency as the bank for the glbank record being created/updated.
 *
 * SL8.02 10 130122 pcoate Mon May 10 14:04:48 2010
 * Both Checks and Wires are only being posted for one bank at a time, though they should be posting for any number of banks in one posting
 * Issue 130122 - Converted tabs to spaces and did general code clean up.  No actual functionality was altered.
 *
 * SL8.02 9 rs4588 Dahn Thu Mar 04 10:29:46 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 8 rs4588 Dahn Thu Mar 04 09:40:17 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 7 rs4021 Mewing Thu Feb 11 15:48:48 2010
 * Update files missed in checking
 *
 * SL8.02 6 rs4021 Mewing Wed Jan 13 18:28:01 2010
 *
 * SL8.02 5 rs4021 Mewing Wed Jan 06 12:31:37 2010
 *
 * SL8.02 4 rs4021 Mewing Mon Dec 14 14:31:06 2009
 *
 * SL8.02 3 rs4021 Mewing Thu Oct 29 15:59:09 2009
 *
 * SL8.02 2 rs4021 Mewing Thu Oct 29 09:53:50 2009
 *
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_CreateGlBankSp] (
     @ProcessId     RowPointer
   , @BankCode      BankCodeType
   , @CheckDate	    DateType
   , @CheckNumber   ArCheckNumType
   , @CheckAmt      AmountType
   , @Type          ArpmtTypeType
   , @RefType       ReferenceType
   , @RefNum        CustNumType
   , @DomCheckAmt   AmountType
   , @Infobar       InfobarType OUTPUT
	, @ZlaThirdPartyCheck	    ListYesNoType	= NULL
	, @ZlaThirdBankId				BankCodeType	= NULL
	, @ZlaThirdDescription		DescriptionType = NULL
	, @ZlaThirdTaxNumReg			TaxRegNumType	= NULL
	, @ZlaThirdCheckDate			DateType			= NULL
   , @ZlaArPayId					ZlaArPayIdType	-- Payment Order
	, @ZlaCreditCardExpDate		ZlaCreditCardExpDateType = NULL
	, @ZlaCreditCardPayments	ZlaCreditCardPaymentType = NULL
	, @GlBankRowPointer			RowPointerType OUTPUT
) AS


DECLARE
     @Severity       INT
   , @Transaction    GlCheckNumType
   , @Exists         INT
   , @CreateTempRec  tinyint
   , @CustCurrCode   CurrCodeType
   , @BankCurrCode   CurrCodeType
   , @BankCurrAmount AmountType
   , @NewRecType     ArpmtTypeType


SET @Severity = 0
SET @Infobar  = NULL

-- Set new glbank rows glbank.type column to 'D' (deposit) unless it is a bank fee, in which case set it to 'O' (other).
SET @NewRecType = CASE WHEN @Type = 'O' THEN 'O' ELSE 'D' END

SELECT @BankCurrCode = curr_code
FROM bank_hdr
WHERE bank_code = @BankCode

SELECT @CustCurrCode = curr_code
FROM custaddr
WHERE cust_num = @RefNum AND cust_seq = 0


IF @ProcessId is not null
BEGIN
   SET @CreateTempRec = 1 

   -- Check to see if a GLBank record of this type, bank code, and ProcessId already exits
   SELECT @Exists = COUNT(*)  FROM tmp_arpaypostbankrecon 
		-- ZLA 
		LEFT OUTER JOIN glbank on glbank.RowPointer = tmp_arpaypostbankrecon.glbank_RowPointer 
		WHERE
			ProcessId = @ProcessId 
			AND tmp_arpaypostbankrecon.bank_code = @BankCode 
			AND tmp_arpaypostbankrecon.type = @NewRecType
			and glbank.cust_check_num = @CheckNumber
			AND glbank.ref_num = @RefNum

END
ELSE
   SELECT 
      @CreateTempRec = 0,
      @Exists = 0,
      @ProcessId = NEWID()

-- If the GlBank record does not exist
IF @Exists = 0
BEGIN
	
	SET @GlBankRowPointer = NEWID()
	
   EXEC @Severity = GetNextReconciliationTypeNumSp
        @BankCode
      , @NewRecType
      , @Transaction OUTPUT

   IF @Severity <> 0
      GOTO EOF

   INSERT INTO glbank (
        RowPointer
      , bank_code
      , check_date 
      , post_date 
      , type 
      , check_num 
      , cust_check_num 
      , check_amt 
      , ref_type 
      , ref_num 
      , voided
      , bank_recon
      , bank_amt 
      , dom_check_amt
		, zla_third_party_check
		, zla_third_bank_id
		, zla_third_description
		, zla_third_tax_num_reg
		, zla_third_check_date
		, zla_pay_id
		, zla_credit_card_exp_date
		, zla_credit_card_payments
) 
   VALUES (
        @GlBankRowPointer
      , @BankCode
      , @CheckDate
      , dbo.GetSiteDate(getdate())
      , @NewRecType
      , @Transaction
      , @CheckNumber -- CJG 23/08/2011 CASE WHEN @Type = 'C' THEN @CheckNumber ELSE 0 END
      , CASE WHEN @BankCurrCode = @CustCurrCode THEN @CheckAmt ELSE @DomCheckAmt END 
      , @RefType
      , @RefNum
      , 0
      , 0
      , 0
      , @DomCheckAmt 
		, @ZlaThirdPartyCheck	
		, @ZlaThirdBankId			
		, @ZlaThirdDescription	
		, @ZlaThirdTaxNumReg		
		, @ZlaThirdCheckDate		
		, @ZlaArPayId
		, @ZlaCreditCardExpDate
		, @ZlaCreditCardPayments
)

   SET @Severity = @@ERROR
   IF @Severity <> 0
      GOTO EOF

   IF @CreateTempRec = 1
      INSERT INTO tmp_arpaypostbankrecon (ProcessId, bank_code, type, glbank_RowPointer) 
      VALUES (@ProcessId, @BankCode, @NewRecType, @GlBankRowPointer)


   SET @Severity = @@ERROR
END
ELSE -- If the GlBank record does exist
BEGIN
   -- Update the GlBank Reconciliation records for the same processid/bank/type, clearing the fields that do not make sence

		SELECT
			@GlBankRowPointer = tmp_arpaypostbankrecon.glbank_RowPointer
		FROM tmp_arpaypostbankrecon
		INNER JOIN glbank ON glbank.RowPointer = tmp_arpaypostbankrecon.glbank_RowPointer
		WHERE
		tmp_arpaypostbankrecon.ProcessId = @ProcessId
		AND tmp_arpaypostbankrecon.bank_code = @BankCode
		AND tmp_arpaypostbankrecon.type = @NewRecType
		AND glbank.cust_check_num = @CheckNumber
		AND glbank.ref_num = @RefNum

   UPDATE glbank 
      -- SET cust_check_num = 0
          SET check_amt = check_amt + CASE WHEN @BankCurrCode = @CustCurrCode THEN @CheckAmt ELSE @DomCheckAmt END
        -- ref_num = 0
          ,dom_check_amt = dom_check_amt + @DomCheckAmt
	FROM glbank 
   WHERE RowPointer = @GlBankRowPointer

   SET @Severity = @@ERROR
END

EOF:
RETURN @Severity
GO

