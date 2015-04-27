/****** Object:  StoredProcedure [dbo].[ZPV_Co10RSp]    Script Date: 10/29/2014 12:25:26 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_Co10RSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_Co10RSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_Co10RSp]    Script Date: 10/29/2014 12:25:26 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--Converted from co\co10-r.p

/* $Header: /ApplicationDB/Stored Procedures/ZLA_Co10RSp.sp 40    9/17/13 4:54a Bbai $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZLA_Co10RSp.sp $
 *
 * SL8.04 40 115295 Bbai Tue Sep 17 04:54:48 2013
 * 115295:
 * If the message object used is like 'I=%' and Access As BaseSyteLine, then replace it with relative error message like 'E=%'.
 *
 * SL8.04 39 RS2775 exia Wed Feb 20 04:00:20 2013
 * RS2775 
 * Invoice builder
 * Add input parameters and pass to other sps
 *
 * SL8.02 38 130187 Cajones Thu Jun 10 16:02:10 2010
 * Blank Invoice records are sent from Order Invoicing for Customers with EDI profile when print invoices is not checked.
 * Issue 130187
 * Added logic to display new message(s) when processing invoice(s) in which the customer has an edi customer profile record with Print Invoice flag set to No.
 *
 * SL8.02 37 rs4588 Dahn Thu Mar 04 10:25:41 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 36 rs4588 Dahn Thu Mar 04 09:34:52 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 35 121361 Mewing Mon Oct 12 14:51:22 2009
 * SL8.02 00 121361  All references to BatchId2Type need to be changed back to BatchIdType.  This checkin will affect stored procedures, triggers, functions.
 * Schema, property classes and component classes will be done seperately.
 *
 * SL8.01 34 118985 Cajones Mon May 18 14:47:28 2009
 * Unable to generate a Batch ID more than 99 at Shipping Processing Orders
 * Issue:118985,APAR:115322 - Changed references of type BatchIdType (defined as tinyint) to new UDDT BatchId2Type (defined as int).  This change is to allow the user to enter a 6 digit batch id number.
 *
 * SL8.01 33 116613 pgross Wed Jan 14 15:21:33 2009
 * Assigning a single date and compressing journal records for a large volume of data takes too long
 * moved packing slip loop into InvPostSp
 *
 * SL8.01 32 rs3953 Vlitmano Tue Aug 26 16:42:43 2008
 * RS3953 - Changed a Copyright header?
 *
 * SL8.01 31 rs3953 Vlitmano Mon Aug 18 15:07:46 2008
 * Changed a Copyright header information(RS3959)
 *
 * SL8.01 30 109493 pgross Mon Jun 09 15:07:27 2008
 * Performance - Order Invoicing/Credit Memo.  The invoicing process 'created from packing slip' is slow
 * reduced the number of CO's that are processed when Creating from Packing Slip is true
 *
 * SL8.00 29 105182 hcl-kumarup Fri Sep 21 09:56:50 2007
 * One Invoice Per Packing Slip not working correctly
 * Checked-in for issue 105182
 * Chagned the conditon from IF @OnePackInv = 1 to IF @OnePackInv = 0
 *
 * SL8.00 28 101202 pgross Fri Apr 20 16:44:21 2007
 * Receive yellow exclamation point with no error message when running Order Invoicing Credit Memo
 * changed how to signal that no invoices were generated
 *
 * SL8.00 27 rs2968 nkaleel Fri Feb 23 00:56:17 2007
 * changing copyright information
 *
 * SL8.00 26 96320 pgross Wed Sep 13 14:26:51 2006
 * Invalid message when trying to print progressive billing and cross reference to project is invalid on Customer Order line
 * stop processing when Progressive Billing fails
 *
 * SL8.00 25 90226 pgross Thu Jul 20 10:33:54 2006
 * InvPostSp blocks the co table for lengthy periods preventing work by many other users in related areas
 * replaced #tt_CounterTable usage with an output parameter
 *
 * SL8.00 24 RS2968 prahaladarao.hs Thu Jul 13 02:45:03 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL8.00 23 RS2968 prahaladarao.hs Tue Jul 11 05:23:59 2006
 * RS 2968
 * Name change CopyRight Update.
 *
 * SL8.00 22 91818 NThurn Mon Jan 09 09:56:04 2006
 * Inserted standard External Touch Point call.  (RS3177)
 *
 * SL7.05 21 91110 hcl-singind Tue Dec 27 02:04:40 2005
 * Add WITH (READUNCOMMITTED) to co selects
 * Issue #: 91110
 * Added "WITH (READUNCOMMITTED)" to co Select Statement.
 *
 * SL7.05 20 91077 hcl-kumarup Fri Dec 16 04:25:47 2005
 * Order invoicing credit memo by packing slip can include order lines not on the packing slip.
 * Checked in for issue #91077
 * Handled One Invoice Per Packing Slip
 *
 * SL7.05 19 86680 Hcl-chantar Fri Apr 01 08:16:18 2005
 * Invoices are not printing correctly based on the starting and ending Packing Slip entered.
 * Issue 86680:
 * AND ph.pack_num BETWEEN @StartPackNum AND @EndPackNum
 *
 * SL7.04 19 86680 Hcl-chantar Fri Apr 01 08:14:30 2005
 * Invoices are not printing correctly based on the starting and ending Packing Slip entered.
 * Issue 86680:
 * AND ph.pack_num BETWEEN @StartPackNum AND @EndPackNum
 *
 * SL7.04 18 86020 Hcl-jainami Fri Feb 11 11:20:22 2005
 * Cannot invoice by ship date when shipping was done through Generate Order Pick List
 * Checked-in for issue 86020:
 * Used the 'ApplyDateOffsetSp' function to set the proper time for variables '@StartLastShipDate' & '@EndLastShipDate'.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_Co10RSp] (
  @InvType                      NVARCHAR(10)  = 'R'
, @InvCred                      NCHAR(1)      = 'I'
, @InvDate                      DateType      = NULL
, @StartCustomer                CustNumType   = NULL
, @EndCustomer                  CustNumType   = NULL
, @StartOrderNum                CoNumType     = NULL
, @EndOrderNum                  CoNumType     = NULL
, @StartLine                    CoLineType    = NULL
, @EndLine                      CoLineType    = NULL
, @StartRelease                 CoReleaseType = NULL
, @EndRelease                   CoReleaseType = NULL
, @StartLastShipDate            DateType      = NULL
, @EndLastShipDate              DateType      = NULL
, @StartPackNum                 PackNumType   = NULL
, @EndPackNum                   PackNumType   = NULL
, @CreateFromPackSlip           FlagNYType    = 0
, @pMooreForms                  nvarchar(1)   = 'N'
, @pNonDraftCust                FlagNYType    = 0
, @SelectedStartInvNum          InvNumType    = NULL
, @CheckShipItemActiveFlag      FlagNYType    = 0
, @StartInvNum                  InvNumType    = NULL  OUTPUT
, @EndInvNum                    InvNumType    = NULL  OUTPUT
, @Infobar                      InfobarType   = NULL  OUTPUT
, @BatchId                      BatchIdType
, @ProcessID                    RowPointerType  OUTPUT
, @CalledFrom                   InfobarType   = NULL -- can be InvoiceBuilder or NULL           
, @InvoicBuilderProcessID       RowpointerType = NULL

) AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_Co10RSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_Co10RSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @InvType
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
         , @Infobar OUTPUT
         , @BatchId
         , @ProcessID OUTPUT
         , @CalledFrom
         , @InvoicBuilderProcessID

      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.
 
DECLARE
  @Severity        INT
, @Counter         INT
, @HoldInvType     NVARCHAR(10)
, @StartInvNum1    InvNumType
, @EndInvNum1      InvNumType
, @StartInvNum2    InvNumType
, @EndInvNum2      InvNumType
, @PckhdrPackNum   PackNumType
, @EDICounter      INT

SET @Severity = 0
SET @PckhdrPackNum = 0
SET @ProcessID = NEWID()

EXEC dbo.ApplyDateOffsetSp @Date = @StartLastShipDate OUTPUT, @Offset = null, @IsEndDate = 0
EXEC dbo.ApplyDateOffsetSp @Date = @EndLastShipDate OUTPUT, @Offset = null, @IsEndDate = 1

set @Counter = 0
set @EDICounter = 0

IF @CreateFromPackSlip = 1
or CHARINDEX (N'P', @InvType) = 0
BEGIN
   /* No progressive billing */
   Exec @Severity = dbo.ZPV_InvPostSp
           @InvType
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
         , @pMooreForms
         , @pNonDraftCust
         , @PckhdrPackNum
         , @CheckShipItemActiveFlag
         , @SelectedStartInvNum
         , @StartInvNum      OUTPUT
         , @EndInvNum      OUTPUT
         , @Infobar      OUTPUT
         , @BatchId
         , @ProcessID
         , @InvoiceCount = @Counter output
         , @EDINoPaperInvoiceCount = @EDICounter output
         , @StartPackNum = @StartPackNum
         , @EndPackNum = @EndPackNum
         , @CreateFromPackSlip = @CreateFromPackSlip
         , @CalledFrom             = @CalledFrom
         , @InvoicBuilderProcessID = @InvoicBuilderProcessID
         
END
ELSE IF @InvType = N'P'
BEGIN
   /* progressive billing only */

   Exec @Severity = dbo.ZPV_InvPostPSp -- Invoice Posting to Blanquet/Regular Progbill
           @InvCred
         , @InvDate
         , @StartCustomer
         , @EndCustomer
         , @StartOrderNum
         , @EndOrderNum
         , @StartLine
         , @EndLine
         , @StartRelease
         , @EndRelease
         , @pMooreForms
         , @SelectedStartInvNum
         , @StartInvNum      OUTPUT
         , @EndInvNum      OUTPUT
         , @Infobar      OUTPUT
         , @ProcessID
         , @InvoiceCount = @Counter output
         , @EDINoPaperInvoiceCount = @EDICounter output
         , @CalledFrom             = @CalledFrom
         , @InvoicBuilderProcessID = @InvoicBuilderProcessID
         
END
ELSE
BEGIN
   /* progressive and regular */
   SET @HoldInvType = ''
   IF CHARINDEX (N'R', @InvType) > 0
   BEGIN
      SET @HoldInvType = @HoldInvType + N'R'
   END
   IF CHARINDEX (N'B', @InvType) > 0
   BEGIN
      SET @HoldInvType = @HoldInvType + N'B'
   END

   Exec @Severity = dbo.ZPV_InvPostPSp
           @InvCred
         , @InvDate
         , @StartCustomer
         , @EndCustomer
         , @StartOrderNum
         , @EndOrderNum
         , @StartLine
         , @EndLine
         , @StartRelease
         , @EndRelease
         , @pMooreForms
         , @SelectedStartInvNum
         , @StartInvNum1      OUTPUT
         , @EndInvNum1      OUTPUT
         , @Infobar      OUTPUT
         , @ProcessID
         , @InvoiceCount = @Counter output
         , @EDINoPaperInvoiceCount = @EDICounter output
         , @CalledFrom             = @CalledFrom
         , @InvoicBuilderProcessID = @InvoicBuilderProcessID
         
   if @Severity = 0
      Exec @Severity = dbo.ZPV_InvPostSp
           @HoldInvType
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
         , @pMooreForms
         , @pNonDraftCust
         , @PckhdrPackNum
         , @CheckShipItemActiveFlag
         , @SelectedStartInvNum
         , @StartInvNum2      OUTPUT
         , @EndInvNum2      OUTPUT
         , @Infobar      OUTPUT
         , @BatchId
         , @ProcessID
         , @InvoiceCount = @Counter output
         , @EDINoPaperInvoiceCount = @EDICounter output          
         , @CalledFrom             = @CalledFrom
         , @InvoicBuilderProcessID = @InvoicBuilderProcessID        
         

      SET @StartInvNum = CASE WHEN ISNULL(@StartInvNum1, '0') <> '0' THEN @StartInvNum1 ELSE @StartInvNum2 END
      SET @EndInvNum =   CASE WHEN @EndInvNum1 IS NULL
                              THEN @EndInvNum2
                              WHEN @EndInvNum1='0'
                              THEN (CASE WHEN @EndInvNum2 IS NOT NULL THEN @EndInvNum2 ELSE @EndInvNum1 END)
                              WHEN @EndInvNum1 IS NOT NULL
                              THEN (CASE WHEN @EndInvNum2 IS NULL
                                         THEN @EndInvNum1
                                         WHEN @EndInvNum2='0'
                                         THEN @EndInvNum1
                                         ELSE
                                         CASE WHEN @EndInvNum1 > @EndInvNum2 THEN @EndInvNum1 ELSE @EndInvNum2 END
                                    END
                                    )
                         END
END

IF @Severity = 0
BEGIN
   SET @Infobar = NULL

   IF @Counter = 0
   begin
      set @EndInvNum = '0'
      EXEC dbo.MsgAppSp
                  @Infobar OUTPUT,
                  'I=#Processed',
                  @Counter,
                  '@!Invoice'         
   end
   ELSE
      EXEC dbo.MsgAppSp
         @Infobar OUTPUT,
         'I=#Processed',
         @Counter,
         '@!Invoice'

      IF @Counter - @EDICounter > 0
      BEGIN
         SET @Counter = @Counter - @EDICounter          
         EXEC dbo.MsgAppSp
              @Infobar OUTPUT,
              'E=FormPrt',
              @Counter
      END
      ELSE
         set @EndInvNum = '0'

      IF @EDICounter > 0 
         BEGIN
         EXEC dbo.MsgAppSp
              @Infobar OUTPUT,
              'I=ExistFor=',
              '@cust_tp',
              '@!Print',
              '@!No'
         END
END

RETURN @Severity



GO

