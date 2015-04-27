/****** Object:  StoredProcedure [dbo].[ZPV_InvoicingBGSp]    Script Date: 10/29/2014 12:28:20 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_InvoicingBGSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_InvoicingBGSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_InvoicingBGSp]    Script Date: 10/29/2014 12:28:20 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/ZLA_InvoicingBGSp.sp 49    9/18/13 12:16p Cajones $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/ZLA_InvoicingBGSp.sp $
 *
 * SL8.04 49 168966 Cajones Wed Sep 18 12:16:39 2013
 * Reprinting Consolidated Invoices when submitted through Doc-Trak
 * Issue 168966
 * Added the following code above the exec of EXTLCDTConsolidateInvoicingSessionIDSp for the Lake Company:
 * 	IF @InvoiceType = 'C'
 * 	BEGIN
 * 		IF @Mode = 'Reprint'
 * 		BEGIN
 * 			SET @PrintMode = 'Reprint'
 * 		END
 * 	END
 *
 * SL8.04 48 163558 calagappan Wed Sep 18 11:51:26 2013
 * Order Invoicing in the bacground does not increment invoice date
 * Validate invoice date whether it falls within specified range for the requesting user
 *
 * SL8.04 47 164226 Lchen3 Wed Jun 26 03:27:44 2013
 * When reprinting a consolidated invoice and the Use Profile is not checked the output is blank.
 * issue 164226
 * do not force PrintMode to be PROCESS for Consolidated Invoices when use profile unchecked.
 *
 * SL8.04 45 161888 calagappan Tue May 14 10:19:23 2013
 * Consolidated invoicing fails when invoicing customers with more than one Invoice Category.
 * Pass in generated lower and higher consolidated invoice numbers correctly to profile procedure
 *
 * SL8.04 44 158677 pgross Thu Mar 28 12:42:55 2013
 * Reprint of Consolidated Invoice is Blank
 * do not force PrintMode to be PROCESS for Consolidated Invoices
 *
 * SL8.04 43 RS4615 jzhou Thu Mar 07 04:56:48 2013
 * RS4615:
 * Remove  extra call of CloseSessionContextSp
 *
 * SL8.04 42 RS4615 jzhou Mon Mar 04 04:07:45 2013
 * RS4615:
 * Replace with InitSessionContextWithUserSp
 * Replace CloseSessionSp with CloseSessionContextSp
 *
 * SL8.04 41 RS2775 exia Wed Feb 20 04:07:00 2013
 * RS2775 
 * Add input parameters and passed into other SPs
 *
 * SL8.04 40 158507 Cajones Wed Feb 13 12:16:10 2013
 * Order Invoicing Credit Memo working with Customer Categories
 * Issue 158507
 * Made 02/11/2013 changes per the Lake Company:
 * - Added code to define the variable LCDTProcessID
 * - Modified if statement to check for nulls in one of the comparing values.
 *
 * SL8.04 39 RS4615 Lliu Fri Jan 18 00:15:30 2013
 * RS4615: Add parameter @site for InitSessionContextSp.
 *
 * SL8.04 38 156737 calagappan Fri Dec 28 17:30:37 2012
 * Invoicing runs were now producing several thousands (close to 70k) of print and reprint requests.
 * Print only those newly created documents during specific run based on appropriate document profiles
 *
 * SL8.04 37 154829 calagappan Wed Nov 14 13:43:39 2012
 * Invoices for incorrect shipto's are being emailed when using Custoemr Document Profiles
 * Send invoices based on Destination set up in Customer Document Profiles
 *
 * SL8.04 36 RS5857 Bbai Mon Oct 29 06:41:55 2012
 * RS5857:
 * Add a parameter InvoiceTypeJP for BG Task Parms.
 *
 * SL8.04 35 RS5566 Cliu Fri Oct 19 01:49:25 2012
 * Call IsAddonAvailable function (rather than checking for the existence of a CCI table) to determine whether to call the CCI SP.
 * RS5566
 *
 * SL8.04 34 153149 Ddeng Wed Sep 19 02:18:00 2012
 * When generating multiple RMA credit memos at one time, only the first one prints.
 * Issue 153149: Assign the last invoice number to @SubStartingInvNum when no user profile is used.
 *
 * SL8.04 33 RS5200 jzhou Fri Aug 24 02:01:38 2012
 * RS5200:
 * Add parameter '@PrintItemOverview'.
 *
 * SL8.04 32 150800 Djackson Sun Jul 15 09:50:03 2012
 * No consolidated invoice is generated
 * 150800 - Consolidated Invoices failing when shipment_id is null not Pick\Pack\and ship
 *
 * SL8.03 31 148119 Ltaylor2 Tue May 15 12:45:27 2012
 * 5325 - Pack and Ship design coding
 * Added start/end shipment_id parameters, pass them to ProfileConsolidatedInvSp and ConInvPostSp
 *
 * SL8.03 30 147042 Cajones Mon Feb 13 11:42:14 2012
 * Add a new Doc-Trak stub to the ZLA_InvoicingBGSp stored procedure
 * Issue 147042
 * Made changes for Doc-Trak per The Lake Company.
 *
 * SL8.03 29 145640 Cajones Mon Dec 19 11:30:06 2011
 * Doc-Trak new stub to the ZLA_InvoicingBGSp stored procedure
 * Issue 145640
 * Maded changes per Lake Company request
 *
 * SL8.03 28 144592 calagappan Mon Nov 14 12:10:29 2011
 * Blank invoices are generated when there is a language code is populated on customer and ship to.
 * Pass language code based on Bill To Customer to report SP
 *
 * SL8.03 27 140007 calagappan Tue Aug 09 10:48:36 2011
 * When generating invoices from Order Invoicing Credit Memo, the date format appears incorrectly.
 * obtain and pass current culture to display invoices
 *
 * SL8.03 26 138941 calagappan Wed Jun 15 16:00:21 2011
 * RMA Credit Memo creates a separate PDF for each invoice
 * launch separate RMA Credit Memos only when customer’s language changes
 *
 * SL8.03 25 138140 calagappan Tue Jun 14 16:55:12 2011
 * The value of CreatedBy on ARINV table is always 'sa' despite the record is created by non sa user
 * use username who submitted task in CreateBy and UpdatedBy columns
 *
 * SL8.03 24 139231 calagappan Mon Jun 13 10:30:43 2011
 * Note added to RMA header does not print on RMA Credit Memo.
 * Pass in correct parameter to print RMA notes on RMA credit memo
 *
 * SL8.03 23 RS4768 Xliang Fri Jun 03 04:41:54 2011
 * RS4768: add ‘Print Lot Numbers? option
 *
 * SL8.03 22 RS5172 calagappan Thu May 12 17:34:07 2011
 * RS 5172 ?Process document profiles for Consolidated Invoices
 *
 * SL8.03 21 135547 calagappan Fri Jan 21 16:47:21 2011
 * Notes added to Customer Order Line do not print on Price Adjustment Invoice
 * Pass Ending Customer number parameter for Adjustment Invoice
 *
 * SL8.03 20 133785 Cajones Wed Nov 17 13:46:26 2010
 * When printing invoices for the first time, on task parameter, the string shows  RBP, REPRINT.
 * Issue 133785
 * Added @Mode to the passed in parameters which should hold either PROCESS/REPRINT.
 * Modified code to use new @Mode when building the @BGTaskParms when @InvoiceType = 'O'
 *
 * SL8.03 19 132415 Cajones Wed Sep 22 11:28:11 2010
 * ZLA_InvoicingBGSp.sql is missing stub for plus products from The Lake Companies
 * Issue 132415
 * Modified stub code per Lake Company
 *
 * SL8.03 18 132770 calagappan Thu Sep 16 15:39:59 2010
 * Printing a range of consolidated invoices creates mutliple pdf files with multiple invoices in each pdf file
 * Do not submit duplicate BG Task for consolidated invoices
 *
 * SL8.03 17 132415 Cajones Wed Aug 18 15:26:59 2010
 * ZLA_InvoicingBGSp.sql is missing stub for plus products from The Lake Companies
 * Issue 132415
 * Added code stubs for The Lake Companies
 *
 * SL8.02 16 131215 flagatta Fri Jun 11 16:23:47 2010
 * Invoicing task errors in background
 * 1.) Fixed a typo on a Cursor fetch (was InvCusror but s/b InvCursor). 2.) Removed unnecessary @@RowCount check on the InvCursor cursor definition.131215
 *
 * SL8.02 15 130187 Cajones Fri Jun 11 10:58:31 2010
 * Blank Invoice records are sent from Order Invoicing for Customers with EDI profile when print invoices is not checked.
 * Issue 130187
 * Added Close/Deallocate for InvCursor and BGTaskCursor
 * Also added various comments to help in future debugging.
 *
 * SL8.02 14 130896 Kbotley Tue Jun 08 13:59:34 2010
 * I18N - Invoice printout does not translate the numbers, currency, dates, and language
 * 130896 - Provided the Language Code to BGTask parms when printing via a Customer Doc Profile. If the Customer Doc Profile is non-active or doesn't exist provided for standard printing of the report.
 *
 * SL8.02 13 130917 Kbotley Mon Jun 07 17:04:54 2010
 * Invoice will not print if a Language code is selected on the Customers form
 * 130917 - Pulling correct Language codes/IDs when invoicing without customer document profile. Print flag is being set correctly based on return value of 0 sent back if no invoice is posted.
 *
 * SL8.02 12 130915 Djackson Thu Jun 03 15:09:32 2010
 * Reprint does not honor the specified data
 * 130915 - Change BG process to print invoice groups based on customer a change in customer has a new BG Task for printing.  Simmilar behavior to the reprint of the invoices.
 *
 * SL8.02 10 129972 flagatta Wed May 05 10:24:46 2010
 * Implement a Single Source hook into ZLA_InvoicingBGSp
 * Added a hook for Single Source's Credit Card Interface.  129972
 *
 * SL8.02 9 129544 Djackson Thu Apr 29 15:01:16 2010
 * When invoicing multiple COs at the same time, an individual task and report is created for each
 * 129544 - Price Adjustment - customer profile - @startinvnum and @endinvnum
 *
 * SL8.02 8 129544 Djackson Thu Apr 29 11:02:39 2010
 * When invoicing multiple COs at the same time, an individual task and report is created for each
 * 129544 - Customer Profile
 *
 * SL8.02 7 129402 Djackson Thu Apr 22 10:26:54 2010
 * Incorrect error reporting
 * 129402 - Remove code that reset error message
 *
 * SL8.02 6 129402 Djackson Thu Apr 22 09:58:11 2010
 * Incorrect error reporting
 * 129402 - Changed conditional from <> 0 to if @Severity < 0
 *
 * SL8.02 5 129408 Djackson Wed Apr 21 13:36:23 2010
 * Error in the BG Task History when processing an Order Invoicing/Credit Memo
 * 129408 - Null profile causes error
 *
 * SL8.02 4 RS2825 Djackson Wed Mar 24 10:58:45 2010
 * RS2825 - Invoicing Multi User
 *
 * SL8.02 2 RS2825 Djackson Mon Mar 15 08:57:05 2010
 * RS 2825 Invoicing Multi User
 *
 * SL8.02 1 RS2825 Djackson Sun Mar 14 14:19:26 2010
 * RS2825 Invoicing Multi User
 *
 * $NoKeywords: $
 */

CREATE PROCEDURE [dbo].[ZPV_InvoicingBGSp]
(
@SessionID                      RowpointerType
, @InvoiceType                  NVARCHAR(1)
, @BGTaskName                   BGTaskNameType
, @InvType                      NVARCHAR(10)    = 'R'
, @InvCred                      NCHAR(1)        = 'I'
, @InvDate                      DateType        = NULL
, @StartCustomer                CustNumType     = NULL
, @EndCustomer                  CustNumType     = NULL
, @StartOrderNum                CoNumType       = NULL
, @EndOrderNum                  CoNumType       = NULL
, @StartLine                    CoLineType      = NULL
, @EndLine                      CoLineType      = NULL
, @StartRelease                 CoReleaseType   = NULL
, @EndRelease                   CoReleaseType   = NULL
, @StartLastShipDate            DateType        = NULL
, @EndLastShipDate              DateType        = NULL
, @StartPackNum                 PackNumType     = NULL
, @EndPackNum                   PackNumType     = NULL
, @CreateFromPackSlip           ListYesNoType   = 0
, @pMooreForms                  NVARCHAR(1)     = 'N'
, @pNonDraftCust                ListYesNoType   = 0
, @SelectedStartInvNum          InvNumType      = NULL
, @CheckShipItemActiveFlag      ListYesNoType   = 0
, @StartInvNum                  InvNumType      = ''   OUTPUT
, @EndInvNum                    InvNumType      = ''   OUTPUT
, @PrintItemCustomerItem        NVARCHAR(2)     = 'CI'        -- I
, @TransToDomCurr               ListYesNoType   = 0
, @PrintSerialNumbers           ListYesNoType   = 1
, @PrintPlanItemMaterial        ListYesNOTYPE   = 0
, @PrintConfigurationDetail     NVARCHAR(1)     = 'N'         -- A or N
, @PrintEuro                    ListYesNoType   = 0
, @PrintCustomerNotes           ListYesNoType   = 1
, @PrintOrderNotes              ListYesNoType   = 1
, @PrintOrderLineNotes          ListYesNoType   = 1
, @PrintOrderBlanketLineNotes   ListYesNoType   = 1
, @PrintProgressiveBillingNotes ListYesNoType   = 0
, @PrintInternalNotes           ListYesNoType   = 1
, @PrintExternalNotes           ListYesNoType   = 1
, @PrintItemOverview            ListYesNoType   = 0
, @DisplayHeader                ListYesNoType   = 1
, @PrintLineReleaseDescription  ListYesNoType   = 1
, @PrintStandardOrderText       ListYesNoType   = 1
, @PrintBillToNotes             ListYesNoType   = 1
, @LangCode                     LangCodeType    = NULL -- @StartLangCode
, @PrintDiscountAmt             ListYesNoType   = 0    -- @PrintTermsDiscAmtVar
, @BatchId                      BatchIdType     = NULL
, @BGSessionId                  NVARCHAR(255)   = NULL
, @UserId                       TokenType       = NULL
, @Infobar                      InfobarType     = NULL  OUTPUT
, @LCRVar                       ListYesNoType   = NULL
, @pBegDoNum                    DoNumType       = NULL
, @pEndDoNum                    DoNumType       = NULL
, @pBegCustPo                   CustPoType      = NULL
, @pEndCustPo                   CustPoType      = NULL
, @DoHdrList                    LongListType    = NULL OUTPUT
, @PItemTypeCust                ListYesNoType   = NULL
, @PItemTypeItem                ListYesNoType   = NULL
, @PrintConInvReport            ListYesNoType   = NULL OUTPUT
, @PInvNum                      InvNumType      = NULL
, @POrderNums                   ListYesNoType   = NULL
, @PMiscCharges                 AmountType      = NULL
, @PSalesTax                    AmountType      = NULL
, @PFreight                     AmountType      = NULL
, @TCustPT                      CustPayTypeType = NULL
, @PApplyToInvNum               InvNumType      = NULL
, @TOpt                         NCHAR(1)        = NULL
, @UseProfile                   ListYesNoType   = NULL
, @Mode                         NVARCHAR(20)    = 'PROCESS' -- REPRINT/PROCESS
, @PrintLotNumbers              ListYesNoType   = 1
, @StartInvDate                 DateType        = NULL -- ReprintStartInvDate
, @EndInvDate                   DateType        = NULL -- ReprintEndInvDate
, @CurrentCultureName           LanguageIDType  = NULL
, @StartingShipment             ShipmentIdType  = NULL
, @EndingShipment               ShipmentIdType  = NULL
, @InvoiceTypeJP                InvoiceTypeType = 'S'
, @CalledFrom                   InfobarType     = NULL -- can be InvoiceBuilder or NULL           
, @InvoicBuilderProcessID       RowpointerType  = NULL
, @ZlaArTypeId				  ZlaArTypeIdType	= NULL
)
AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_InvoicingBGSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_InvoicingBGSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @SessionID
         , @InvoiceType
         , @BGTaskName
         , @InvType
         , @InvCred
         , @InvDate
         , @StartCustomer
         , @EndCustomer
         , @StartOrderNum
         , @EndOrderNum
         , @StartLine
         , @EndLine
         , @StartRelease
         , @EndRelease
         , @StartLastShipDate
         , @EndLastShipDate
         , @StartPackNum
         , @EndPackNum
         , @CreateFromPackSlip
         , @pMooreForms
         , @pNonDraftCust
         , @SelectedStartInvNum
         , @CheckShipItemActiveFlag
         , @StartInvNum OUTPUT
         , @EndInvNum OUTPUT
         , @PrintItemCustomerItem
         , @TransToDomCurr
         , @PrintSerialNumbers
         , @PrintPlanItemMaterial
         , @PrintConfigurationDetail
         , @PrintEuro
         , @PrintCustomerNotes
         , @PrintOrderNotes
         , @PrintOrderLineNotes
         , @PrintOrderBlanketLineNotes
         , @PrintProgressiveBillingNotes
         , @PrintInternalNotes
         , @PrintExternalNotes
         , @PrintItemOverview 
         , @DisplayHeader
         , @PrintLineReleaseDescription
         , @PrintStandardOrderText
         , @PrintBillToNotes
         , @LangCode
         , @PrintDiscountAmt
         , @BatchId
         , @BGSessionId
         , @UserId
         , @Infobar OUTPUT
         , @LCRVar
         , @pBegDoNum
         , @pEndDoNum
         , @pBegCustPo
         , @pEndCustPo
         , @DoHdrList OUTPUT
         , @PItemTypeCust
         , @PItemTypeItem
         , @PrintConInvReport OUTPUT
         , @PInvNum
         , @POrderNums
         , @PMiscCharges
         , @PSalesTax
         , @PFreight
         , @TCustPT
         , @PApplyToInvNum
         , @TOpt
         , @UseProfile
         , @Mode
         , @PrintLotNumbers
         , @StartInvDate
         , @EndInvDate
         , @CurrentCultureName
         , @StartingShipment
         , @EndingShipment
         , @InvoiceTypeJP
         , @CalledFrom
         , @InvoicBuilderProcessID
		 , @ZlaArTypeId

      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.
 
DECLARE
  @RequestingUser       UsernameType
, @UsingExistingSession ListYesNoType

SELECT @RequestingUser = username
FROM UserNames WHERE UserId = @UserId

DECLARE
  @Severity INT
, @xInfobar       InfobarType
, @BGTaskParms    BGTaskParmsType
, @BGTaskID       TokenType
, @SpSessionID    RowPointerType
, @ProcessID      RowPointerType
, @PrintInv       ListYesNoType
, @LockedType     NCHAR(1)
, @InvNum         InvNumType
, @OldInvNum         InvNumType
, @InvSeq         InvSeqType
, @DoNum          DoNumType
, @DoHdrInfo      LongListType
, @DoLineInfo     LongListType
, @BGStringTable  BGTaskParmsType
, @Destination    DestinationType
, @ProfileLangCode    LangCodeType
, @FaxNumber          DestinationType
, @Email              DestinationType
, @NumCopies          CopiesType
, @Printer            DestinationType
, @CoverSheetContact  ContactType
, @CoverSheetCompany  NameType
, @ProfileMethod      OutputMethodType
, @ProfileCustNum     CustNumType
, @ProfileDestination DestinationType
, @ProfileInvNum      InvNumType
, @DocProfileExists   ListYesNoType
, @PrevDocProfileExists      ListYesNoType
, @Method                    OutputMethodType
, @Resource                  SYSNAME
, @SubStartingInvNum         InvNumType
, @SubEndingInvNum           InvNumType
, @InvNum1                   InvNumType
, @InvNum2                   InvNumType
, @RowPointer                RowPointerType
, @CustNum                   CustNumType
, @OldCustNum                CustNumType
, @StringTable               BGTaskParmsType
, @END                       INT
, @PrintMode                 NVARCHAR(20)
, @PrevLangCode              LangCodeType

DECLARE
  @LowCharacter  HighLowCharType
, @HighCharacter HighLowCharType
, @Site          SiteType   

DECLARE @PrintProfile AS TABLE
( InvNum             InvNumType
, CustNum            CustNumType
, LangCode           LangCodeType
, DocProfileCustomer ListYesNoType
, Method             OutputMethodType
, Destination        DestinationType
, NumCopies          CopiesType
, CoverSheetCompany  NameType
, CoverSheetContact  ContactType
)

-- populated only by Price Adjustment Invoice profile SP
DECLARE @PrintProfilePriceAdjInv AS TABLE
( LangCode           LangCodeType
, DocProfileCustomer ListYesNoType
, Method             OutputMethodType
, Destination        DestinationType
, NumCopies          CopiesType
, CoverSheetContact  ContactType
, CoverSheetCompany  NameType
, AlternateSessionID RowPointerType
)

DECLARE @BGTask AS TABLE
( TaskName          BGTaskNameType
, TaskParms1        BGTaskParmsType
, TaskParms2        BGTaskParmsType
, StringTable       BGTaskParmsType
, SubStartingInvNum InvNumType
, SubEndingInvNum   InvNumType
, LangCode          LangCodeType
, RowPointer        RowPointerType
, PrintMode         NVARCHAR(20)
)

-- try to re-use an existing license
IF @RequestingUser IS NOT NULL
   SELECT @SpSessionID = ConnectionID
   FROM ConnectionInformation WITH (READUNCOMMITTED)
   WHERE UserName = @RequestingUser

SET @UsingExistingSession = CASE WHEN @RequestingUser IS NOT NULL AND @SpSessionID IS NULL THEN 0 ELSE 1 END
SET @Site = dbo.ParmsSite()

EXEC dbo.InitSessionContextSp
     @ContextName = 'InvoicingBGSp'
   , @SessionID   = @SpSessionID OUTPUT
   , @Site        = @Site

IF @UsingExistingSession = 0
   EXEC dbo.InitSessionContextWithUserSp
        @ContextName = 'InvoicingBGSp'
      , @Username    = @RequestingUser
      , @SessionID   = @SpSessionID
      , @Site        = @Site 

 /*
====================
Lake Companies, Inc.
====================
Get the Lake Company Parameters
*/
DECLARE
  @SpName           SYSNAME
, @LCDTTypeEnabled  TINYINT      --Determine if DT Exists and Enabled for @InvoiceType
, @LUseLakeProfile  TINYINT
, @LCDTInvType      NVARCHAR(1)  --Translation between SL Type and DT Type
, @LCDTRef          NVARCHAR(30) --Needed to help declare Temp Table
, @LCDTFirstProf    TINYINT
, @LCDTInvNum		InvNumType
, @LCDTHeldSessionID UniqueIdentifier

SET @LCDTHeldSessionID = @SessionID

IF OBJECT_ID('dbo.EXTLCDTInvoicingEnabledSP') IS NOT NULL
BEGIN
   SET @SpName = 'dbo.EXTLCDTInvoicingEnabledSP'
   EXEC @Severity = @SpName
		@InvoiceType
	   ,@RequestingUser
	   ,@LCDTInvType OUTPUT
	   ,@LCDTTypeEnabled OUTPUT

   IF @Severity <> 0
      RETURN @Severity		
      
IF OBJECT_ID('dbo.EXTLCDTInvoicingRMADocProfileExistSP') IS NOT NULL  and @LCDTTypeEnabled = 1
	BEGIN  
	   SET @SpName = 'dbo.EXTLCDTInvoicingRMADocProfileExistSP'  
	   EXEC @Severity = @SpName  
	     @InvoiceType  
	 	,@LUseLakeProfile OUTPUT 
	 
	  
  		 IF @Severity <> 0  
     	 RETURN @Severity    
	END  
         
END  
ELSE --CHECK FOR DT SP FAILED.  Doc-Trak Not Installed
   SET @LCDTTypeEnabled = 0

SELECT 	@InvNum			AS InvNum		
	,@LCDTRef			AS Ref1
	,@LCDTRef			AS Ref2
	,@LCDTRef			AS Ref3
	,@ProfileMethod		AS Method
	,@Destination		AS Destination
	,@ProfileLangCode	AS Lang
	,@NumCopies			AS NumCopies
	,@CoverSheetContact	AS CoverSheetContact
	,@CoverSheetCompany	AS CoverSheetCompany
	,@LCDTTypeEnabled	AS FirstProf
INTO #LCDTDocProf		
WHERE 1=2

/*
End modification.
====================
Lake Companies, Inc.
====================
*/


-- ZLA 
IF @InvCred = 'C'
EXECUTE [DefineVariableSp] 
   'ZlaArTypeId'
  ,@ZlaArTypeId
  ,@Infobar OUTPUT
-- ZLA End
ELSE 
	SET @ZlaArTypeId = NULL
SET @LowCharacter  = dbo.LowCharacter()
SET @HighCharacter = dbo.HighCharacter()
SET @Mode          = LTRIM(RTRIM(ISNULL(@Mode, 'PROCESS')))
SET @InvDate       = dbo.MidnightOf(@InvDate)
SET @StartInvDate  = ISNULL(dbo.MidnightOf(@StartInvDate), dbo.LowDate())
SET @EndInvDate    = ISNULL(dbo.DayEndOf(@EndInvDate), dbo.HighDate())

IF @Mode = 'PROCESS'
BEGIN
   BEGIN TRAN --Lock out the inv_sequence table to prevent projects from breaking the sequence numbers -- WAIT TIME in milliseconds
   SET @Resource = 'inv_sequence.last_inv_num'
   EXEC @Severity  =  sp_getapplock @Resource = @Resource, @LockMode = 'Exclusive', @LockTimeout = 100000
   IF @Severity < 0
   BEGIN
     SET @Resource = 'E=AppLockFail' + CAST ( ABS(@Severity) AS nvarchar)
     EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, @Resource
     GOTO ERROR_FUNCT
   END
END -- IF @Mode = 'PROCESS'

SET @PrintInv = 0
SET @Severity = 0

IF @Mode = 'PROCESS'
BEGIN
   IF @InvoiceType = 'O' -- 'Order Invoicing Credit/Memo
   BEGIN
      EXEC @Severity = dbo.DateChkSp
           @PDate         = @InvDate
         , @FieldLabel    = '@inv_hdr.inv_date'
         , @FunctionLabel = NULL
         , @Infobar       = @Infobar  OUTPUT
         , @PromptMsg     = @xInfobar OUTPUT
         , @PromptButtons = @xInfobar OUTPUT

      IF @Severity <> 0
        GOTO ERROR_FUNCT

      EXEC @Severity = dbo.ZPV_Co10RSp
             @InvType
            ,@InvCred
            ,@InvDate
            ,@StartCustomer
            ,@EndCustomer
            ,@StartOrderNum
            ,@EndOrderNum
            ,@StartLine
            ,@EndLine
            ,@StartRelease
            ,@EndRelease
            ,@StartLastShipDate
            ,@EndLastShipDate
            ,@StartPackNum
            ,@EndPackNum
            ,@CreateFromPackSlip
            ,@pMooreForms
            ,@pNonDraftCust
            ,@SelectedStartInvNum
            ,@CheckShipItemActiveFlag
            ,@StartInvNum             OUTPUT
            ,@EndInvNum               OUTPUT
            ,@Infobar                 OUTPUT
            ,@BatchId
            ,@ProcessID               OUTPUT
            ,@CalledFrom              = @CalledFrom
            ,@InvoicBuilderProcessID  = @InvoicBuilderProcessID
            
      IF @Severity <> 0
        GOTO ERROR_FUNCT
      ELSE COMMIT

      IF NOT (@StartInvNum IS NULL OR @EndInvNum IS NULL OR @StartInvNum = '0' OR @EndInvNum = '0')
      BEGIN

         --SSS START: Credit Card Interface
         IF dbo.IsAddonAvailable('SyteLineCCI') = 1
         BEGIN
            IF OBJECT_ID('dbo.SSSCCIPayInvoicesSp') IS NOT NULL
            BEGIN
               DECLARE @SSSCCI_SpName Sysname
               SET @SSSCCI_SpName = 'dbo.SSSCCIPayInvoicesSp'	
               EXEC @SSSCCI_SpName
                   @StartInvNum
                 , @EndInvNum
                 , @Infobar OUTPUT
            END
         END   
         --SSS Finish

         SET @PrintInv = 1
      END -- IF NOT (@StartInvNum IS NULL OR @EndInvNum IS NULL OR @StartInvNum = '0' OR @EndInvNum = '0')
   END -- IF @InvoiceType = 'O'
  ELSE IF @InvoiceType = 'R' -- RMA Credit Memo
  BEGIN
    DECLARE
    @BCrmDate DATETIMETYPE
    , @ECrmDate DATETIMETYPE
    , @TNewInvoice LongListType

    Exec @Severity = dbo.ZLA_CrmPostSp
         @TNewInvoice        = @TNewInvoice
       , @TCrmDate           = @InvDate
       , @TTransDomCurr      = @TransToDomCurr
       , @BRmaNum            = @StartOrderNum
       , @ERmaNum            = @EndOrderNum
       , @BRmaLine           = @StartLine
       , @ERmaLine           = @EndLine
       , @BCustNum           = @StartCustomer
       , @ECustNum           = @EndCustomer
       , @BLastReturnDate    = @StartLastShipDate
       , @ELastReturnDate    = @EndLastShipDate
       , @BCrmNum            = @StartInvNum       OUTPUT
       , @ECrmNum            = @EndInvNum         OUTPUT
       , @BCrmDate           = @BCrmDate          OUTPUT
       , @ECrmDate           = @ECrmDate          OUTPUT
       , @PrintOrderNotes    = @PrintOrderNotes
       , @PrintRMANotes      = @PrintOrderBlanketLineNotes
       , @PrintShipToNotes   = @PrintStandardOrderText
       , @PrintBillToNotes   = @PrintBillToNotes
       , @PrintInternalNotes = @PrintInternalNotes
       , @PrintExternalNotes = @PrintExternalNotes
       , @PrintRMALineNotes  = @PrintOrderLineNotes
       , @Infobar            = @Infobar           OUTPUT
       , @ProcessId          = @ProcessID         OUTPUT
    IF @Severity <> 0
      GOTO ERROR_FUNCT
    ELSE COMMIT
    IF NOT (@StartInvNum IS NULL OR @EndInvNum IS NULL OR @StartInvNum = '0' OR @EndInvNum = '0')
      SET @PrintInv = 1
  END -- IF @InvoiceType = 'R' -- RMA Credit Memo
  ELSE IF @InvoiceType = 'C' -- Consolidating Invoice
  BEGIN
    Exec @Severity = dbo.ConInvPostSp
         @SessionId         = @SessionID
       , @PInvNum           = @PInvNum                              --
       , @PInvDate          = @InvDate                              --
       , @PStartCustNum     = @StartCustomer                        --
       , @PEndCustNum       = @EndCustomer                          --
       , @PStartDoNum       = @pBegDoNum                            --
       , @PEndDoNum         = @pEndDoNum                            --
       , @PStartCustPoNum   = @pBegCustPo                           --
       , @PEndCustPoNum     = @pEndCustPo                           --
       , @PMooreForm        = @pMooreForms                          --
       , @PInclNonDraft     = @pNonDraftCust                        --
       , @PLCR              = @LCRVar                               --
       , @POrderNums        = @POrderNums                           --
       , @PEuroTotal        = @PrintEuro                            --
       , @PTransToDom       = @TransToDomCurr                       --
       , @PSerialNums       = @PrintSerialNumbers                   --
       , @PPlanItemMats     = @PrintPlanItemMaterial                --
       , @PConfigDetails    = @PrintConfigurationDetail             --
       , @PItemTypeItem     = @PItemTypeItem                        --
       , @PItemTypeCust     = @PItemTypeCust                        --
       , @PBillToText       = @PrintBillToNotes                     --
       , @PStdOrderText     = @PrintStandardOrderText               --
       , @PLineRelText      = @PrintLineReleaseDescription          --
       , @StartInvNum       = @StartInvNum         OUTPUT           --
       , @EndInvNum         = @EndInvNum           OUTPUT           --
       , @Infobar           = @Infobar             OUTPUT           --
       , @DoHdrList         = @DoHdrList           OUTPUT           --
       , @PrintConInvReport = @PrintConInvReport   OUTPUT           --
       , @PStartingShipment = @StartingShipment                     --
       , @PEndingShipment   = @EndingShipment                       --


    IF @Severity <> 0
      GOTO ERROR_FUNCT
    ELSE COMMIT

    ------ UkExportInterface-------------------------
    IF NOT (@StartInvNum IS NULL OR @EndInvNum IS NULL OR @StartInvNum = '0' OR @EndInvNum = '0')
    BEGIN
      DECLARE InvCursor CURSOR LOCAL STATIC FOR
      SELECT inv_num
         , inv_seq
         , do_num
        FROM inv_hdr inv
        JOIN custaddr cu ON cu.cust_num = inv.cust_num
        JOIN country  co ON co.country = cu.country
       WHERE NOT (exp_doc_reqd IS NULL OR exp_doc_reqd = 0 )
         AND inv.Inv_num BETWEEN ISNULL(@StartInvNum, inv.Inv_num)
                               AND ISNULL (@EndInvNum, inv.Inv_num)

      OPEN InvCursor
        WHILE @Severity = 0
        BEGIN
          FETCH InvCursor INTO
                @InvNum
              , @InvSeq
              , @DoNum
          IF @@FETCH_STATUS = -1
            BREAK

          SET @DoHdrInfo = ''
          SET @DoLineInfo = ''

          EXEC  @Severity = dbo.ExtInterfaceDoInfoSp
                @DoNum
              , @InvNum
              , @InvSeq
              , @DoHdrInfo   OUTPUT
              , @DoLineInfo  OUTPUT

          SET @BGTaskParms = @DoNum + ',''' + @DoHdrInfo + ''',''' +  @DoLineInfo + ''''
          EXEC @Severity        = dbo.BGTaskSubmitSp
               @TaskName        = 'UkExportInterface'
             , @TaskParms1      = @BGTaskParms
             , @TaskParms2      = NULL
             , @Infobar         = @Infobar   OUTPUT
             , @TaskID          = @BGTaskID  OUTPUT
             , @TaskStatusCode  = 'READY'
             , @StringTable     = NULL
             , @RequestingUser  = @RequestingUser
          IF @Severity <> 0
            GOTO ERROR_FUNCT
        END -- WHILE @Severity = 0
      CLOSE InvCursor
      DEALLOCATE InvCursor

      IF @PrintConInvReport = 1 -- Print Invoice Flag
         SET @PrintInv = 1

    END

  END -- IF @InvoiceType = 'C' -- Consolidating Invoice

  ELSE IF @InvoiceType = 'A' -- Price Adjustment only one price adjustment per task
  BEGIN
    DECLARE  @PPrintFlag          ListYesNoType
           , @TAcctError          ListYesNoType

    Exec @Severity              = dbo.InvPostASp
       @PRecIdCo                = @StartOrderNum
      ,@PMiscCharges            = @PMiscCharges
      ,@PSalesTax               = @PSalesTax
      ,@PFreight                = @PFreight
      ,@PDest                   = 0
      ,@PInvOrCm                = 0
      ,@PNonDraftCust           = @pNonDraftCust
      ,@PProgBillText           = @PrintProgressiveBillingNotes
      ,@PLineRelText            = @PrintOrderLineNotes
      ,@PPlanItemMtls           = @PrintPlanItemMaterial
      ,@PLCR                    = @LCRVar
      ,@PSerNums                = @PrintSerialNumbers
      ,@PConfDets               = @PrintConfigurationDetail
      ,@PPRTVals                = 0
      ,@POrdNums                = @POrderNums
      ,@PTransToDomCur          = @TransToDomCurr
      ,@PEuroTotal              = @PrintEuro
      ,@PInvNum                 = @PInvNum      OUTPUT
      ,@PInvDate                = @InvDate
      ,@PCustNumStart           = @StartCustomer
      ,@PCustNumEnd             = @EndCustomer
      ,@PCoNumStart             = @StartOrderNum
      ,@PCoNumEnd               = @EndOrderNum
      ,@PLastShipDateStart      = @StartLastShipDate
      ,@PLastShipDateEnd        = @EndLastShipDate
      ,@PDoNumStart             = @pBegDoNum
      ,@PDoNumEnd               = @pEndDoNum
      ,@PCustPOStart            = @pBegCustPo
      ,@PCustPOEnd              = @pEndCustPo
      ,@PInvNumRepStart         = @PInvNum
      ,@PInvNumRepEnd           = @PInvNum
      ,@PInvDateRepStart        = ''--
      ,@PInvDateRepEnd          = ''
      ,@PItemTypeItem           = @PItemTypeItem
      ,@PItemTypeCust           = @PItemTypeCust
      ,@PTextOrd                = @PrintOrderNotes
      ,@PTextStandOrd           = @PrintStandardOrderText
      ,@PTextCustMast           = @PrintCustomerNotes
      ,@PTextBillTo             = @PrintBillToNotes
      ,@PTextNone               = 0
      ,@TOpt                    = @TOpt
      ,@TDispFLine              = 0
      ,@TDispFInv               = 0
      ,@TCustPT                 = @TCustPT
      ,@TInvStart               = @StartInvNum
      ,@TInvEnd                 = @EndInvNum
      ,@PPrintFlag              = @PPrintFlag   output
      ,@TAcctError              = @TAcctError   output
      ,@Infobar                 = @Infobar      output
      ,@pProcessId              = @SessionID
      ,@PApplyToInvNum          = @PApplyToInvNum

    ----delete temporary records from tt_inv_adj
    DECLARE @TempTable AS TABLE
    (
    co_num       CoNumType
    , co_line    CoLineType
    , co_release CoReleaseType
    )
    INSERT INTO @TempTable
    SELECT DISTINCT
      co_num
    , co_line
    , co_release
      FROM tt_inv_adj
     WHERE SessionID = @SessionID

    DELETE tt_inv_adj
      FROM tt_inv_adj ttadj
      JOIN @TempTable tt ON ttadj.co_num = tt.co_num
                      AND ttadj.co_line = tt.co_line
                      AND ttadj.co_release = tt.co_release
    -- THIS should not be needed -- not deleting records
    DELETE tt_inv_adj
      FROM tt_inv_adj
     WHERE SessionID = @SessionID

    --Delete from the TT_Tax_Dist table
    DELETE
      FROM TT_Tax_Dist
     WHERE SessionID = @SessionID

    IF @Severity <> 0
      GOTO ERROR_FUNCT
    ELSE COMMIT

    IF NOT (@PInvNum IS NULL OR @PInvNum = '0')
    BEGIN
      SET @PrintInv = 1
      SET @StartInvNum = @PInvNum
      SET @EndInvNum    = @PInvNum
    END
  END -- IF @InvoiceType = 'A' -- Price Adjustment only one price adjustment per task
END -- IF @Mode = 'PROCESS'
IF @Mode = 'REPRINT'
    SET @PrintInv = 1

-- Print the invoice -- customer doc profile

IF @PrintInv = 1
BEGIN
   IF @UseProfile = 1
   OR (@LCDTTypeEnabled = 1 and  (@LUseLakeProfile = 1)) --LAKE  There is No use Profile on RMA Invoicing /******  Lake Companies, Inc.  ******/  
   BEGIN
      SET @CustNum = ''
      SET @RowPointer = newid()
      /*
      ====================
      Lake Companies, Inc.
      ====================
      */
      SET @InvNum = '' --NEW CONTROL BREAK FIELD
      SET @LCDTFirstProf = 1

      DECLARE @LCDTUseLakProf as TINYINT
      IF OBJECT_ID('EXTLCDTProfileInvoicingSp') IS NOT NULL
      BEGIN
         IF @InvoiceType IN (SELECT INVTYPE from dbo.EXTLCDTUseProfileTypesFN())
            SET @LCDTUseLakProf = 1		
         Else
            SET @LCDTUseLakProf = 0
      END
      ELSE
         SET @LCDTUseLakProf = 0		

      IF OBJECT_ID('EXTLCDTProfileInvoicingSp') IS NOT NULL AND @LCDTTypeEnabled = 1 AND @LCDTUseLakProf = 1
      BEGIN
		 /*
		 ====================
		 Begin Part 1 of 2 02/11/2013 modification.
		 Lake Companies, Inc.
		 ====================
		 */
	     EXEC DefineVariableSp 'LCDTProcessID', @ProcessID, NULL
         /*
		 ====================
		 End Part 1 of 2 02/11/2013 modification.
		 Lake Companies, Inc.
		 ====================
		 */            
         SET @SpName = 'dbo.EXTLCDTProfileInvoicingSp'
         INSERT INTO @PrintProfile
         EXEC @Severity = @SpName
                          @LCDTInvType
                        , @StartInvNum
                        , @EndInvNum
      
         IF @Severity <> 0
            RETURN @Severity
      END
      ELSE
      /*
      End modification.
      ====================
      Lake Companies, Inc.
      ====================
      */
      BEGIN -- if above ext SP is not available
         IF @InvoiceType = 'C'
         BEGIN
            SET @InvNum1 = @StartInvNum
            SET @InvNum2 = @EndInvNum

            IF @Mode = 'PROCESS'
            BEGIN
               SET @InvNum2 = dbo.MaxInvNum(@StartInvNum, @EndInvNum)
               SET @InvNum1 = CASE WHEN @InvNum2 = @StartInvNum THEN @EndInvNum
                                   ELSE @StartInvNum
                              END
               SET @StartInvDate = @InvDate
               SET @EndInvDate   = @InvDate                              
            END

            INSERT INTO @PrintProfile
            EXEC dbo.ProfileConsolidatedInvSp
                 @StartCustNum = @StartCustomer
               , @EndCustNum   = @EndCustomer
               , @StartDoNum   = @pBegDoNum
               , @EndDoNum     = @pEndDoNum
               , @StartInvNum  = @InvNum1
               , @EndInvNum    = @InvNum2
               , @StartInvDate = @StartInvDate
               , @EndInvDate   = @EndInvDate
               , @StartShipment = @StartingShipment
               , @EndShipment   = @EndingShipment
               , @CalledFrom   = @Mode /* PROCESS or REPRINT */
               , @ProcessID    = @SessionID
         END -- IF @InvoiceType = 'C'
         ELSE IF @InvoiceType = 'O'
         BEGIN   
            INSERT INTO @PrintProfile
            EXEC dbo.ProfileOrderInvoicingSp
                 @StartInvNum = @StartInvNum
               , @EndInvNum   = @EndInvNum
               , @CalledFrom  = 'POST'
               , @ProcessID   = @ProcessID
         END -- IF @InvoiceType = 'O'
         ELSE IF @InvoiceType = 'A'
         BEGIN   
            INSERT INTO @PrintProfilePriceAdjInv
            EXEC dbo.ProfilePriceAdjustmentSp 
                 @CoNum = @StartOrderNum

            INSERT INTO @PrintProfile
            SELECT   
              @StartInvNum
            , @StartCustomer
            , LangCode
            , DocProfileCustomer
            , Method
            , Destination
            , NumCopies
            , CoverSheetCompany
            , CoverSheetContact
            FROM @PrintProfilePriceAdjInv      
         END -- IF @InvoiceType = 'A'
      END
      
      SET @InvNum               = NULL
      SET @CustNum              = NULL
      SET @LangCode             = NULL
      SET @PrevDocProfileExists = NULL
      SET @Destination          = NULL
      SET @Method               = NULL

      DECLARE PProfile CURSOR LOCAL STATIC FOR
      SELECT 
        LangCode
      , CASE WHEN Method = 'F' THEN Destination ELSE '' END -- FaxNumber
      , CASE WHEN Method = 'E' THEN Destination ELSE '' END -- Email
      , CASE WHEN Method = 'P' THEN Destination ELSE '' END -- Printer
      , NumCopies
      , CoverSheetContact
      , CoverSheetCompany
      , Method -- ProfileMethod
      , CustNum -- ProfileCustNum
      , Destination -- ProfileDestination
      , InvNum -- ProfileInvNum
      , DocProfileCustomer
      FROM @PrintProfile

      OPEN PProfile
      WHILE @Severity = 0
      BEGIN
         FETCH PProfile INTO
           @ProfileLangCode
         , @FaxNumber
         , @Email
         , @Printer
         , @NumCopies
         , @CoverSheetContact
         , @CoverSheetCompany
         , @ProfileMethod
         , @ProfileCustNum
         , @ProfileDestination
         , @ProfileInvNum
         , @DocProfileExists
         IF @@FETCH_STATUS = -1
            BREAK

         /*
         ====================
         Lake Companies, Inc.
         ====================
         */
         IF @LCDTTypeEnabled = 1 --DT Use Profile
         BEGIN
			/*
			====================
			Begin Part 2 of 2 02/11/2013 modification.
			Lake Companies, Inc.
			====================
			*/   
            IF @ProfileInvNum != ISNULL(@InvNum, '') --CONTROL BREAK ON EACH INV_NUM WHEN DT ENABLED
            BEGIN
			/*
			====================
			End Part 2 of 2 02/11/2013 modification.
			Lake Companies, Inc.
			====================
			*/   
               IF NOT (@ProfileMethod IS NULL OR @ProfileMethod = '')
               BEGIN
                  SET @LangCode = ISNULL(@ProfileLangCode ,'')
                  SET @BGStringTable = ISNULL(@ProfileLangCode ,'') + ',,,,,,,'
               END -- IF NOT (@ProfileMethod IS NULL OR @ProfileMethod = '')
               ELSE
               BEGIN
                  SET @LangCode = (select lang_code from customer WITH (NOLOCK) where customer.cust_num = @ProfileCustNum  and customer.cust_seq = 0)
                  SET @BGStringTable = ISNULL(@LangCode ,'') + ',,,,,,,'
               END

               SET @PrintMode = 'PROCESS'
               SET @RowPointer = NEWID()
               SET @LCDTFirstProf = 1

               INSERT INTO @BGTask (SubStartingInvNum, SubEndingInvNum, StringTable, LangCode, RowPointer, PrintMode)
               VALUES (@ProfileInvNum, @ProfileInvNum, @BGStringTable, @LangCode, @RowPointer, @PrintMode)

               SET @CustNum     = @ProfileCustNum
               SET @Destination = @ProfileDestination
            END -- IF @ProfileInvNum != @InvNum
            ELSE
            BEGIN
               SET @LCDTFirstProf = 0
            END

            IF OBJECT_ID('dbo.EXTLCDTInvoicingLoadDocProfileSp') IS NOT NULL AND @LCDTTypeEnabled = 1
            BEGIN
               SET @SpName = 'dbo.EXTLCDTInvoicingLoadDocProfileSp'
               EXEC @Severity = @SpName
                    @InvoiceType
                  , @ProfileInvNum
                  , @LCDTFirstProf
                  , @ProfileMethod
                  , @ProfileDestination
                  , @LangCode
                  , @NumCopies
                  , @CoverSheetContact
                  , @CoverSheetCompany
                  , @InvNum OUTPUT

               IF @Severity <> 0
                  RETURN @Severity
            END
         END --END DT Use Profile
         ELSE
         BEGIN --SL Standard Use Profile
         /*
         End modification.
         ====================
         Lake Companies, Inc.
         ====================
         */
            IF ISNULL(@ProfileInvNum, '') <> ISNULL(@InvNum, '')
            BEGIN -- PROCESS
               if @InvoiceType != 'C'
                  SET @PrintMode = 'PROCESS'
               SET @ProfileLangCode = ISNULL(@ProfileLangCode, '')
               SET @BGStringTable = ISNULL((SELECT LanguageID FROM LanguageIDs WHERE LanguageCode = @ProfileLangCode), @CurrentCultureName)
                                    + ',' + ISNULL(@FaxNumber,'')
                                    + ',' + ISNULL(@Email, '')
                                    + ',' + ISNULL(CAST(@NumCopies AS NVARCHAR(4)), '1')
                                    + ',' + ISNULL(@Printer, '')
                                    + ',' + ISNULL(@CoverSheetContact, '')
                                    + ',' + '' --FaxTemplate
                                    + ',' + ISNULL(@CoverSheetCompany, '')

               SET @RowPointer = NEWID()

               INSERT INTO @BGTask (SubStartingInvNum, SubEndingInvNum, StringTable, LangCode, RowPointer, PrintMode)
               VALUES (@ProfileInvNum, @ProfileInvNum, @BGStringTable, @ProfileLangCode, @RowPointer, @PrintMode)
               
               SET @InvNum               = @ProfileInvNum
               SET @CustNum              = @ProfileCustNum
               SET @LangCode             = @ProfileLangCode
               SET @PrevDocProfileExists = @DocProfileExists
               SET @Destination          = @ProfileDestination
               SET @Method               = @ProfileMethod

            END -- PROCESS
            ELSE
            BEGIN -- REPRINT
               SET @PrintMode = 'REPRINT'
            
               IF ISNULL(@ProfileCustNum, '') <> ISNULL(@CustNum, '')
               OR ISNULL(@ProfileLangCode, '') <> ISNULL(@LangCode, '')
               OR ISNULL(@DocProfileExists, 0) <> ISNULL(@PrevDocProfileExists, 0)
               OR ISNULL(@ProfileDestination, '') <> ISNULL(@Destination, '')
               OR ISNULL(@ProfileMethod, '') <> ISNULL(@Method, '')
               BEGIN
                  SET @ProfileLangCode = ISNULL(@ProfileLangCode, '')
                  SET @BGStringTable = ISNULL((SELECT LanguageID FROM LanguageIDs WHERE LanguageCode = @ProfileLangCode), @CurrentCultureName)         
                                    + ',' + ISNULL(@FaxNumber,'')
                                    + ',' + ISNULL(@Email, '')
                                    + ',' + ISNULL(CAST(@NumCopies AS NVARCHAR(4)), '1')
                                    + ',' + ISNULL(@Printer, '')
                                    + ',' + ISNULL(@CoverSheetContact, '')
                                    + ',' + '' --FaxTemplate
                                    + ',' + ISNULL(@CoverSheetCompany, '')

                  SET @RowPointer = NEWID()

                  INSERT INTO @BGTask (SubStartingInvNum, SubEndingInvNum, StringTable, LangCode, RowPointer, PrintMode)
                  VALUES (@ProfileInvNum, @ProfileInvNum, @BGStringTable, @ProfileLangCode, @RowPointer, @PrintMode)

                  SET @InvNum               = @ProfileInvNum
                  SET @CustNum              = @ProfileCustNum
                  SET @LangCode             = @ProfileLangCode
                  SET @PrevDocProfileExists = @DocProfileExists
                  SET @Destination          = @ProfileDestination
                  SET @Method               = @ProfileMethod
               END -- IF ISNULL(@ProfileCustNum, '') <> ISNULL(@CustNum, '')
               ELSE
                  UPDATE @BGTask
                  SET SubEndingInvNum = @ProfileInvNum
                  WHERE RowPointer = @RowPointer
            END -- REPRINT
         END -- SL Standard Use Profile
      END -- WHILE @Severity = 0 (Next Profile)
      CLOSE PProfile
      DEALLOCATE PProfile
   END -- IF @UseProfile = 1
   ELSE --@UseProfile = 0 not using the customer doc profile
   BEGIN
  	    /*
	    ====================
	    Lake Companies, Inc.
	    ====================
	    */
	    SET @LCDTInvNum = '' --NEW CONTROL BREAK FIELD
	    /*
	    ====================
	    Lake Companies, Inc.
	    ====================
	    */
      IF @InvoiceType = 'C'
      BEGIN
         SET @InvNum1 = @StartInvNum
         SET @InvNum2 = @EndInvNum

         IF @Mode = 'PROCESS'
         BEGIN
            SET @InvNum2 = dbo.MaxInvNum(@StartInvNum, @EndInvNum)
            SET @InvNum1 = CASE WHEN @InvNum2 = @StartInvNum THEN @EndInvNum
                                ELSE @StartInvNum
                           END
            SET @StartInvDate = @InvDate
            SET @EndInvDate   = @InvDate                              
         END
         
         INSERT INTO @PrintProfile
         EXEC dbo.ProfileConsolidatedInvSp
              @StartCustNum = @StartCustomer
            , @EndCustNum   = @EndCustomer
            , @StartDoNum   = @pBegDoNum
            , @EndDoNum     = @pEndDoNum
            , @StartInvNum  = @InvNum1
            , @EndInvNum    = @InvNum2
            , @StartInvDate = @StartInvDate
            , @EndInvDate   = @EndInvDate
            , @StartShipment = @StartingShipment
            , @EndShipment   = @EndingShipment
            , @CalledFrom   = @Mode /* PROCESS or REPRINT */
            , @ProcessID    = @SessionID
      END -- IF @InvoiceType = 'C'
      ELSE IF @InvoiceType = 'O'
      BEGIN   
         INSERT INTO @PrintProfile
         EXEC dbo.ProfileOrderInvoicingSp
              @StartInvNum = @StartInvNum
            , @EndInvNum   = @EndInvNum
            , @CalledFrom  = 'POST'
            , @ProcessID   = @ProcessID
      END -- IF @InvoiceType = 'O'
      ELSE IF @InvoiceType = 'A'
      BEGIN   
         INSERT INTO @PrintProfilePriceAdjInv
         EXEC dbo.ProfilePriceAdjustmentSp 
              @CoNum = @StartOrderNum

         INSERT INTO @PrintProfile
         SELECT   
           @StartInvNum
         , @StartCustomer
         , LangCode
         , DocProfileCustomer
         , Method
         , Destination
         , NumCopies
         , CoverSheetCompany
         , CoverSheetContact
         FROM @PrintProfilePriceAdjInv      
      END -- IF @InvoiceType = 'A'
      ELSE IF @InvoiceType = 'R'
      BEGIN   
         INSERT INTO @PrintProfile (InvNum, CustNum, LangCode)
         EXEC dbo.ProfileRMACreditMemoSp
              @BCrmNum  = @StartInvNum
            , @ECrmNum  = @EndInvNum
            , @BCrmDate = @BCrmDate
            , @ECrmDate = @ECrmDate
      END -- IF @InvoiceType = 'R'

      DECLARE InvCursor CURSOR LOCAL STATIC FOR
      SELECT
        InvNum
      , CustNum
      , LangCode
      FROM @PrintProfile

      OPEN InvCursor
      FETCH InvCursor INTO
        @OldInvNum
      , @OldCustNum
      , @LangCode

      SET @PrevLangCode = @LangCode

      SET @BGStringTable = ISNULL((select LanguageID from LanguageIDs where LanguageCode = @PrevLangCode), @CurrentCultureName)
                           + ',' + ISNULL(@FaxNumber,'')
                           + ',' + ISNULL(@Email, '')
                           + ',' + ISNULL(CAST(@NumCopies AS NVARCHAR(4)), '1')
                           + ',' + ISNULL(@Printer, '')
                           + ',' + ISNULL(@CoverSheetContact, '')
                           + ',' + '' --FaxTemplate
                           + ',' + ISNULL(@CoverSheetCompany, '')

      IF @Mode = 'PROCESS'
      BEGIN
         SET @SubStartingInvNum = @StartInvNum
         IF @@FETCH_STATUS = -1
            SET @SubEndingInvNum   = @EndInvNum
         ELSE 
            SET @SubEndingInvNum = @StartInvNum
      END
      ELSE
      BEGIN
         SET @SubStartingInvNum = @OldInvNum
         SET @SubEndingInvNum   = @OldInvNum
      END

      WHILE @Severity = 0
      BEGIN --break by change in customer number
         FETCH InvCursor INTO
           @InvNum
         , @CustNum
         , @LangCode

         IF @@FETCH_STATUS = -1
            SET @END = 1

         IF ( (CHARINDEX(@InvoiceType, 'COA') <> 0) AND ( (@OldCustNum <> @CustNum) OR (ISNULL(@PrevLangCode, '') <> ISNULL(@LangCode, '')) ) )
         OR ( (CHARINDEX(@InvoiceType, 'R') <> 0) AND (ISNULL(@PrevLangCode, '') <> ISNULL(@LangCode, '')) )
         OR @END = 1
         OR (@LCDTTypeEnabled = 1 AND @LCDTInvNum <> @SubStartingInvNum) --LAKE-- CONTROL BREAK ON InvNum /******  Lake Companies, Inc.  ******/
         BEGIN
            IF @InvoiceType != 'C'         
               SET @PrintMode = 'PROCESS'
               
            SET @RowPointer = NEWID()
            INSERT INTO @BGTask (SubStartingInvNum, SubEndingInvNum, StringTable, LangCode, RowPointer, PrintMode)
            VALUES (@SubStartingInvNum, @SubEndingInvNum, @BGStringTable, @PrevLangCode, @RowPointer, @PrintMode)
            /*
            ====================
            Lake Companies, Inc.
            ====================
            */
            IF OBJECT_ID('dbo.EXTLCDTInvoicingLoadDocProfileSp') IS NOT NULL AND @LCDTTypeEnabled = 1
            BEGIN		
               SET @SpName = 'dbo.EXTLCDTInvoicingLoadDocProfileSp'
               EXEC @Severity = @SpName
                               @InvoiceType
                              ,@SubStartingInvNum
                              ,1
                              ,''
                              ,''
                              ,''
                              ,1
                              ,''
                              ,''
                              ,@LCDTInvNum OUTPUT
               IF @Severity <> 0
               RETURN @Severity
            END
            /*
            End modification.
            ====================
            Lake Companies, Inc.
            ====================
            */
            IF ISNULL (@InvNum, '' ) <> ''
            BEGIN
               SET @SubStartingInvNum = @InvNum
               SET @SubEndingInvNum = @InvNum

               SET @BGStringTable = ISNULL((select LanguageID from LanguageIDs where LanguageCode = @LangCode), @CurrentCultureName)
                                    + ',' + ISNULL(@FaxNumber,'')
                                    + ',' + ISNULL(@Email, '')
                                    + ',' + ISNULL(CAST(@NumCopies AS NVARCHAR(4)), '1')
                                    + ',' + ISNULL(@Printer, '')
                                    + ',' + ISNULL(@CoverSheetContact, '')
                                    + ',' + '' --FaxTemplate
                                    + ',' + ISNULL(@CoverSheetCompany, '')
            END

            IF @END = 1
               BREAK

            SET @SubStartingInvNum = @InvNum
            SET @OldCustNum = @CustNum
            SET @PrevLangCode = @LangCode
         END
         SET @SubEndingInvNum = @InvNum
      END
      CLOSE InvCursor
      DEALLOCATE InvCursor

   END --@UseProfile = 0 not using the customer doc profile

  DECLARE BGTaskCursor CURSOR LOCAL STATIC FOR
  SELECT
    SubStartingInvNum
  , SubEndingInvNum
  , StringTable
  , LangCode
  , PrintMode
  FROM @BGTask

  OPEN BGTaskCursor
  WHILE @Severity = 0
  BEGIN
    FETCH BGTaskCursor INTO
      @SubStartingInvNum
    , @SubEndingInvNum
    , @StringTable
    , @LangCode
    , @PrintMode

    IF @@FETCH_STATUS = -1
      BREAK

    SET @BGTaskParms = NULL
    /*
	====================
	Lake Companies, Inc.
	====================
	*/
	
	IF @InvoiceType = 'C'
	BEGIN
		IF @Mode = 'Reprint'
		BEGIN
			SET @PrintMode = 'Reprint'
		END
	END
		
	IF OBJECT_ID('EXTLCDTConsolidateInvoicingSessionIDSp') IS NOT NULL and (@InvoiceType = 'C' and @LCDTTypeEnabled = 1 )
	BEGIN
	   SET @SpName = 'dbo.EXTLCDTConsolidateInvoicingSessionIDSp'
			EXEC @Severity = @SpName
				@SubStartingInvNum,
				@SessionID OUTPUT
			
			IF @Severity <> 0
	 		RETURN @Severity
    END	
  	/*
	End modification.
	====================
	Lake Companies, Inc.
	====================
	*/

      IF @InvoiceType = 'O'
        SET @BGTaskParms = ISNULL(CAST(@ProcessID AS NVARCHAR(36)),'')  --ISNULL(CAST(@SessionID AS NVARCHAR(36)),'')
                   + ',' + ISNULL(CAST(@InvType AS NVARCHAR(4)),'')
                   + ',' + ISNULL(@PrintMode,'PROCESS')
                   + ',' + ISNULL(@SubStartingInvNum, '')
                   + ',' + ISNULL(@SubEndingInvNum, '')
                   + ',' + '' --ISNULL(@StartOrderNum, '')
                   + ',' + '' --ISNULL(@EndOrderNum, '')
                   + ',' + '' --ISNULL(CAST (@InvDate AS NVARCHAR(30)), '')           --@StartReprintInvDate = @InvDate
                   + ',' + '' --ISNULL(CAST (@InvDate AS NVARCHAR(30)), '')           --@EndReprintInvDate   = @InvDate
                   + ',' + '' --ISNULL(@StartCustomer, '')
                   + ',' + '' --ISNULL(@EndCustomer, '')
                   + ',' + ISNULL(CAST (@PrintItemCustomerItem AS NVARCHAR(2)), '')
                   + ',' + ISNULL(CAST (@TransToDomCurr AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@InvCred AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintSerialNumbers AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintPlanItemMaterial AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintConfigurationDetail AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintEuro AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintCustomerNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintOrderNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintOrderLineNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintOrderBlanketLineNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintProgressiveBillingNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintInternalNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintExternalNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintItemOverview AS NVARCHAR(1)), '')            --@PrintItemOverview
                   + ',' + ISNULL(CAST (@DisplayHeader AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintLineReleaseDescription AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintStandardOrderText AS NVARCHAR(1)), '')
                   + ',' + ISNULL(CAST (@PrintBillToNotes AS NVARCHAR(1)), '')
                   + ',' + ISNULL(@LangCode, '')
                   + ',' + ISNULL(CAST (@BGSessionID AS NVARCHAR(36)), '')
                   + ',' + ISNULL(CAST (@PrintDiscountAmt AS NVARCHAR(1)), '')  --@PrintTermsDiscAmtVar = @PrintDiscountAmt   --
                   + ',' + ISNULL(CAST(@PrintLotNumbers AS NVARCHAR(1)),'')
                   + ',' + ISNULL(CAST(@InvoiceTypeJP AS NVARCHAR(1)),'')

      IF @InvoiceType = 'R'
        --- @BGTaskName  = 'RMACreditMemoLaser' --'EXTFRRMACreditMemo'
        SET @BGTaskParms = ISNULL(CAST(@ProcessID AS NVARCHAR(36)), '')
               + ',' + 'P'
               + ',' + ISNULL(CAST (@PrintItemCustomerItem AS NVARCHAR(2)), '')    --@PrintItemCustItem
               + ',' + ISNULL(CAST (@PrintSerialNumbers AS NVARCHAR(1)), '')       --@IncludeSerialNumbers
               + ',' + ISNULL(CAST (@TransToDomCurr AS NVARCHAR(1)),'')            --@TranslateToDomesticCurrency
               + ',' + ISNULL(@SubStartingInvNum, '')                               --
               + ',' + ISNULL(@SubEndingInvNum, '')                               --
               + ',' + ''                                                             --@StartCreditMemoDate
               + ',' + ''                                                             --@EndCreditMemoDate
               + ',' + ISNULL(CAST(@PrintOrderNotes AS NVARCHAR(1)), '')              --@PrintOrderNotes
               + ',' + ISNULL(CAST(@PrintOrderBlanketLineNotes AS NVARCHAR(1)), '')   --@PrintRMANotes
               + ',' + ISNULL(CAST(@PrintStandardOrderText AS NVARCHAR(1)), '')       --@PrintShipToNotes
               + ',' + ISNULL(CAST(@PrintBillToNotes AS NVARCHAR(1)), '')             --@PrintBillToNotes
               + ',' + ISNULL(CAST(@PrintInternalNotes  AS NVARCHAR(1)), '')          --@PrintInternalNotes
               + ',' + ISNULL(CAST(@PrintExternalNotes AS NVARCHAR(1)), '')           --@PrintExternalNotes
               + ',' + ISNULL(CAST(@PrintItemOverview AS NVARCHAR(1)), '')            --@PrintItemOverview
               + ',' + ISNULL(CAST(@PrintOrderLineNotes AS NVARCHAR(1)), '')          --@PrintRMALineNotes
               + ',' + ISNULL(CAST(@PrintLotNumbers AS NVARCHAR(1)),'')               --@PrintLotNumbers      END

      IF @InvoiceType = 'C'
      -- @BGTaskName  = ConsolidatedInvoicingDraft      --ConsolidatedInvoicingLaser
      --       French = EXTFRConsolidatedInvoicingDraft --EXTFRConsolidatedInvoicing
        SET @BGTaskParms = ISNULL(CAST(@SessionID AS NVARCHAR(36)), '')
                 + ',' + ISNULL(@PrintMode,'REPRINT')
                 + ',' + ISNULL(@StartCustomer, '')                                   --@StartingCustVar
                 + ',' + ISNULL(@EndCustomer, '')                                     --@EndingCustVar
                 + ',' + ISNULL(@pBegDoNum, '')                                       --@StartingDOVar
                 + ',' + ISNULL(@pEndDoNum, '')                                       --@EndingDOVar
                 + ',' + ISNULL(@pBegCustPo, '')                                      --@StartingPOVar
                 + ',' + ISNULL(@pEndCustPo, '')                                      --@EndingPOVar
                 + ',' + ISNULL(@SubStartingInvNum, '')                               --@ReprintStartInvNum
                 + ',' + ISNULL(@SubEndingInvNum, '')                                 --@ReprintEndInvNum
                 + ',' + '' --@ReprintStartInvDate
                 + ',' + '' --@ReprintEndInvDate
                 + ',' + ISNULL(@PrintItemCustomerItem, 'CI')                         --@PrintItemType
                 + ',' + 'I'
                 + ',' + ISNULL(CAST(@PrintConfigurationDetail AS NVARCHAR(1)),'')    --@ConfigurationDetailsVar
                 + ',' + 'RB'
                 + ',' + ISNULL(CAST(@PrintEuro AS NVARCHAR(1)),'')                   --@PrintEuroTotalVar
                 + ',' + ISNULL(CAST(@TransToDomCurr AS NVARCHAR(1)),'')              --@TransToDomCurVar
                 + ',' + ISNULL(CAST(@PrintSerialNumbers AS NVARCHAR(1)),'')          --@SerNumVar
                 + ',' + ISNULL(CAST(@PrintPlanItemMaterial AS NVARCHAR(1)),'')       --@PlanItemMaterialsVar
                 + ',' + ISNULL(CAST(@LCRVar AS NVARCHAR(1)),'')                      --@LCRVar
                 + ',' + ISNULL(@StartOrderNum, '')                                   --@OrderNumVar
                 + ',' + ISNULL(CAST(@PrintOrderNotes AS NVARCHAR(1)),'')             --@PrintLineReleaseNotes
                 + ',' + ISNULL(CAST(@PrintLineReleaseDescription AS NVARCHAR(1)),'') --@PrintLineReleaseDescription
                 + ',' + ISNULL(CAST(@PrintStandardOrderText AS NVARCHAR(1)),'')      --@StdOrderTextVar
                 + ',' + ISNULL(CAST(@PrintBillToNotes AS NVARCHAR(1)),'')            --@BillToTextVar
                 + ',' + ISNULL(CAST(@PrintInternalNotes AS NVARCHAR(1)),'')          --@PrintInternalNotes
                 + ',' + ISNULL(CAST(@PrintExternalNotes AS NVARCHAR(1)),'')          --@PrintExternalNotes
                 + ',' + ISNULL(CAST(@PrintItemOverview AS NVARCHAR(1)), '')          --@PrintItemOverview
                 + ',' + ISNULL(CAST(@PrintDiscountAmt AS NVARCHAR(1)),'')            --@PrintTermsDiscAmtVar
                 + ',' + ISNULL(CAST(@PrintLotNumbers AS NVARCHAR(1)),'')             --@PrintLotNumbers
                 + ',' + LTRIM(CAST(ISNULL(@StartingShipment, dbo.LowInt()) AS NVARCHAR(36))) --@StartingShipment
                 + ',' + LTRIM(CAST(ISNULL(@EndingShipment, dbo.HighInt())AS NVARCHAR(36)))   --@EndingShipment

      IF @InvoiceType = 'A' -- Price Adjustment
        ------@BGTaskName  = 'OrderInvoicingCreditMemoReportLaser'
        SET @BGTaskParms = ISNULL(CAST(@SessionID AS NVARCHAR(36)),'')
                 + ',' + ISNULL(CAST(@InvType AS NVARCHAR(4)),'')
                 + ',' + ISNULL(@PrintMode,'PROCESS')
                 + ',' + ISNULL(@PInvNum, '')
                 + ',' + ISNULL(@PInvNum, '')
                 + ',' + ISNULL(@StartOrderNum,'')
                 + ',' + ISNULL(@EndOrderNum,'')
                 + ',' + CONVERT ( NVARCHAR(28) , ISNULL(@InvDate, GETDATE()) ,20 )
                 + ',' + CONVERT ( NVARCHAR(28) , ISNULL(@InvDate, GETDATE()) ,20 )
                 + ',' + ISNULL(@StartCustomer , '')
                 + ',' + ISNULL(@EndCustomer, '')
                 + ',' + ISNULL(@PrintItemCustomerItem , '')
                 + ',' + ISNULL(CAST(@TransToDomCurr AS NVARCHAR(1)),'')
                 + ',' + ISNULL(@InvCred, '')
                 + ',' + ISNULL(CAST(@PrintSerialNumbers AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintPlanItemMaterial AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintConfigurationDetail AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintEuro AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintCustomerNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintOrderNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintOrderLineNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintOrderBlanketLineNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintProgressiveBillingNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintInternalNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintExternalNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintItemOverview AS NVARCHAR(1)), '')         
                 + ',' + ISNULL(CAST(@DisplayHeader AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintLineReleaseDescription AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintStandardOrderText AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintBillToNotes AS NVARCHAR(1)),'')
                 + ',' + ISNULL(@LangCode, '')
                 + ',' + ISNULL(CAST(@BGSessionID AS NVARCHAR(36)), '')
                 + ',' + ISNULL(CAST(@PrintDiscountAmt AS NVARCHAR(1)),'')
                 + ',' + ISNULL(CAST(@PrintLotNumbers AS NVARCHAR(1)),'')

      IF NOT @BGTaskParms IS NULL
	  BEGIN --LAKE-- GROUP BGTaskSubmit and New DT PDF Trx /******  Lake Companies, Inc.  ******/

         EXEC @Severity        = dbo.BGTaskSubmitSp
              @TaskName        = @BGTaskName
            , @TaskParms1      = @BGTaskParms
            , @TaskParms2      = NULL
            , @Infobar         = @Infobar   OUTPUT
            , @TaskID          = @BGTaskID  OUTPUT
            , @TaskStatusCode  = 'READY'
            , @StringTable     = @StringTable
            , @RequestingUser  = @RequestingUser
		
		 /*
		 ====================
		 Lake Companies, Inc.
		 ====================
		 */
		 IF OBJECT_ID('EXTLCDTInsertIntoLCDTPDFTRANSACTIONOIVSp') IS NOT NULL AND @LCDTTypeEnabled = 1
		 BEGIN
		    SET @SpName = 'dbo.EXTLCDTInsertIntoLCDTPDFTRANSACTIONOIVSp'
		    EXEC @Severity = @SpName
			    @SessionID
			  , @InvoiceType
			  , @BGTaskName
			  , @InvType
			  , @InvCred
			  , @InvDate
			  , @StartCustomer
			  , @EndCustomer
			  , @StartOrderNum
			  , @EndOrderNum
			  , @StartLine
			  , @EndLine
			  , @StartRelease
			  , @EndRelease
			  , @StartLastShipDate
			  , @EndLastShipDate
			  , @StartPackNum
			  , @EndPackNum
			  , @CreateFromPackSlip
			  , @pMooreForms
			  , @pNonDraftCust
			  , @SelectedStartInvNum
			  , @CheckShipItemActiveFlag
			  , @StartInvNum
			  , @EndInvNum
			  , @PrintItemCustomerItem
			  , @TransToDomCurr
			  , @PrintSerialNumbers
			  , @PrintPlanItemMaterial
			  , @PrintConfigurationDetail
			  , @PrintEuro
			  , @PrintCustomerNotes
			  , @PrintOrderNotes
			  , @PrintOrderLineNotes
			  , @PrintOrderBlanketLineNotes
			  , @PrintProgressiveBillingNotes
			  , @PrintInternalNotes
			  , @PrintExternalNotes
			  , @DisplayHeader
			  , @PrintLineReleaseDescription
			  , @PrintStandardOrderText
			  , @PrintBillToNotes
			  , @LangCode
			  , @PrintDiscountAmt
			  , @BatchId
			  , @BGSessionId
			  , @UserId
			  , @Infobar
			  , @LCRVar
			  , @pBegDoNum
			  , @pEndDoNum
			  , @pBegCustPo
			  , @pEndCustPo
			  , @DoHdrList
			  , @PItemTypeCust
			  , @PItemTypeItem
			  , @PrintConInvReport
			  , @PInvNum
			  , @POrderNums
			  , @PMiscCharges
			  , @PSalesTax
			  , @PFreight
			  , @TCustPT
			  , @PApplyToInvNum
			  , @TOpt
			  , @UseProfile
			  , @SubStartingInvNum
			  , @SubEndingInvNum
			  , @LCDTInvType
			  , @BGTaskID
			  IF @Severity <> 0
			 	 RETURN @Severity         				
		 END

		 IF OBJECT_ID('EXTLCDTInvoicingCreatePDFTrxSp') IS NOT NULL AND @LCDTTypeEnabled = 1
		 BEGIN
			SET @SpName = 'dbo.EXTLCDTInvoicingCreatePDFTrxSp'
			EXEC @Severity = @SpName
				@SubStartingInvNum
				,@SubEndingInvNum
				,@LCDTInvType
				,@BGTaskID	
		    IF @Severity <> 0
			  RETURN @Severity				
		 END
	     /*
	     End modification.
	     ====================
	     Lake Companies, Inc.
	     ====================
	     */		
      END --LAKE-- END --NEW BEGIN TO GROUP BGTaskSubmit and New PDF Trx /******  Lake Companies, Inc.  ******/
  END --while loop
  CLOSE BGTaskCursor
  DEALLOCATE BGTaskCursor
END -- IF @PrintInv = 1

 /*  
====================  
Lake Companies, Inc.  
====================  
Get the Lake Company Parameters  
*/  
IF OBJECT_ID('dbo.EXTLCDTInvoicingCompletedSP') IS NOT NULL
BEGIN  
   SET @SpName = 'dbo.EXTLCDTInvoicingCompletedSP'  
   EXEC @Severity = @SpName  
    @RequestingUser  
    ,@LCDTInvType
    ,@LCDTTypeEnabled
    ,@LCDTUseLakProf
    ,@SubStartingInvNum  
    ,@SubEndingInvNum
  
   IF @Severity <> 0  
      RETURN @Severity    
END  
/*  
End modification.  
====================  
Lake Companies, Inc.  
====================  
*/       

IF @Severity = 0 AND @CalledFrom = 'InvoiceBuilder'
BEGIN  
   DECLARE  
   @OrigSite    SiteType  
   SELECT @OrigSite = site FROM parms  
   -- This deletes all the records which are successfully processed
   DELETE FROM tmp_invoice_builder
   WHERE process_id = @InvoicBuilderProcessID and to_site = @OrigSite

END

ERROR_FUNCT:
IF @Severity <> 0
BEGIN
   EXEC dbo.RaiseErrorSp @Infobar, @Severity, 1
   ROLLBACK
END

EXEC dbo.CloseSessionContextSp @SessionID = @SpSessionID

RETURN @Severity



GO

