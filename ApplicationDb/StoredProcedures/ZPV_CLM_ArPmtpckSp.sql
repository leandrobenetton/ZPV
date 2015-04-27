/****** Object:  StoredProcedure [dbo].[ZPV_CLM_ArPmtpckSp]    Script Date: 10/29/2014 12:14:14 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_ArPmtpckSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_ArPmtpckSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_ArPmtpckSp]    Script Date: 10/29/2014 12:14:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/CLM_ArPmtpckSp.sp 33    1/17/14 12:39a Lchen3 $  */
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

/* $Archive: /ApplicationDB/Stored Procedures/CLM_ArPmtpckSp.sp $
 *
 * SL9.00 33 171545 Lchen3 Fri Jan 17 00:39:40 2014
 * RS4793 AR Chargeback - Coding
 * issue 171545
 * RS4793
 * add chargeback amount fields
 *
 * SL9.00 32 171545 Lchen3 Thu Jan 16 21:05:04 2014
 * RS4793 AR Chargeback - Coding
 * issue 171545
 * RS4793
 * add chargeback amount columns
 *
 * SL8.04 31 RS4615 Lzhan Mon Feb 18 21:34:28 2013
 * RS4615: changed related table name to new table name(*_mst)
 *
 * SL8.04 30 149696 Cjin2 Fri Jul 13 04:06:13 2012
 * Filter on Invoice field in grid is not working
 * 149696: get correct length for d_inv_num in build up filter.
 *
 * SL8.03 29 148119 Ltaylor2 Wed May 02 15:18:08 2012
 * 5325 - Pack and Ship design coding
 * Added tt_pmtpck.shipment_id as new output field
 *
 * SL8.03 28 137702 pgross Thu Apr 21 10:25:58 2011
 * Intermittent Load Collection IDO Error using AR Quick Payment on large customer
 * force recompilation of ArCalcDiscSp to ensure proper index usage
 *
 * SL8.02 27 rs4588 Dahn Thu Mar 04 10:22:06 2010
 * RS4588 Copyright header changes
 *
 * SL8.02 26 rs4588 Dahn Thu Mar 04 09:27:58 2010
 * RS4588 CopyRight Changes
 *
 * SL8.01 25 rs3953 Vlitmano Tue Aug 26 16:41:59 2008
 * RS3953 - Changed a Copyright header?
 *
 * SL8.01 24 rs3953 Vlitmano Mon Aug 18 15:07:09 2008
 * Changed a Copyright header information(RS3959)
 *
 * SL8.00 23 106269 hcl-kumarup Thu Oct 25 00:58:58 2007
 * AR payments cannot select invoice in 'Quick' if invoice number has leading alpha
 * Issue 106269
 * Modified WHERE clause of statement "Delete from #tt_pmtpck"
 *
 * SL8.00 22 100240 Mkurian Fri Sep 21 02:32:45 2007
 * clicking on select All button, not all check box are marked selected.
 * The insert statement has been removed from the Sp. As the table need not be created.
 * issue 100240
 *
 * SL8.00 21 100240 Mkurian Thu Sep 20 11:28:29 2007
 * clicking on select All button, not all check box are marked selected.
 * A 'GO' has been added at the end of the Sps. The code "IF (Select distinct 1 from..... " has been removed from the Sp.
 * issue 100240
 *
 * SL8.00 20 100240 Mkurian Wed Sep 19 10:17:50 2007
 * clicking on select All button, not all check box are marked selected.
 * Removed 
 * SET QUOTED_IDENTIFIER OFF
 * GO
 * SET ANSI_NULLS ON
 * GO
 * From the Sps
 * issue 100240
 *
 * SL8.00 19 100240 Mkurian Tue Sep 18 04:17:22 2007
 * clicking on select All button, not all check box are marked selected.
 * The commented out code has been removed, and the case conversion UPPER has been removed.
 * Issue 100240
 *
 * SL8.00 18 100240 Mkurian Thu Sep 13 02:15:18 2007
 * clicking on select All button, not all check box are marked selected.
 * Replaced all instances of the global temporary table ##tt_pmtpck with the new permanent table tt_pmtpck. Also, deletion, selection etc is all done based on the ProcessId (IDO Session ID). Also, the Sps have been modified to accept an additional parameter the Session ID from the form.
 * The statement to create the temp table ##tt_pmtpck was removed, instead a simple insert happens into the tt_pmtpck table.
 * issue 100240
 *
 * SL8.00 17 103762 hcl-dbehl Fri Jul 27 10:42:03 2007
 * AR Wire payments showing invalid invoice in Quick grid
 * Issue# 103762
 * Removed the filter condition of Type='C' in delete statement of this SP so as to filter out the Invoices with 0 invoice number for the wire and draft records also. 
 *
 * SL8.00 16 99189 hcl-tiwasun Fri Feb 23 06:49:51 2007
 * Invoice 0 is displaying on invoice selection grid
 * Issue# 99189
 * Modified the ARQuickPaymentApplication SP to filter out the paid invoices and payment from the resultset.
 *
 * SL8.00 15 rs2968 nkaleel Fri Feb 23 00:43:19 2007
 * Changing copyright information
 *
 * SL8.00 14 98844 hcl-tiwasun Fri Feb 09 04:21:14 2007
 * Sort Order is not correct A/R Payment Quick Application form
 * Issue# 98844
 *  Modified the SP to display the invoices in correct order.
 *
 * SL8.00 13 97583 hcl-tiwasun Thu Nov 09 06:03:13 2006
 * A/R Quick Payment Application is not displaying open payments after the open credits
 * Issue# 97583
 * Added the inv_date field in order by clause of select command.
 *
 * SL8.00 12 97250 hcl-kumarup Thu Oct 19 00:46:45 2006
 * Credit memos are displaying at the bottom of the grid in A/R Quick Payment Application
 * Checked-in for issue 97250
 * Chaged the order by clause from Type to artran_type
 *
 * SL8.00 11 RS2968 prahaladarao.hs Thu Jul 13 02:41:47 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL8.00 10 RS2968 prahaladarao.hs Tue Jul 11 05:02:38 2006
 * RS 2968
 * Name change CopyRight Update.
 *
 * SL8.00 9 90857 prahaladarao.hs Wed Mar 08 07:05:37 2006
 * System is not consistently handling Remote Invoices (draft customer)
 * 90857
 * 1.Used Payment type to fetch the records in the cursor either from local site or site group.
 *
 * SL7.05 7 91818 NThurn Fri Jan 06 14:22:06 2006
 * Inserted standard External Touch Point call.  (RS3177)
 *
 * SL7.04 6 90165 Grosphi Mon Oct 31 10:32:31 2005
 * made changes to improve performance
 *
 * SL7.04 5 87193 Hcl-dixichi Sun May 15 23:35:44 2005
 * ARQuickPaymentApplication - Filter in Grid Does Not Give Correct Details
 * Checked-in for issue 87193
 * Added a filter parameter '@PFilter' and added logic to filter the records.
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_CLM_ArPmtpckSp] (
  @PBankCode     BankCodeType
, @PCustNum      CustNumType
, @PType         ArpmtTypeType
, @PCheckNum     ArCheckNumType
, @PCreditMemoNum InvNumType
, @PFilter       LongListType = NULL
, @PProcessId    RowPointerType
) AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_CLM_ArPmtpckSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_CLM_ArPmtpckSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      EXEC @EXTGEN_SpName
         @PBankCode
         , @PCustNum
         , @PType
         , @PCheckNum
         , @PCreditMemoNum
         , @PFilter
         , @PProcessId    
 
      -- ETP routine must take over all desired functionality of this standard routine:
      RETURN 0
   END
   -- End of Generic External Touch Point code.
 
declare
 @SiteSite SiteType

-- Converted from as/query/static/pmtpck.w  procedure: build-temp-tables-QUERY-2
DECLARE
  @Severity  INT
, @Infobar   InfobarType
, @SiteGroup SiteGroupType
, @LocalSite SiteType
, @InvNumLength InvNumLength 

SET @Severity = 0

SELECT @InvNumLength = inv_num_length FROM coparms 

DECLARE
  @SQL LongListType

DECLARE
  @PropertyList LongListType
, @ColumnList   LongListType
SET @PropertyList = N'BankCode;CustNum;Type;CheckNum;Description;ExchRate;Ref;ArpdCoNum;ArpdSite;DerAcct;DerAcctUnit1;DerAcctUnit2;DerAcctUnit3;DerAcctUnit4;DerApplyCustNum;DerArtranType;DerCheckSeq;DerDiscAcct;DerDiscAcctUnit1;DerDiscAcctUnit2;DerDiscAcctUnit3;DerDiscAcctUnit4;DerDiscDate;DerDoNum;DerDomAllowAmt;DerDomAmtApplied;DerDomDiscAmt;DerDueDate;DerFixedRate;DerForAllowAmt;DerForAmtApplied;DerForDiscAmt;DerInvDate;DerInvNum;DerInvSeq;DerPayType;DerPickFlag;DerTcAmtAllowAmt;DerTcAmtAmount;DerTcAmtAmtApplied;DerTcAmtDiscAmt;DerTcAmtOrigAmt;DerTcAmtTotPaid;DerDInvNum;DerDInvSeq;DerTcAmtChargebackAmt;DerDomChargebackAmt;DerForChargebackAmt'
SET @ColumnList = N'bank_code;cust_num;type;check_num;description;exch_rate;ref;co_num;site;acct;acct_unit1;acct_unit2;acct_unit3;acct_unit4;apply_cust_num;artran_type;check_seq;disc_acct;disc_acct_unit1;disc_acct_unit2;disc_acct_unit3;disc_acct_unit4;disc_date;do_num;dom_allow_amt;dom_amt_applied;dom_disc_amt;due_date;fixed_rate;for_allow_amt;for_amt_applied;for_disc_amt;inv_date;inv_num;inv_seq;pay_type;pick_flag;tc_amt_allow_amt;tc_amt_amount;tc_amt_amt_applied;tc_amt_disc_amt;tc_amt_orig_amt;tc_amt_tot_paid;CASE WHEN LEN(LTRIM(d_inv_num)) < ' + CAST(@InvNumLength AS NVARCHAR(5)) + N' THEN RIGHT(d_inv_num,' + CAST(@InvNumLength AS NVARCHAR(5)) + N') ELSE LTRIM(d_inv_num) END;inv_seq;tc_amt_chargeback_amt;dom_chargeback_amt;for_chargeback_amt'

SET @PFilter = ISNULL(dbo.SQLFilter(@PFilter, @PropertyList, @ColumnList, ';'), N'')

IF @PFilter <> ''
  SET @PFilter = ' AND ' + @PFilter

 
-- Get local site
SELECT @LocalSite = site
, @SiteGroup = isnull(@SiteGroup, site_group)
FROM   parms with (readuncommitted)
WHERE  parm_key = 0


SET @SiteGroup = NULL
-- Get Arparms site_group
SELECT @SiteGroup = site_group
FROM   arparms with (readuncommitted)
WHERE  arparms_key = 0

IF @PCustNum IS NOT NULL AND @PCheckNum IS NOT NULL
BEGIN
   IF @PType <> 'D'
   BEGIN
      declare site_crs cursor local static for
      select site.site
      from site_group AS Site with (readuncommitted)
      where Site.site_group = @SiteGroup

      open site_crs
   END   
   
   while 1 = 1
   begin
      IF @PType <> 'D'
      BEGIN             
         fetch site_crs into
           @SiteSite 
         if @@fetch_status <> 0
            break
      END
      ELSE
         select @SiteSite = site.site
         from site with (readuncommitted)
         where Site.site = @LocalSite

      -- Only include those sites where customer data is replicated.
      IF (@LocalSite = @SiteSite) OR
         dbo.IsObjectReplicated( @LocalSite, @SiteSite, 'custaddr_mst', 1) = 1
      BEGIN
         -- make sure that we have the proper Execution Plan
         exec sp_recompile ArCalcDiscSp
         EXEC @Severity = dbo.ArFilpckSp
           @PBankCode   = @PBankCode
         , @PCustNum    = @PCustNum
         , @PType       = @PType
         , @PCheckNum   = @PCheckNum
         , @InvoiceSite = @SiteSite
         , @Infobar     = @Infobar OUTPUT
         , @PCreditMemoNum  = @PCreditMemoNum
         , @PProcessId = @PProcessId

         IF @Severity <> 0 OR  @PType = 'D'
            BREAK
      END

   end
   IF @PType <> 'D'
   begin
      close site_crs
      deallocate site_crs
   end
END

Delete from tt_pmtpck where (Artran_type ='I' and tc_amt_orig_amt = 0 and inv_num='0' and ProcessId = @PProcessId)     

-- Return record set from #tt_pmtpck
SET @SQL = 'SELECT
  bank_code
, cust_num
, type
, check_num
, inv_num
, d_inv_num -- just to get a temp NCHAR field
, inv_seq
, d_inv_seq -- just to get a temp NCHAR field
, check_seq
, site
, inv_date
, due_date
, disc_date
, co_num
, artran_type
, apply_cust_num
, pay_type
, tc_amt_amount
, tc_amt_orig_amt
, tc_amt_tot_paid
, tc_amt_amt_applied
, tc_amt_disc_amt
, tc_amt_allow_amt
, dom_amt_applied
, dom_disc_amt
, dom_allow_amt
, for_amt_applied
, for_disc_amt
, for_allow_amt
, fixed_rate
, exch_rate
, description
, ref
, pick_flag
, acct
, acct_unit1
, acct_unit2
, acct_unit3
, acct_unit4
, disc_acct
, disc_acct_unit1
, disc_acct_unit2
, disc_acct_unit3
, disc_acct_unit4
, do_num
, RowPointer
, Use_multi_due_dates
, credit_memo_num
, shipment_id
, tc_amt_chargeback_amt
, dom_chargeback_amt
, for_chargeback_amt
FROM tt_pmtpck' +
' WHERE ProcessId = N'''+ cast(@PProcessId AS nvarchar(50))+''''+
@PFilter +
' ORDER BY cust_num,'          
+ '(Case when (Artran_type=' +  CHAR(39) + 'C' + CHAR(39) + ') then ' + CHAR(39) + 'A' + CHAR(39)                 
+ 'when (Artran_type='+ CHAR(39) + 'F' + CHAR(39) + ') then ' + CHAR(39) + 'B' + CHAR(39)                
+ 'when (Artran_type='+ CHAR(39) + 'P' + CHAR(39) + ') then ' + CHAR(39) + 'C' + CHAR(39)                
+ 'when (Artran_type='+ CHAR(39) + 'I' + CHAR(39) + ') then ' + CHAR(39) + 'D' + CHAR(39)                 
+ ' ELSE ' + CHAR(39) + 'E' + CHAR(39)                 
+ ' END )'                
+ ' , ( Case when (Artran_type=' +  CHAR(39) + 'C' + CHAR(39) + ') then '       
+ ' ISNULL(co_num,' + CHAR(39) + 'zzzzzzzzzzz' + char(39) + ')'             
+ ' Else Inv_Num '      
+ ' END ) '       
+ ' , Inv_Date, site'  

EXEC sp_executesql @SQL

RETURN @Severity

GO

