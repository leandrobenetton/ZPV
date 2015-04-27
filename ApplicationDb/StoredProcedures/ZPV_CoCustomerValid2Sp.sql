/****** Object:  StoredProcedure [dbo].[ZPV_CoCustomerValid2Sp]    Script Date: 10/29/2014 12:25:48 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CoCustomerValid2Sp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CoCustomerValid2Sp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CoCustomerValid2Sp]    Script Date: 10/29/2014 12:25:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/CoCustomerValid2Sp.sp 15    11/06/12 2:56a Ezhang1 $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/CoCustomerValid2Sp.sp $
 *
 * SL8.04 15 RS5421 Ezhang1 Tue Nov 06 02:56:51 2012
 * RS5421
 * Add a output parameter of shipmentapprovalrequired
 *
 * SL8.02 14 rs4588 Dahn Thu Mar 04 10:25:57 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 13 rs4588 Dahn Thu Mar 04 09:35:11 2010
 * RS4588 Copyright header changes
 *
 * SL8.01 12 rs3953 Vlitmano Wed Aug 27 11:02:29 2008
 * RS3953 - Changed a Copyright header?
 *
 * SL8.00 10 101988 Dahn Tue Sep 04 13:29:21 2007
 * SQL Objects Wording - Some SPs and Numerous Scalar- Valued Functions
 * Changed header's comment (file dbo.AcctChgSp) to "Copyright ? 2007 Infor Global Solutions Technology GmbH, and/or its affiliate and subsidiaries.  All rights reserved.  The word and design marks set forth herein are trademarks and/or registered trademarks of Infor Global Solutions Technology GmbH and/or its affiliate and subsidiaries.  All rights reserved.  All other trademarks listed herein are the property of their respective owners."
 *
 * SL8.00 9 98440 Hcl-chantar Mon Apr 02 01:49:27 2007
 * The customer number and sequence can be changed on a Customer Order after it has been shipped and invoiced
 * Issue # 98127
 * 1. Moved the changes of Fix 87928 from sp "CoGetOrderActivity" to sp "CoCustomerValid2Sp".
 * 2. Called the sp "CoGetOrderActivitySp" with @OldCustNum instead of @CustNum.
 *
 * SL8.00 8 rs2968 nkaleel Fri Feb 23 01:11:03 2007
 * changing copyright information
 *
 * SL8.00 7 RS2968 prahaladarao.hs Thu Jul 13 02:45:19 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL8.00 6 RS2968 prahaladarao.hs Tue Jul 11 05:24:09 2006
 * RS 2968
 * Name change CopyRight Update.
 *
 * SL7.05 5 91818 NThurn Fri Jan 06 14:26:25 2006
 * Inserted standard External Touch Point call.  (RS3177)
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_CoCustomerValid2Sp] (
  @CoNum            CoNumType
, @OldCustNum       CustNumType
, @RowPointer       RowPointerType
, @OrderDate        DateType
, @ExchRate         ExchRateType    OUTPUT
, @CustNum          CustNumType     OUTPUT
, @CustSeq          CustSeqType     OUTPUT
, @ShipmentExists   Flag            OUTPUT
, @BillToAddress    LongAddress     OUTPUT
, @ShipToAddress    LongAddress     OUTPUT
, @Contact          ContactType     OUTPUT
, @Phone            PhoneType       OUTPUT
, @BillToContact    ContactType     OUTPUT
, @BillToPhone      PhoneType       OUTPUT
, @ShipToContact    ContactType     OUTPUT
, @ShipToPhone      PhoneType       OUTPUT
, @CorpCust         CustNumType     OUTPUT
, @CorpCustName     NameType        OUTPUT
, @CorpCustContact  ContactType     OUTPUT
, @CorpCustPhone    PhoneType       OUTPUT
, @CorpAddress      Flag            OUTPUT
, @CurrCode         CurrCodeType    OUTPUT
, @UseExchRate      Flag            OUTPUT
, @Whse             WhseType        OUTPUT
, @ShipCode         ShipCodeType    OUTPUT
, @ShipCodeDesc     DescriptionType OUTPUT
, @ShipPartial      Flag            OUTPUT
, @ShipEarly        Flag            OUTPUT
, @Consolidate      Flag            OUTPUT
, @Summarize        Flag            OUTPUT
, @InvFreq          InvFreqType     OUTPUT
, @Einvoice         Flag            OUTPUT
, @TermsCode        TermsCodeType   OUTPUT
, @TermsCodeDesc    DescriptionType OUTPUT
, @Slsman           SlsmanType      OUTPUT
, @PriceCode        PriceCodeType   OUTPUT
, @PriceCodeDesc    DescriptionType OUTPUT
, @EndUserType      EndUserTypeType OUTPUT
, @EndUserTypeDesc  DescriptionType OUTPUT
, @ApsPullUp        Flag            OUTPUT
, @TaxCode1Type     LongListType
, @TaxCode1         TaxCodeType     OUTPUT
, @TaxDesc1         DescriptionType OUTPUT
, @TaxCode2Type     LongListType
, @TaxCode2         TaxCodeType     OUTPUT
, @TaxDesc2         DescriptionType OUTPUT
, @FrtTaxCode1Type  LongListType
, @FrtTaxCode1      TaxCodeType     OUTPUT
, @FrtTaxDesc1      DescriptionType OUTPUT
, @FrtTaxCode2Type  LongListType
, @FrtTaxCode2      TaxCodeType     OUTPUT
, @FrtTaxDesc2      DescriptionType OUTPUT
, @MiscTaxCode1Type LongListType
, @MiscTaxCode1     TaxCodeType     OUTPUT
, @MiscTaxDesc1     DescriptionType OUTPUT
, @MiscTaxCode2Type LongListType
, @MiscTaxCode2     TaxCodeType     OUTPUT
, @MiscTaxDesc2     DescriptionType OUTPUT
, @TransNat         TransNatType    OUTPUT
, @TransNat2        TransNat2Type   OUTPUT
, @Delterm          DelTermType     OUTPUT
, @ProcessInd       ProcessIndType  OUTPUT
, @CusLcrReqd       ListYesNoType   OUTPUT
, @CusUseExchRate   ListYesNoType   OUTPUT
, @OnCreditHold ListYesNoType output
, @Infobar          LongListType    OUTPUT
, @ShipmentApprovalRequired ListYesNoType OUTPUT
, @CusCustType		CustTypeType
)
AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_CoCustomerValid2Sp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_CoCustomerValid2Sp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @CoNum
         , @OldCustNum
         , @RowPointer
         , @OrderDate
         , @ExchRate OUTPUT
         , @CustNum OUTPUT
         , @CustSeq OUTPUT
         , @ShipmentExists OUTPUT
         , @BillToAddress OUTPUT
         , @ShipToAddress OUTPUT
         , @Contact OUTPUT
         , @Phone OUTPUT
         , @BillToContact OUTPUT
         , @BillToPhone OUTPUT
         , @ShipToContact OUTPUT
         , @ShipToPhone OUTPUT
         , @CorpCust OUTPUT
         , @CorpCustName OUTPUT
         , @CorpCustContact OUTPUT
         , @CorpCustPhone OUTPUT
         , @CorpAddress OUTPUT
         , @CurrCode OUTPUT
         , @UseExchRate OUTPUT
         , @Whse OUTPUT
         , @ShipCode OUTPUT
         , @ShipCodeDesc OUTPUT
         , @ShipPartial OUTPUT
         , @ShipEarly OUTPUT
         , @Consolidate OUTPUT
         , @Summarize OUTPUT
         , @InvFreq OUTPUT
         , @Einvoice OUTPUT
         , @TermsCode OUTPUT
         , @TermsCodeDesc OUTPUT
         , @Slsman OUTPUT
         , @PriceCode OUTPUT
         , @PriceCodeDesc OUTPUT
         , @EndUserType OUTPUT
         , @EndUserTypeDesc OUTPUT
         , @ApsPullUp OUTPUT
         , @TaxCode1Type
         , @TaxCode1 OUTPUT
         , @TaxDesc1 OUTPUT
         , @TaxCode2Type
         , @TaxCode2 OUTPUT
         , @TaxDesc2 OUTPUT
         , @FrtTaxCode1Type
         , @FrtTaxCode1 OUTPUT
         , @FrtTaxDesc1 OUTPUT
         , @FrtTaxCode2Type
         , @FrtTaxCode2 OUTPUT
         , @FrtTaxDesc2 OUTPUT
         , @MiscTaxCode1Type
         , @MiscTaxCode1 OUTPUT
         , @MiscTaxDesc1 OUTPUT
         , @MiscTaxCode2Type
         , @MiscTaxCode2 OUTPUT
         , @MiscTaxDesc2 OUTPUT
         , @TransNat OUTPUT
         , @TransNat2 OUTPUT
         , @Delterm OUTPUT
         , @ProcessInd OUTPUT
         , @CusLcrReqd OUTPUT
         , @CusUseExchRate OUTPUT
         , @OnCreditHold OUTPUT
         , @Infobar OUTPUT
         , @ShipmentApprovalRequired OUTPUT
         , @CusCustType OUTPUT
 
      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.
 
DECLARE
  @Severity INT
, @Message  LongListType
, @CustaddrCreditHold ListYesNoType
, @CustaddrCorpCred ListYesNoType
, @CorpCustCreditHold ListYesNoType
, @CoCustNum CustNumType
, @CoType    CoTypeType

EXEC @Severity = dbo.CoCustomerValidSp
  @CoNum          = @CoNum
, @OldCustNum     = @OldCustNum
, @RowPointer     = @RowPointer
, @CustNum        = @CustNum          OUTPUT
, @CustSeq        = @CustSeq          OUTPUT
, @ShipmentExists = @ShipmentExists   OUTPUT
, @BillToAddress  = @BillToAddress    OUTPUT
, @ShipToAddress  = @ShipToAddress    OUTPUT
, @Contact        = @Contact          OUTPUT
, @Phone          = @Phone            OUTPUT
, @BillToContact  = @BillToContact    OUTPUT
, @BillToPhone    = @BillToPhone      OUTPUT
, @ShipToContact  = @ShipToContact    OUTPUT
, @ShipToPhone    = @ShipToPhone      OUTPUT
, @CorpCust       = @CorpCust         OUTPUT
, @CorpCustName   = @CorpCustName     OUTPUT
, @CorpCustContact = @CorpCustContact OUTPUT
, @CorpCustPhone  = @CorpCustPhone    OUTPUT
, @CorpAddress    = @CorpAddress      OUTPUT
, @CurrCode       = @CurrCode         OUTPUT
, @UseExchRate    = @UseExchRate      OUTPUT
, @Whse           = @Whse             OUTPUT
, @ShipCode       = @ShipCode         OUTPUT
, @ShipCodeDesc   = @ShipCodeDesc     OUTPUT
, @ShipPartial    = @ShipPartial      OUTPUT
, @ShipEarly      = @ShipEarly        OUTPUT
, @Consolidate    = @Consolidate      OUTPUT
, @Summarize      = @Summarize        OUTPUT
, @InvFreq        = @InvFreq          OUTPUT
, @Einvoice       = @Einvoice         OUTPUT
, @TermsCode      = @TermsCode        OUTPUT
, @TermsCodeDesc  = @TermsCodeDesc    OUTPUT
, @Slsman         = @Slsman           OUTPUT
, @PriceCode      = @PriceCode        OUTPUT
, @PriceCodeDesc  = @PriceCodeDesc    OUTPUT
, @EndUserType    = @EndUserType      OUTPUT
, @EndUserTypeDesc = @EndUserTypeDesc OUTPUT
, @ApsPullUp      = @ApsPullUp        OUTPUT
, @TaxCode1       = @TaxCode1         OUTPUT
, @TaxCode2       = @TaxCode2         OUTPUT
, @TransNat       = @TransNat         OUTPUT
, @TransNat2      = @TransNat2        OUTPUT
, @Delterm        = @Delterm          OUTPUT
, @ProcessInd     = @ProcessInd       OUTPUT
, @Infobar        = @Infobar          OUTPUT
, @ShipmentApprovalRequired = @ShipmentApprovalRequired OUTPUT
IF @Severity <> 0
   RETURN @Severity

SELECT 
   @CoCustNum = cust_num
 , @CoType = type
FROM co
WHERE co_num = @CoNum

IF @CoCustNum <> @CustNum
BEGIN
   IF @CoType = 'R' AND EXISTS(SELECT * FROM coitem
                               WHERE co_num = @CoNum)
   BEGIN
      EXEC MsgAppSp @Infobar OUTPUT, 'I=WasCompareIsSet'
         , '@co.cust_num'
         , @CoCustNum
         , @CustNum
   
      EXEC MsgAppSp @Infobar OUTPUT, 'E=ExistFor'
         , '@coitem'
 
      EXEC MsgAppSp @Infobar OUTPUT, 'I=Adjust'
         , '@coitem'
   END
   ELSE IF @CoType = 'B' AND EXISTS(SELECT * FROM co_bln
                                    WHERE co_num = @CoNum) 
   BEGIN
      EXEC MsgAppSp @Infobar OUTPUT, 'I=WasCompareIsSet'
         , '@co.cust_num'
         , @CoCustNum
         , @CustNum
   
      EXEC MsgAppSp @Infobar OUTPUT, 'E=ExistFor'
         , '@co_bln'

      EXEC MsgAppSp @Infobar OUTPUT, 'I=Adjust'
         , '@co_bln'
 
      IF EXISTS(SELECT * FROM coitem
                WHERE co_num = @CoNum)
         EXEC MsgAppSp @Infobar OUTPUT, 'I=Adjust'
            , '@coitem'
   END
   
END

EXEC @Severity = dbo.CoGetOrderActivitySp
  @PCoNum   = @CoNum
, @PCustNum = @OldCustNum
, @Infobar  = @Infobar OUTPUT

IF @Severity <> 0
BEGIN
   RETURN @Severity
END

EXEC @Severity = dbo.UpdateOrderExchRateSp
  @CurrCode  = @CurrCode
, @OrderDate = @OrderDate
, @ExchRate  = @ExchRate OUTPUT
, @Infobar   = @Infobar  OUTPUT

IF @Severity <> 0
   RETURN @Severity

--  If the tax description for the input tax type can't be found, then
-- the tax code is not returned.
IF @TaxCode1 IS NOT NULL
BEGIN
   SELECT
     @TaxDesc1 = tc.description
   FROM taxcode AS tc
   WHERE tc.tax_system = 1
   AND   tc.tax_code = @TaxCode1
   AND   CHARINDEX(tc.tax_code_type, @TaxCode1Type) > 0
   IF @@ROWCOUNT <> 1
      SET @TaxCode1 = NULL
END
IF @TaxCode2 IS NOT NULL
BEGIN
   SELECT
     @TaxDesc2 = tc.description
   FROM taxcode AS tc
   WHERE tc.tax_system = 2
   AND   tc.tax_code = @TaxCode2
   AND   CHARINDEX(tc.tax_code_type, @TaxCode2Type) > 0
   IF @@ROWCOUNT <> 1
      SET @TaxCode2 = NULL
END

IF @FrtTaxCode1 IS NOT NULL
BEGIN
   SELECT
     @FrtTaxDesc1 = tc.description
   FROM taxcode AS tc
   WHERE tc.tax_system = 1
   AND   tc.tax_code = @FrtTaxCode1
   AND   CHARINDEX(tc.tax_code_type, @FrtTaxCode1Type) > 0
   IF @@ROWCOUNT <> 1
      SET @FrtTaxCode1 = NULL
END
IF @FrtTaxCode2 IS NOT NULL
BEGIN
   SELECT
     @FrtTaxDesc2 = tc.description
   FROM taxcode AS tc
   WHERE tc.tax_system = 2
   AND   tc.tax_code = @FrtTaxCode2
   AND   CHARINDEX(tc.tax_code_type, @FrtTaxCode2Type) > 0
   IF @@ROWCOUNT <> 1
      SET @FrtTaxCode2 = NULL
END

IF @MiscTaxCode1 IS NOT NULL
BEGIN
   SELECT
     @MiscTaxDesc1 = tc.description
   FROM taxcode AS tc
   WHERE tc.tax_system = 1
   AND   tc.tax_code = @MiscTaxCode1
   AND   CHARINDEX(tc.tax_code_type, @MiscTaxCode1Type) > 0
   IF @@ROWCOUNT <> 1
      SET @MiscTaxCode1 = NULL
END
IF @MiscTaxCode2 IS NOT NULL
BEGIN
   SELECT
     @MiscTaxDesc2 = tc.description
   FROM taxcode AS tc
   WHERE tc.tax_system = 2
   AND   tc.tax_code = @MiscTaxCode2
   AND   CHARINDEX(tc.tax_code_type, @MiscTaxCode2Type) > 0
   IF @@ROWCOUNT <> 1
      SET @MiscTaxCode2 = NULL
END

SELECT
  @CusLcrReqd     = cus.lcr_reqd
, @CusUseExchRate = cus.use_exch_rate
FROM customer AS cus
WHERE cus.cust_num = @CustNum
AND   cus.cust_seq = @CustSeq

-- determine if the customer is on credit hold
SELECT
  @CustaddrCreditHold = custaddr.credit_hold
, @CustaddrCorpCred = custaddr.corp_cred
FROM custaddr
WHERE custaddr.cust_num = @CustNum
AND   custaddr.cust_seq = @CustSeq

if @CustaddrCorpCred = 1 and @CorpCust is not null
   select
     @CorpCustCreditHold = custaddr.credit_hold
   from custaddr
   where custaddr.cust_num = @CorpCust
   and custaddr.cust_seq = 0

set @OnCreditHold = case when @CorpCust is not null and @CustaddrCorpCred = 1 and @CustaddrCreditHold = 0
   then @CorpCustCreditHold
   else @CustaddrCreditHold
   end

select @CusCustType = customer.cust_type from customer where customer.cust_num = @CustNum and customer.cust_seq = @CustSeq

RETURN 0

GO

