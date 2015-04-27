/****** Object:  Trigger [coitem_mstIup]    Script Date: 16/04/2015 1:51:39 p. m. ******/
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'coitem_mstIup' AND xtype = 'TR')
DROP TRIGGER [dbo].[coitem_mstIup]
GO

/****** Object:  Trigger [dbo].[coitem_mstIup]    Script Date: 16/04/2015 1:51:39 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*$Header: /ApplicationDB/Triggers/coitem_mstIup.trg 193   3/13/14 2:18p pgross $ */
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
*   (c) COPYRIGHT 2008 INFOR.  ALL RIGHTS RESERVED.           *
*   THE WORD AND DESIGN MARKS SET FORTH HEREIN ARE            *
*   TRADEMARKS AND/OR REGISTERED TRADEMARKS OF INFOR          *
*   AND/OR ITS AFFILIATES AND SUBSIDIARIES. ALL RIGHTS        *
*   RESERVED.  ALL OTHER TRADEMARKS LISTED HEREIN ARE         *
*   THE PROPERTY OF THEIR RESPECTIVE OWNERS.                  *
*                                                             *
***************************************************************
*/


/* $Archive: /ApplicationDB/Triggers/coitem_mstIup.trg $
 *
 * SL9.00 193 176867 pgross Thu Mar 13 14:18:40 2014
 * Non-Inventory Item-Description,unit price and UOM are updated by Customer order lines
 * do not update the non_inventory_item's description and U/M
 *
 * SL9.00 192 176119 pgross Mon Mar 10 11:04:18 2014
 * Allocated to Customer Order does not always update.
 * do not pass an adjusted quantity to UpdIwhsSp
 *
 * SL9.00 191 175705 Sxu Thu Feb 20 22:20:45 2014
 * Estimate Lines - non-inventory item the Cost getting set to zero after saving.
 * Issue 175705 - Set correct cost when order is estimate and item is non inventory item
 *
 * SL9.00 190 175054 pgross Thu Feb 06 15:21:14 2014
 * The SSD Value on the Customer Order Line is set to the Unit Price when it should be set to the Net Price to take into consideration any sales discount applied.
 * use the discounted price for the export_value
 *
 * SL9.00 189 169051 pgross Tue Dec 10 14:06:31 2013
 * Ready quantity on Customer order Lines for xref jobs is incorrect if Customer order has had a status of stopped
 * only update qty_ready when line status if P, O, F
 *
 * SL9.00 188 170456 Lqian2 Mon Nov 25 23:56:01 2013
 * Rows not being inserted into chart_mst_all table
 * Issue 170456, Rollback first fix and use the new solution for multi-site in one DB problem.
 *
 * SL9.00 187 170456 Lqian2 Mon Nov 25 22:03:16 2013
 * Issue 170456, Fix multi-site in one db.
 *
 * SL9.00 186 168072 pgross Tue Nov 05 15:48:26 2013
 * The reserved qty field is not updated on customer order lines when the reservation is removed.
 * force replication of qty_rsvd when changing the Status to Complete
 *
 * SL9.00 185 169325 Jgao1 Mon Oct 28 01:57:52 2013
 * Update _All Tables message on launch
 * 169325: add parameter for function Populate_AllTables
 *
 * SL9.00 184 170346 Sxu Sun Oct 27 22:21:16 2013
 * The CO line item unit cost is not being recalculated properly when the line is shipped
 * Issue 170346- Add condition @NonInventoryItem = 1, so it will not reset item unit cost to Customer Order Lines when item is not non-inventory.
 *
 * SL8.04 183 169358 bbopp Fri Oct 04 10:29:13 2013
 * Saving line with Ship Site changed not updating Item Availability
 * Issue 169358
 * Correct setting of site based on which site the update occured.
 *
 * SL8.04 182 169358 Lqian2 Thu Sep 26 04:15:42 2013
 * Saving line with Ship Site changed not updating Item Availability
 * Issue 169358, Use GoTo to run the trigger twice and switch the site context.
 *
 * SL8.04 181 167237 Lqian2 Thu Sep 12 03:06:28 2013
 * Shipped status not update when done order ship at diff site
 * Issue 167237, Multi site in one DB fix. When the CO orig site and ship site are in the same DB, should call the RemoteMethodCallSp to update row regardless sync_reqd value.
 *
 * SL8.04 180 165054 Jmtao Thu Sep 12 02:00:14 2013
 * On Order Balance is not caculated correctly
 * 165054 IF ( ( @Status = N'P' ) OR ( @OldStatus = N'P' ) AND (@Status != @OldStatus) )  -- Status changing to or from Planned.  should be changed to IF ( ( @Status = N'P' ) OR ( @OldStatus = N'P' ) ) AND (@Status != @OldStatus)  -- Status changing to or from Planned.  
 *
 * SL8.04 179 165054 Jmtao Wed Sep 11 03:59:19 2013
 * On Order Balance is not caculated correctly
 * 165054 Remove the else clause.
 * Let sp do the logic even @Adjust is not zero.
 *
 * SL8.04 178 161307 Jgao1 Tue Sep 10 02:40:25 2013
 * Code review of RS3639 in trigger coitem_mstIup
 * 161307: message for non-inventory account is not required for estimate line.
 *
 * SL8.04 177 164433 Lqian2 Wed Jul 10 05:15:28 2013
 * On Order Balance not subtracting from total depending on order status.
 * Issue 164433, @OnlyStatChanged should be set to 1 when change state from "O" to "P".
 *
 * SL8.04 176 163026 Azhang Fri Jun 07 05:52:17 2013
 * Customer Order Line not saving; Error message is "Error Message does not exist. Object:PK_coitem_mst_all, Type:17"
 * Issue 163026: Avoid to insert records into all tables in single site in one db.
 *
 * SL8.04 174 162050 mstephens Fri May 10 10:13:49 2013
 * Order deletion leaves stranded transfer plan information at supply site
 * MSF 162050. Order deletion leaves stranded transfer plan information at supply site.
 *
 * SL8.04 173 161878 Lchen3 Mon May 06 22:47:43 2013
 * Incorrect error message when completing second Pick Confirmation
 * issue 161878
 * remove the logic of check picked qty
 *
 * SL8.04 172 160611 Ltaylor2 Fri Apr 19 10:21:44 2013
 * Multi-Site features do not work with multiple sites in one DB.
 * Issue 160611 - copy code to insert into _all table from Insert trigger to Iup trigger
 *
 * SL8.04 171 161220 Lchen3 Fri Apr 19 02:09:41 2013
 * Add validation against Qty Picked when user deleting Customer Order
 * issue 161220
 * add validator on qty ordered to check if the qty ordered less than qty to pick.
 *
 * SL8.04 170 161006 Sxu Thu Apr 18 21:39:10 2013
 * Total Cost showing 0 on estimates
 * Issue 161006 - Do not update x_cost_conv to 0 for estimate lines in trigger coitemIup
 *
 * SL8.04 169 160005 bbopp Thu Mar 21 09:06:47 2013
 * File checked in as unicode
 * Issue 160005
 * Remove unicode version.
 *
 * SL8.04 168 rs5932 Mding2 Thu Mar 14 23:36:07 2013
 * RS 5932 recalculate freight charges when add newly co  line or update  item/qty ordered.
 *
 * SL8.04 167 158715 Bli2 Wed Feb 20 02:24:52 2013
 * Unit Cost on Customer Order Lines form, it get wrong whse when cost item at warehouse is Yes.
 * Issue 158715 - Use Item Wharehouse Cost instead of Item Cost if Cost Item At Warehouse is checked on Inventory Parameters.
 *
 * SL8.04 166 RS3377 Dlai Tue Jan 15 02:44:02 2013
 * RS337 Change back from UMConvFactor2Type to UMConvFactorType
 *
 * SL8.04 165 RS4637 Jgao1 Wed Jan 09 00:33:54 2013
 * RS4637: Update non-inventory unit cost, unit price, um and description.
 *
 * SL8.04 164 RS4615 Jpan2 Thu Dec 13 03:06:47 2012
 * RS4615 - change trigger nest level references.
 *
 * SL8.04 163 RS4615 Jmtao Thu Dec 06 21:42:13 2012
 * RS4615(Multi - Add Site within a Site Functionality).
 *
 * SL8.04 162 RS5458 pcoate Fri Nov 30 17:07:19 2012
 * RS5458 - Call SumCoSp for estimates created from the portal no matter what the ship_site is.
 *
 * SL8.04 161 155210 Ehe Fri Nov 23 03:24:11 2012
 * Customer Order Lines - Allow Over Credit limit selected does not save the line in status ordered
 * Issue:155210
 * Change the code to get the correct value of @AllowOverCreditLimit
 *
 * SL8.04 160 105750 Cliu Tue Oct 09 05:33:47 2012
 * sweep required to pass date values in internal format to RemoteMethodCallSp
 * Issue:105750
 * Convert the PromiseDate, DueDate, ReleaseDate, ProjectedDate and ShipDate to the 121 string format before passing it into the RemoteMethodCallSp procedure in coitem_mstIup.
 *
 * SL8.04 159 92739 Dhuang Tue Sep 11 22:43:27 2012
 * Usage of GetErrorMessageSp should be removed
 * 92739
 * GetErrorMessageSp is replaced with MsgAppSp
 *
 * SL8.04 158 150338 pgross Tue Sep 11 16:05:00 2012
 * Error Customer, Item, Customer Item entered combination already exists
 * remove DefineVariables created by CoitemSetGloVarSp
 *
 * SL8.04 157 150967 calagappan Tue Sep 04 16:14:49 2012
 * No warning message when completing a customer order line and there is outstanding Progressive Billing amounts
 * Progressive billed and applied amounts must be equal before status can be changed to complete
 *
 * SL8.04 156 152388 pgross Fri Aug 24 09:23:15 2012
 * Co Released Status not be 'Filled' after perform a shipment with full Quantity.
 * ignore minor rounding differences between quantity shipped and ordered and invoiced
 *
 * SL8.04 155 RS5458 srathore Thu Aug 02 15:12:33 2012
 * RS5458 Account Management. Trigger modified for OrderShippingAlert logic.
 *
 * SL8.04 154 148730 pgross Thu Aug 02 10:39:10 2012
 * Transfer Order Lines issues invalid warning message: The SSD value entered must be greater than 0
 * only generate an export_value error when crossing EU borders
 *
 * SL8.04 153 148448 pgross Tue Jul 31 16:49:25 2012
 * Change CO Status Utility run in Background Queue completes partially shipped and invoiced Blanket Lines
 * added the ability to skip updating co_bln.stat
 *
 * SL8.04 152 RS5458 srathore Tue Jul 31 16:36:19 2012
 * RS 5458 Account Management.
 *
 * SL8.04 151 94565 Dlai Mon Jul 23 22:51:15 2012
 * RemoteMethodCallSp Clean-up
 * 94565-All objects that utilize RemoteMethodCallSp should pass in NULL for the IDO.
 *
 * SL8.04 150 RS5458 srathore Thu Jul 19 17:25:54 2012
 * RS 5458 Account Management. Modified the trigger logic to  insert rows in the Trackrows table.
 *
 * SL8.04 149 150883 Phorne Wed Jul 18 11:44:24 2012
 * Remote Event should be fired after the fix of 150226.
 * Issue#150883 - Removed code to skip deadlock issue fixed in 150226
 * code in 150226 Built into toolset 7.1.0.24
 *
 * SL8.04 148 150875 pgross Fri Jun 29 17:19:59 2012
 * Errors occur about Item not existing and GL Acct may not be blank when entering item in one site that only exists in the ship site
 * check to see if the item exists in the shipping site
 *
 * SL8.03 147 146452 Ddeng Mon Jun 04 00:28:59 2012
 * Issue fro RS 5397 implementation of PO-CO Automation
 * Issue 146452: Skip to fire sending email event during PO-CO Automation.
 *
 * SL8.03 146 134779 Dlai Thu May 31 21:22:50 2012
 * The Source field on CO Lines can be blanked.
 * Issue 134779 add logic to set default value for column ref_type in table coitem by calling stored procedure GetItemRefSp
 *
 * SL8.03 145 144882 pgross Mon Feb 20 11:14:16 2012
 * You can change status to Complete even though there was a Credit Return and Reshipment and Credit Memo and Invoice has not been printed
 * include Qty Returned when checking the ability to close a line
 *
 * SL8.03 144 134983 pgross Wed Jan 25 14:06:23 2012
 * U/M Conversion Wrong Calculation Quantity
 * replaced UMConvFactorType with UMConvFactor2Type
 *
 * SL8.03 143 143381 Ddeng Wed Oct 19 03:19:23 2011
 * Manufacturer and Manufacturer Item are enabled in ship site when different than originating site
 * Issue 143381
 * Modified to replicated Manufacturer Id and Manufacturer Item for remote calling RepCoitemSp.
 *
 * SL8.03 142 143381 jray Mon Oct 17 14:17:43 2011
 * Manufacturer and Manufacturer Item are enabled in ship site when different than originating site
 * Issue 143381: Modified to replicated Manufacturer Id and Manufacturer Item for coitem from orig site to ship site
 *
 * SL8.03 141 139924 pgross Tue Oct 04 11:22:17 2011
 * Margin calculation is incorrect on Margin tab on Customer Service Home Page
 * update converted costs during shipping
 *
 * SL8.03 140 143439 Jbrokl Tue Oct 04 11:07:50 2011
 * Order Line Net Price subtracted from the Customer On order balance.
 * 143439 - Order Line Net Price subtracted from the Customer On order balance.
 *
 * SL8.03 139 142654 Jbrokl Mon Oct 03 03:45:20 2011
 * The dollar amount of a new Customer Order is being doubled when added to the Customer form's On Order Balance
 * 142654 - The dollar amount of a new Customer Order is being doubled when added to the Customer form's On Order Balance
 *
 * SL8.03 138 143042 flagatta Thu Sep 22 15:26:13 2011
 * Unclear error message on the Customer Orders form when changing Status from Ordered to Complete.
 * Change message used when ship qty does not equal invoice qty.  143042
 *
 * SL8.03 137 138003 sruffing Fri Aug 19 09:59:30 2011
 * On Order Balance amount is double what it should be for a Customer Order Line amount
 * 138003
 * Revised update to consider both Amount and Old and New Status before updating customer order balance.  
 *
 * SL8.03 136 139766 Cajones Wed Aug 17 13:03:25 2011
 * Wrong customer number on coitem_mst (customer order line)
 * Issue 139766
 * Modified code to update the coitem.co_cust_num when it doesn't match co.cust_num
 *
 * SL8.03 135 140779 pgross Thu Jul 28 14:18:57 2011
 * Qty Ready field is not correct when Source = Job.
 * update qty_ready when changing ref type from Inventory
 *
 * SL8.03 134 139808 Ddeng Thu Jul 28 07:01:31 2011
 * The Ship to Site Warehouse not being used
 * Issue 139808 Modified the validation to check the customer consignment warehouse whether exists if it's consignment order.
 *
 * SL8.03 133 140454 btian Tue Jul 19 23:02:26 2011
 * Updating CO gives error message " may not be (Blank) for CO Line/Release that has [Order:        164] and [Line #: 1] and [Release: 0]."
 * 140454, set @NonInventoryItem 0 at the begining of circle of cursor coitem_mstIupCrs
 *
 * SL8.03 132 RS 1838 vanmmar Sun Jun 26 03:12:23 2011
 * RS 1838
 *
 * SL8.03 131 RS 1838 vanmmar Thu Jun 23 09:54:59 2011
 * RS 1838
 *
 * SL8.03 130 137872 calagappan Fri Jun 03 16:32:38 2011
 * No data returned for Estimate Lines created in Estimates Quick Entry form when filtering for Customer number in Customer Service Home page.
 * set coitem.co_cust_num = co.cust_num when coitem.co_cust_num is null and co.cust_num is not null
 *
 * SL8.03 129 136707 calagappan Fri May 20 10:46:26 2011
 * SSD no value warning message missing in SL8 for regular and blanket Customer Orders
 * Default SSD Value when it is set as zero in the form
 * Display warning / error message, if needed
 *
 * SL8.03 128 RS4423 Djackson Fri Apr 08 14:45:48 2011
 * RS 4423 - Update co Stat 'S' Update coitem stat 'P' or change credit_hold update forecast
 *
 * SL8.03 127 RS3639 chuang2 Wed Mar 09 02:05:40 2011
 * RS3639 For non-inventory items write the cost_conv amount to the cost column and if there are amounts in the other x_cost_conv or x_cost_conv columns delete those values. 
 *
 * SL8.03 126 RS3639 Cjin2 Fri Feb 25 00:47:00 2011
 * add parameters of non inventory account to call RepCoitemSp
 *
 * SL8.03 125 rs3639 Jpan2 Tue Feb 22 22:29:12 2011
 * RS3639 Handle non-inventory item and allow it go into database.
 *
 * SL8.03 124 134296 pgross Thu Feb 10 10:28:02 2011
 * Customer order lines can not be configured if the item exists in another database as configured with a config string assigned.
 * made changes to support cross-site configuration
 *
 * SL8.03 123 RS4771 Bli2 Sun Jan 09 21:35:38 2011
 * RS4771 - prevent saving if co is set to consignment and whse on coitem_mst is different from co
 *
 * SL8.03 122 135130 pgross Tue Dec 14 13:00:48 2010
 * The shipping site is always the current site when you copy the CO from Estimate after loading SL134999.
 * do not replicate cross-site estimate lines
 *
 * SL8.03 121 132974 sruffing Wed Oct 27 09:36:05 2010
 * On Order Balance not properly calculated based on Order Line status
 * Issue 132974
 * UobChcrSp updates customer.order_bal conditionally for 
 * IF not (@Status = 'P' and @OldStatus in ('P'))
 * so the subsequent update to @SumCo.adjustment is only necessary when the condition is not true.  
 *
 * SL8.03 120 132288 Dahn Wed Aug 25 09:56:50 2010
 * Identify Key Places to Gen Std Events
 * RS3956. Add trigger point for Application Events
 *
 * SL8.03 119 132056 pgross Thu Jul 29 12:55:04 2010
 * On order customer balance goes negative when you reduce the customer order line price if the line status is set to ?Planned? because credit limit is exceeded.
 * adjusted on-order balance for Planned lines
 *
 * SL8.03 118 129619 pgross Thu Jul 08 11:09:55 2010
 * Under specific set of circumstances the on order balanceis incorrect
 * altered the assignment of @OnlyStatChanged to handle more status changes
 *
 * SL8.02 117 128675 Mewing Tue Apr 27 15:29:10 2010
 * Update Copyright
 *
 * SL8.02 116 128628 pgross Mon Mar 29 15:33:55 2010
 * Forecast and cost to complete sales dollars are not updated when the cross reference CO line is changed.
 * update projtask when quantity/cost/discount changes
 *
 * SL8.02 115 rs4588 Dahn Tue Mar 09 08:48:36 2010
 * rs4588 copyright header changes.
 *
 * SL8.02 114 125631 calagappan Mon Mar 01 16:11:22 2010
 * Error: 0 is not a valid ship to is displayed when saving records added using paste rows overwrite
 * Set cust_seq to 0 for regular and blanket COs if cust_num is NULL.
 *
 * SL8.02 113 124881 calagappan Tue Nov 17 16:03:36 2009
 * Customer Order Lines - line shipping from another site that exceeds credit limit is planned status with allow over credit limit
 * Pass Allow Over Credit Limit value from Orig site to Ship site
 *
 * SL8.02 112 125120 pgross Wed Nov 11 16:07:44 2009
 * Customer On Order Balance Updating Incorrectly from Blanket Order Releases
 * corrected order_bal calculation when buffering updates
 *
 * SL8.02 111 124827 Dmcwhorter Fri Nov 06 09:39:54 2009
 * On Blanket orders, the cust_seq is set to null instead of zero.  Same as APAR 112689 but for Blanket orders.
 * 124827 - On blankets set a null cust_seq to 0 even if the cust_num is null.
 *
 * SL8.02 110 123387 pgross Fri Oct 02 16:03:42 2009
 * Customer Order line - Planned status shows in booking report when credit exceeded and ship from other site
 * moved ItemlogSp call to be after cross-site copy of coitem
 *
 * SL8.01 109 123413 pgross Mon Aug 24 10:18:17 2009
 * Price Adjustment Invoice in Ship site does not update the Order in Originating Site.
 * pass price and discount to RepCoitemSp when copying information back to the originating site
 *
 * SL8.01 108 122802 pgross Thu Jul 30 11:28:12 2009
 * Incorrect total price on CO with sales tax.
 * adjust customer balance by tax rounding differences
 *
 * SL8.01 107 122061 pgross Thu Jul 16 08:57:21 2009
 * User gets error SSD value may not be 0.000000000 for CO Line/release that has [unit price 0.0000000] when changing the unit price to 0.00000 so they are unable to save the changes.
 * corrected Export Value calculation
 *
 * SL8.01 106 115337 pgross Fri Nov 07 11:43:29 2008
 * Running Estimate Job BOM Cost Rollup does not reset Estimate Order total cost
 * 1)  always get UM conversion factor for Estimates
 * 2)  call SumCoSp when costs change for Estimates
 *
 * SL8.01 105 114633 pgross Fri Oct 24 14:57:46 2008
 * Final steps in the configuration process are too slow
 * replaced call to ClrXrefSp with ClrXrefBulkSp
 *
 * SL8.01 104 rs3953 Dahn Tue Aug 26 10:15:46 2008
 * changing the copyright header (rs3953)
 *
 * SL8.01 103 rs3953 Dahn Mon Aug 18 14:08:59 2008
 * changing copyright information(RS3953)
 *
 * SL8.01 102 110162 akottapp Tue Jul 15 02:11:04 2008
 * Projected date is getting set to the customer order line due date when the customer order is shipped.
 * Issue 110162 :
 * Modified updating of projected_date field to include trackrows table as well in the joining contitions
 *
 * SL8.01 101 109994 nmannam Thu Jul 03 03:02:11 2008
 * Closing an unshipped CO line is not updating the On Order Balance 
 * 10994-Rebalancing the customer orderblance when changing the customerorderline status from 'Filled' to 'Complete'.
 *
 * SL8.01 100 RS4088 dgopi Fri May 23 04:45:48 2008
 * Making modifications as per RS4088
 *
 * SL8.00 99 106211 Hcl-ajain Wed Oct 24 02:58:16 2007
 * Letter of Credit Accum Co value can be corrupted
 * Issue 106211
 * Modified the condition for substracting the old LCR values
 * From-
 *   IF @InsertFlag = 0 AND @LcrValuesChanged = 1 AND
 *          @OldStatus <> 'P' AND @Status <> 'P'
 * To-
 *       IF (@InsertFlag = 0 AND @LcrValuesChanged = 1 AND          
 *          @OldStatus <> 'P' AND @Status <> 'P') or   
 *           (@InsertFlag = 0 AND      
 *          @OldStatus <> 'P' AND @Status = 'P')      
 *
 * SL8.00 98 104648 Hcl-chantar Fri Sep 14 08:07:12 2007
 * Change Order Lines Change Log showing negative Unit Price when changing unit price to zero.
 * Issue 104648:
 * Passed @OldItem as parameter while calling itemlogSp.
 *
 * SL8.00 97 104395 nmannam Wed Sep 05 04:31:18 2007
 * 0 is not a valid Ship To when actions > copy
 * 104395 - setting the value of shipto zero only when shipto is null and dropship is not null.
 *
 * SL8.00 96 104402 pgross Fri Aug 10 09:14:08 2007
 * Total Price on Estimate Orders is incorrect
 * get UM when cost changes
 *
 * SL8.00 95 95791 Dahn Tue Jul 31 16:59:02 2007
 * Error on process
 * Change Validators for update.
 *
 * SL8.00 94 101929 hcl-dbehl Fri May 18 03:30:35 2007
 * Save release and get Error:  The Ship To must be entered when Drop Ship Customer is not null
 * Issue# 101929
 * Update the coitem table set custseq =0 ehen custnum and custseq is blank.
 *
 * SL8.00 93 101639 Debmcw Tue May 15 16:06:34 2007
 * To Be Shipped Report - Is not including Blanket Releases
 * 101639 - Correct updating of qty_ready.
 *
 * SL8.00 92 101246 pgross Tue May 08 16:14:43 2007
 * Notes not replicating correctly on Customer Orders and Customer Lines
 * removed copying of co notes and relocated copying of coitem notes
 *
 * SL8.00 91 101019 hcl-tiwasun Sun Apr 15 04:12:58 2007
 * Customer Order Blanket Release - Drop Ship defaults from Customer Order.
 * Issue# 101019
 * update the cust_Seq field of coitem table with cust_Seq field of CO table for blanket type of record containig Null Cust_Seq value.
 *
 * SL8.00 90 100702 Hcl-chantar Thu Apr 05 04:41:49 2007
 * SSD value error/warning message no longer displayed in CO line Entry
 * Issue# 100702
 * Added a block of code in the trigger, that was removed against Project 1119.
 *
 * SL8.00 89 99357 Dmcwhorter Fri Mar 09 10:09:17 2007
 * SLCNFIG: When change Item on Estimate Line and reconfigure, the Item on the EJob is not changed although it's Configuration Values are.
 * 99357 - When changing the xref, clear out the config_id on the coitem.
 *
 * SL8.00 88 97738 hcl-dbehl Wed Mar 07 04:34:27 2007
 * Wrong calculation for Customer On Order balance
 * Issue# 97738
 * Made changes so that when Co line status is changed to planned On Order Balance value will reset to 0.
 *
 * SL8.00 87 98734 hcl-dbehl Wed Mar 07 03:08:14 2007
 * Update Customer On Order Balance has rounding problem when using sales tax
 * Issue# 98734
 * The @Adjust value was getting rounded to currency places and hence was creating the problem in the computaion of OrderBalance at Customers.
 * Hence removed the respective lines of code.
 *
 * SL8.00 86 RS2968 nkaleel Fri Feb 23 06:53:01 2007
 * changing copyright information(RS2968)
 *
 * SL8.00 85 99348 bbopp Mon Feb 12 09:29:47 2007
 * unable to script coitem_mstIup trigger
 * Issue 99348
 * Removed nested comments added during revision 74.
 *
 * SL8.00 84 99178 DPalmer Fri Feb 09 15:47:53 2007
 * Error on clicking the process button.
 * Corrected SELECT statement to prevent error
 *
 * SL8.00 83 97800 Hcl-tayamoh Thu Feb 08 04:50:55 2007
 * The cost and price data is 0.00 on the Estimate Status Report for non-inventory items
 * Issue 97800
 * Changed INNER JOIN to LEFT OUTER JOIN for table custaddr in  coitem_mstIupCrs cursor.
 *
 * SL8.00 82 98126 pgross Wed Jan 24 15:25:17 2007
 * Wrong calculation of Customer On Order Balance when unit price changed
 * always calculate price adjustment when qty_shipped changes
 *
 * SL8.00 81 94538 Debmcw Tue Oct 03 17:56:20 2006
 * In SLCNFIG, Configuration values do not pass with Centralized Order Entry
 * 94538 - Add parameter for ConfigId for RepCoitemSp call.
 *
 * SL8.00 80 96018 DPalmer Wed Sep 20 08:08:24 2006
 * Compare currency code of sites when Order Site <> Ship Side.
 *
 * SL8.00 79 95668 hcl-vsukhadiya Wed Aug 23 01:08:18 2006
 * Customer Order Lines -  Credit hold not working when order entered to ship from another site.
 * Issue # 95668
 *
 * SL8.00 78 95547 hcl-singind Fri Aug 04 01:32:19 2006
 * Closing unshipped CO lines is not updating the On Order Balance.
 * Issue # 95547
 * Modified the condition for updating the On Order Balance of Customer.
 *
 * SL8.00 77 RS2968 prahaladarao.hs Wed Jul 12 07:02:25 2006
 * RS 2968, Name change CopyRight Update.
 *
 * SL8.00 76 94129 hoffjoh Fri Jul 07 12:24:24 2006
 * Modifying warehouse on co line to 'dedicated' warehouse - order is still planned
 * TRK 94129 - updated APS Sync logic to include changes to the whse field
 *
 * SL8.00 75 94277 hcl-singind Thu May 25 08:06:49 2006
 * Allocated To customer order quantity is wrong
 * Issue # 94277
 * Effect of Shiped qty has been taken while calculating the Ordered quantity.
 *
 * SL8.00 74 94514 Hcl-jainami Wed May 24 12:43:03 2006
 * Customer order line statCustomer order line status cannot be changed from Planned back to Ordered.us cannot be changed from Planned back to Ordered.
 * Checked-in for issue 94514:
 * Re-added the correct code for:
 *  Set current site's coitem record stat to 'P' when any other site's stat was set to 'P' .
 *
 * SL8.00 73 91804 hcl-kumanav Fri Mar 24 05:22:47 2006
 * Customer Order Lines -  cannot change line from planned to ordered in entry site if shipping from another site.
 * issue# 91804
 * Revert the changes of issue# 81185
 * Remove the Update coitem Set statement
 *
 * SL8.00 72 91636 Hcl-khurgag Wed Mar 08 04:42:24 2006
 * Inconsistent messaging w/ Multisite credit hold
 * Issue -91636. Changed the trigger to display the warning for Customer on Credit Hold . Earlier it was displaying error.
 *
 * SL8.00 71 92214 hcl-kumanav Thu Feb 23 08:48:17 2006
 * Customer Orders - Amounts tab - Total Price is zero.
 * Issue#92214
 * Modify the insert into DefineVariables statement for the Co number whose length is less then datatype length of Co number
 *
 * SL8.00 70 90206 NThurn Thu Feb 02 14:04:55 2006
 * Optimize Insert & Update Triggers
 * Removed more generated sections.  (RS3158)
 *
 * SL8.00 69 91658 pgross Wed Feb 01 16:19:23 2006
 * avoid duplicate TrackRows error
 *
 * SL8.00 68 90917 vanmmar Mon Jan 30 13:27:52 2006
 * Planned orders are created after entering a customer order line with plan on save unchecked.
 * 90917 - sync "plan on save" correctly during syncdefer
 *
 * SL8.00 67 91990 pgross Mon Jan 30 11:31:26 2006
 * The Drop Ship field is being cleared in the Shipping Site when the CO is shipped
 * copy additional columns when replicating to the originating site
 *
 * SL8.00 66 92272 vanmmar Mon Jan 30 00:24:19 2006
 * Replication during planner putback is inefficient
 * 92272 - changes for RS 3049
 *
 * SL8.00 65 90252 pgross Fri Jan 13 09:51:40 2006
 * EDI import of shippers - Performance is slow in co shipping error processing form
 * minimize price calculations
 *
 * SL7.05 63 91301 Hcl-singsun Wed Dec 28 01:40:38 2005
 * Add WITH (READUNCOMMITTED) to poitem selects
 * Issue #91301
 * Added WITH (READUNCOMMITTED) toitem, mrp_parm, poitem and trnitem select.
 *
 * SL7.05 62 90447 vanmmar Tue Nov 15 17:17:16 2005
 * Mass update of coitem.projected_date in planner putback can cause concurrency issues with msite replication
 * Improve performance and concurrency of coitem.projected_date update in APS planner completion logic
 *
 * SL7.05 61 90328 Hcl-jainami Fri Nov 04 16:07:00 2005
 * All lines and releases on a blanket CO are changed to Complete if you change all of the releases on one line to Complete
 * Checked-in for issue 90328:
 * Corrected the logic in WHERE clause while updating the Status in 'co_bln' table to 'C'.
 *
 * SL7.05 60 88658 Coatper Tue Oct 04 16:18:19 2005
 * PostEdiCoSp is locking and bocking
 * Issue 88658 - Prevent credit check logic from executing when the trigger was firied from an insert statement in EdiInOrderPSp.  Instead credit check logic fires in coIup.trg at a later point.
 *
 * SL7.05 59 89575 Hcl-rizvali Mon Oct 03 06:00:03 2005
 * coitem_mstIup trigger assigns the wrong value to coitem_all.co_num
 * Issue No. 89575
 * Changed UPDATE statement to correctly update co_num, co_line, and co_release columns of the coitem_all table.
 *
 * SL7.05 58 89249 Hcl-rizvali Mon Sep 26 06:16:06 2005
 * Issue 89249 - Insert/Update (Iup) triggers for tables having _all tables should be updating all columns of the _all table with the exception of columns used in the join and CreatedBy and CreateDate.
 *
 * SL7.05 57 88521 Clarsco Thu Aug 11 13:26:58 2005
 * Co Line Update through Asynchronous replication shows SumCoSp nuisance Error in To Site Rep. Errors.
 * Added Parm3Value and Parm4Value as dummy parms for RemoteMethodCallSp(SumCoSp) 
 *
 * SL7.05 55 86514 Hcl-tayamoh Mon Jul 25 15:27:18 2005
 * issue 86514
 *
 * SL7.05 54 86514 Hcl-tayamoh Mon Jul 25 12:07:41 2005
 * issue 86514
 *
 * SL7.05 53 88189 Hcl-purosan Tue Jul 19 07:45:10 2005
 * Error:   [Post] was not successful for Pendigng CO Shipping Transaction that has [Order] and [Line:2] and [Release].  Credit Hold is yes for Customer Order that has [Order]
 * Issue 88189
 *
 * SL7.05 52 87872 Hcl-purosan Thu Jul 07 07:43:48 2005
 * Credit Hold is not working with Allow Over Credit Limit checked or unchecked.
 * Issue 87872
 * Corrected the previous version.
 *
 * SL7.05 51 87872 Hcl-purosan Mon Jul 04 07:08:49 2005
 * Credit Hold is not working with Allow Over Credit Limit checked or unchecked.
 * Issue 87872
 * Called SumCoPriceSp for new price calculation ,for credit hold check.
 *
 * SL7.05 50 87411 vanmmar Tue Jun 07 16:58:22 2005
 * Iup trigger on co & coitem do unneeded actions during planner post processing
 * 87411
 *
 * SL7.05 49 87247 Coatper Mon May 16 11:22:28 2005
 * Unit Price not calculated correctly after changing unit of measure on CO line
 * Issue 87247 - Changed conditions that control whether to run the logic that determines what the coitem.price value and whether it gets updated or not.
 *
 * SL7.05 48 87037 Hcl-kavimah Thu May 12 06:19:36 2005
 * Customer Order Line can be xref'd to a job for a different item
 * Issue 87037,
 * 
 * made changes to validate the reference details
 *
 * SL7.05 47 87109 Grosphi Fri May 06 11:49:45 2005
 * Login blocking when saving large CO's with multi-site replication
 * 1)  minimize RepCoSp and SumCoSp calls
 * 2)  corrected table scan on coitem_all
 *
 * SL7.05 46 86691 Janreu Mon Apr 25 12:32:01 2005
 * Planning fails in Multi Site environment when CO is overshipped
 * Issue 86691 - Minor tweek so that shipping more than ordered is no longer an error to planning.  Marking order as complete will catch this.
 *
 * SL7.05 45 86649 Nicthu Thu Mar 31 07:56:03 2005
 * Migrations Phase 3 fails SL 7.03.08 using a multisite database when converting certain table first
 * Exit immediately if no rows were affected or if triggers are 

 * disabled, before calling dbo.GetSiteDate()  (86649)
 *
 * SL7.05 44 PRJ1311 Hcl-chatpra Thu Mar 31 04:08:37 2005
 * Project # 1311.Call ClrXRefSp in case of Estimates.
 *
 * SL7.05 43 86544 Debmcw Wed Mar 30 14:53:16 2005
 * Error message when changing status to "Planned"
 * 86544
 *
 * SL7.05 42 86659 Grosphi Wed Mar 30 11:28:20 2005
 * Need to Pull Remaing work of  Enhancement 86374 in SL7.05
 * added support for setting item.include_in_net_change_planning
 *
 * SL7.05 41 86537 Hcl-kavimah Wed Mar 23 01:33:59 2005
 * unit of measure change does not get written to coitem_log table.
 * Issue 86537,
 * 
 * added the following line
 * 
 *           ISNULL(@OldUM,0)  <> ISNULL(@UM,0) )
 *
 * SL7.04 40 85889 Hcl-purosan Fri Feb 25 00:55:58 2005
 * Changing lines to complete, changes order header to complete with no warning
 * Issue 85889 - 
 * Removed "Update Co"  statements
 *
 * $NoKeywords: $
 */
CREATE TRIGGER [dbo].[coitem_mstIup]
on [dbo].[coitem_mst]
FOR INSERT, UPDATE
AS

IF @@ROWCOUNT = 0 RETURN

IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.coitem_mstUpdatePenultimate')) > 0
   RETURN
SET NOCOUNT ON

-- Skip trigger operations as required.
IF dbo.SkipBaseTrigger() = 1
   RETURN

DECLARE @Site SiteType
, @ParmsECReport ListYesNoType
, @InsertFlag   TINYINT
SELECT @Site = prm.site
, @ParmsECReport = ec_reporting
FROM parms AS prm with (readuncommitted)
WHERE prm.parm_key = 0
SELECT
  @InsertFlag = CASE
      WHEN EXISTS ( SELECT 1 FROM deleted ) THEN 0
      ELSE 1
  END

DECLARE @CurrparmsCurrCode  CurrCodeType
SELECT TOP 1
   @CurrparmsCurrCode = currparms.curr_code
FROM currparms with (readuncommitted)

DECLARE
  @TaxparmsTwoExchRates ListYesNoType
SELECT TOP 1
  @TaxparmsTwoExchRates = taxparms.two_exch_rates
FROM taxparms WITH (READUNCOMMITTED)

declare @PlacesQtyUnit DecimalPlacesType
select @PlacesQtyUnit = places_qty_unit from invparms with (readuncommitted)

declare @ApsPlannerUpdate ListYesNoType
set @ApsPlannerUpdate = dbo.VariableIsDefined('ApsPlannerUpdate')

DECLARE
  @Severity     INT
, @Infobar      Infobar
, @Infobar2     Infobar
, @WarningMsg   Infobar
, @CalledFromCopy LongListType
, @Partition uniqueidentifier
, @PrevCustNum CustNumType
, @OtherSite SiteType

exec dbo.GetVariableSp
  @VariableName   = 'CopyCoEst'
, @DefaultValue   = null
, @DeleteVariable = 0
, @VariableValue  = @CalledFromCopy OUTPUT
, @Infobar        = @WarningMsg OUTPUT

declare @EdiInOrderPSp ListYesNoType
exec dbo.GetVariableSp
  @VariableName   = 'In.EdiInOrderPSp'
, @DefaultValue   = 0
, @DeleteVariable = 0
, @VariableValue  = @EdiInOrderPSp OUTPUT
, @Infobar        = @WarningMsg OUTPUT

declare @BufferCoitem ListYesNoType
, @SessionID RowPointerType
exec dbo.GetVariableSp
  @VariableName   = 'BufferCoitem'
, @DefaultValue   = 0
, @DeleteVariable = 0
, @VariableValue  = @BufferCoitem OUTPUT
, @Infobar        = @WarningMsg OUTPUT

declare @SkipCoBlnStatusUpdate ListYesNoType
exec dbo.GetVariableSp
  @VariableName   = 'SkipCoBlnStatusUpdate'
, @DefaultValue   = 0
, @DeleteVariable = 1
, @VariableValue  = @SkipCoBlnStatusUpdate OUTPUT
, @Infobar        = @WarningMsg OUTPUT

declare @TmpTaxTablesInUse ListYesNoType
set @TmpTaxTablesInUse = dbo.TmpTaxTablesInUse()
set @SessionID = dbo.SessionIdSp()

/*============   VALIDATION SECTION   ============*/

/*========   CURSOR PROCESSING SECTION    ========*/
DECLARE
  @RowPointer           RowPointer
, @CoNum                CoNumType
, @CoLine               CoLineType
, @CoRelease            CoReleaseType
, @QtyOrderedConv       QtyUnitType
, @OrigQtyOrderedConv   QtyUnitType
, @QtyOrdered           QtyUnitType
, @InQtyOrdered         QtyUnitType
, @OrigQtyOrdered       QtyUnitType
, @UM                   UMType
, @OldUM                UMType
, @Item                 ItemType
, @OldItem              ItemType
, @Whse                 WhseType
, @OldWhse              WhseType
, @QtyShipped           QtyUnitType
, @QtyInvoiced          QtyUnitType
, @OldQtyInvoiced       QtyUnitType
, @CoLcrNum             LcrNumType
, @PriceConv            AmountType
, @OldPriceConv         AmountType
, @Price                AmountType
, @NewTotalPrice        AmountType
, @OldTotalPrice        AmountType
, @OldPrice             AmountType
, @CorpCust             CustNumType
, @CorpCred             Flag
, @RefType              RefTypeIJKPRTType
, @OldRefType           RefTypeIJKPRTType
, @RefNum               CoNumType
, @OldRefNum            CoNumType
, @RefLineSuf           CoLineType
, @OldRefLineSuf        CoLineType
, @RefRelease           CoLineType
, @OldRefRelease        CoLineType
, @RefChanged           Flag
, @JobJob               CoNumType
, @JobSuffix            CoLineType
, @RefLine              CoLineType
, @OldRefLine           CoLineType
, @Status               CoStatusType
, @OldStatus            CoStatusType
, @ConvFactor           UMConvFactorType
, @DueDate              DateType
, @OldDueDate           DateType
, @ItemwhseRowPointer   RowPointerType
, @ItemwhseQtyOnHand    QtyTotlType
, @ItemwhseQtyRsvdCo    QtyTotlType
, @ItemwhseQtyAllocCo   QtyTotlType
, @AddrCurrCode         CurrCodeType
, @ShipSite             SiteType
, @OldShipSite          SiteType
, @OldExportValue       AmountType
, @ExportValue          AmountType
, @CoStat               CoStatusType
, @OldQtyRsvd           QtyUnitType
, @OldQtyShipped        QtyUnitType
, @Cost                 AmountType
, @Disc                 LineDiscType
, @OldDisc              LineDiscType
, @OldProjectedDate     DateType
, @ProjectedDate        DateType
, @QtyReady             QtyUnitType
, @CoitemRowPointer     RowPointerType
, @CoBlnRowPointer      RowPointerType
, @CoMiscCharges        AmountType
, @CoFreight            AmountType
, @Adjust               AmountType
, @CoitemLinePrice      AmountType
, @ICCustItem           CustItemType
, @CustItem             CustItemType
, @CoBlnStat            CoStatusType
, @CoBlnFeatStr         FeatStrType
, @CoStatusChanged      FlagNyType
, @LbrCost              CostPrcType
, @OldLbrCost           CostPrcType
, @MatlCost             CostPrcType
, @OldMatlCost          CostPrcType
, @FovhdCost            CostPrcType
, @OldFovhdCost         CostPrcType
, @VovhdCost            CostPrcType
, @OldVovhdCost         CostPrcType
, @OutCost              CostPrcType
, @OldOutCost           CostPrcType
, @TaxCode1             TaxCodeType
, @OldTaxCode1          TaxCodeType
, @TaxCode2             TaxCodeType
, @OldTaxCode2          TaxCodeType
, @ItemCustAdd          ListYesNoType
, @ItemCustUpdate       ListYesNoType
, @ChgdQtyReady         Flag
, @OrigSite             SiteType
, @PrgBillTot           AmountType
, @PrgBillApp           AmountType
, @OldPrgBillTot        AmountType
, @OldPrgBillApp        AmountType
, @OldQtyReturned       QtyUnitType
, @QtyReturned          QtyUnitType
, @Reprice              ListYesNoType
, @CalcTaxFlag          ListYesNoType
, @FeatStr              FeatStrType
, @OldFeatStr              FeatStrType
, @QtyRsvd              QtyUnitNoNegType
, @QtyPacked            QtyUnitNoNegType
, @Packed               ListYesNoType
, @ShipDate             DateType
, @UnitWeight           UnitWeightType
, @SyncReqd             ListYesNoType -- used to set replication to other sites
, @CoOrigSite           SiteType
, @CoCustNum            CustNumType
, @CoCustSeq            CustSeqType
, @CoDisc               OrderDiscType
, @CoType               CoTypeType
, @CoPrice              AmountType
, @CoOrderDate          DateType
, @CoFixedRate          ListYesNoType
, @CoExchRate           ExchRateType
, @WhereClause          LongListType
, @Description          DescriptionType
, @CustNum              CustNumType
, @CustSeq              CustSeqType
, @ReleaseDate          DateType
, @CommCode             CommodityCodeType
, @TransNat             TransNatType
, @TransNat2            TransNat2Type
, @ProcessInd           ProcessIndType
, @Delterm              DeltermType
, @SupplQtyConvFactor   UMConvFactorType
, @Origin               EcCodeType
, @ConsNum              ConsignmentsType
, @EcCode               EcCodeType
, @Transport            TransportType
, @PromiseDate          DateType
, @CoitemCustNum        CustNumType
, @Pricecode            PriceCodeType
, @CurrLineNet          AmountType
, @OldLineNet           AmountType
, @LcrValuesChanged     ListYesNoType
--, @TraceMsg           InfobarType
, @OnlyStatChanged ListYesNoType
, @MrpParmReqSrc MrpReqSrcType
, @LbrCostConv          CostPrcType
, @MatlCostConv         CostPrcType
, @FovhdCostConv        CostPrcType
, @VovhdCostConv        CostPrcType
, @OutCostConv          CostPrcType
, @CostConv             CostPrcType
, @CoRowPointer         RowPointer
, @PlanOnSave           ListYesNoType
, @ConfigId             ConfigIdType
, @ItemCurUCost         CostPrcType
, @CreditHoldReason     ReasonCodeType
, @AllowOverCreditLimit ListYesNoType
, @CoConsignment        ListYesNoType
, @CoWhse               WhseType
, @oldNonInvAcct        AcctType
, @newNonInvAcct        AcctType
, @oldNonInvAcctUnit1   UnitCode1Type
, @newNonInvAcctUnit1   UnitCode1Type
, @oldNonInvAcctUnit2   UnitCode2Type
, @newNonInvAcctUnit2   UnitCode2Type
, @oldNonInvAcctUnit3   UnitCode3Type
, @newNonInvAcctUnit3   UnitCode3Type
, @oldNonInvAcctUnit4   UnitCode4Type
, @newNonInvAcctUnit4   UnitCode4Type
, @NonInventoryItem     FlagNyType
, @oldNonInvCostConv    CostPrcType
, @newNonInvCostConv    CostPrcType
, @TRate                ExchRateType
, @Priority             ApsSmallIntType
, @OldPriority          ApsSmallIntType
, @ManufacturerId       ManufacturerIdType
, @ManufacturerItem     ManufacturerItemType
, @AutoShipDemandingSiteCO ListYesNoType
, @ParmsSite                 SiteType
, @PortalOrder           ListYesNoType
, @FromEcCode EcCodeType
, @ToEcCode EcCodeType
, @PromiseDate121Str    NVARCHAR(100)
, @DueDate121Str        NVARCHAR(100)
, @ReleaseDate121Str    NVARCHAR(100)
, @ProjectedDate121Str  NVARCHAR(100)
, @ShipDate121Str       NVARCHAR(100)

-- ZPV
, @ZpvPos				varchar(20)

DECLARE @SavedState LongListType

declare @CoStatus table (
  co_num CoNumType primary key
)
declare @Forecast table (
  item ItemType primary key
)
declare @NetChange table (
  item ItemType primary key
)
declare @RepCo table (
  co_num CoNumType
, ship_site SiteType
, curr_code CurrCodeType
primary key (co_num, ship_site)
)
declare @SumCo table (
  co_num CoNumType
, site SiteType
, update_order_bal bit
, orig_price CostPrcType
, adjustment CostPrcType
primary key (site, co_num)
)

-- ZLA BEGIN
DECLARE
  @ZlaForPrice			AmountType
, @ZlaForPriceConv		AmountType
-- ZLA END


SET @Severity   =  0
SET @Adjust = 0
set @PrevCustNum = ''

set @PlanOnSave = ISNULL(dbo.DefinedValue('PlanOnSave'),1)
SET @NonInventoryItem = 0

exec dbo.GetVariableSp
  @VariableName   = 'CoitemItemCustAdd'
, @DefaultValue   = 0
, @DeleteVariable = 1
, @VariableValue  = @ItemCustAdd OUTPUT
, @Infobar        = @WarningMsg OUTPUT

exec dbo.GetVariableSp
  @VariableName   = 'CoitemItemCustUpd'
, @DefaultValue   = 0
, @DeleteVariable = 1
, @VariableValue  = @ItemCustUpdate OUTPUT
, @Infobar        = @WarningMsg OUTPUT


SELECT
  @CreditHoldReason = limit_exc_credit_hold_reason
FROM arparms WITH (READUNCOMMITTED)

select @MrpParmReqSrc = req_src from mrp_parm WITH (READUNCOMMITTED)

if @BufferCoitem = 1
begin
   insert into @SumCo
   select substring(VariableName, 7, 10)
   , substring(VariableName, 17, 10)
   , substring(VariableValue, 1, 1)
   , dbo.Entry(2, VariableValue, '|')
   , dbo.Entry(3, VariableValue, '|')
   from DefineVariables with (readuncommitted)
   where ConnectionID = @SessionID
   and ProcessID = -1
   and VariableName like 'SumCo=%'

   insert into @RepCo
   select substring(VariableName, 7, 10)
   , substring(VariableName, 17, 10)
   , VariableValue
   from DefineVariables with (readuncommitted)
   where ConnectionID = @SessionID
   and ProcessID = -1
   and VariableName like 'RepCo=%'
end

SET @ParmsSite = @Site 

DECLARE coitem_mstIupCrs CURSOR LOCAL STATIC READ_ONLY
FOR SELECT
  ii.RowPointer
, ii.co_num
, ii.co_line
, ii.co_release
, ii.qty_ordered_conv
, ISNULL (dd.qty_ordered_conv, 0)
, ii.qty_ordered
, ISNULL (dd.qty_ordered, 0)
, co.cust_num
, co.cust_seq
, co.stat
, co.disc
, co.price
, ii.ship_site
, dd.ship_site
, ii.u_m
, dd.u_m
, ii.item
, dd.item
, ii.cust_item
, ii.whse
, dd.whse
, ii.qty_shipped
, isnull(dd.qty_shipped, 0)
, ii.qty_invoiced
, dd.qty_invoiced
, co.lcr_num
, ii.price
, dd.price
, ii.price_conv
, dd.price_conv
, ii.disc
, dd.disc
, adr.corp_cust
, adr.corp_cred
, adr.curr_code
, ii.co_orig_site
, ii.ref_type
, dd.ref_type
, ii.ref_num
, dd.ref_num
, ii.ref_line_suf
, dd.ref_line_suf
, ii.ref_release
, dd.ref_release
, ii.stat
, dd.stat
, co.type
, co.order_date
, co.fixed_rate
, co.exch_rate
, ii.due_date
, dd.due_date
, ii.projected_date
, dd.projected_date
, dd.export_value
, ii.export_value
, co.misc_charges
, co.freight
, cbl.stat
, cbl.feat_str
, ii.lbr_cost
, dd.lbr_cost
, ii.matl_cost
, dd.matl_cost
, ii.fovhd_cost
, dd.fovhd_cost
, ii.vovhd_cost
, dd.vovhd_cost
, ii.out_cost
, dd.out_cost
, ii.tax_code1
, dd.tax_code1
, ii.tax_code2
, dd.tax_code2
, ii.qty_ready
, co.orig_site
, isnull(ii.prg_bill_tot, 0)
, isnull(dd.prg_bill_tot, 0)
, isnull(ii.prg_bill_app, 0)
, isnull(dd.prg_bill_app, 0)
, dd.qty_returned
, ii.qty_returned
, ii.reprice
, ii.feat_str
, dd.feat_str
, ii.cust_num
, ii.cust_seq
, ii.release_date
, ii.promise_date
, ii.comm_code
, ii.trans_nat
, ii.trans_nat_2
, ii.process_ind
, ii.delterm
, ii.suppl_qty_conv_factor
, ii.origin
, ii.cons_num
, ii.ec_code
, ii.pricecode
, ii.co_cust_num
, ii.transport
, ii.description
, ii.qty_rsvd
, dd.qty_rsvd
, ii.qty_packed
, ii.packed
, ii.ship_date
, ii.unit_weight
, ii.sync_reqd
, ii.lbr_cost_conv
, ii.matl_cost_conv
, ii.fovhd_cost_conv
, ii.vovhd_cost_conv
, ii.out_cost_conv
, co.RowPointer
, ii.config_id
, co.consignment
, co.whse
, dd.non_inv_acct  
, ii.non_inv_acct  
, dd.non_inv_acct_unit1  
, ii.non_inv_acct_unit1  
, dd.non_inv_acct_unit2  
, ii.non_inv_acct_unit2  
, dd.non_inv_acct_unit3  
, ii.non_inv_acct_unit3  
, dd.non_inv_acct_unit4  
, ii.non_inv_acct_unit4  
, dd.cost_conv
, ii.cost_conv
, dd.priority
, ii.priority
, ii.manufacturer_id
, ii.manufacturer_item
, co.portal_order
-- ZLA
, ii.zla_for_price_conv
-- ZPV
, co.zpv_pos
FROM inserted ii
LEFT OUTER JOIN co_bln AS cbl ON
    cbl.co_num  = ii.co_num
AND cbl.co_line = ii.co_line
INNER JOIN co ON
  co.co_num = ii.co_num
LEFT OUTER JOIN deleted AS dd ON
  dd.RowPointer = ii.RowPointer
LEFT OUTER JOIN custaddr AS adr ON
    adr.cust_num = co.cust_num
AND adr.cust_seq = co.cust_seq

OPEN coitem_mstIupCrs


declare @HasTaxSystem2 ListYesNoType
if @@cursor_rows > 4 and @InsertFlag = 1
   set @HasTaxSystem2 = case when (select 1 from tax_system with (readuncommitted) where tax_system.tax_system = 2) = 1 then 1 else 0 end
else
   set @HasTaxSystem2 = 1

declare @Itemwhse table (
  item nvarchar(40)
, whse nvarchar(40)
, qty_alloc_co decimal(25,10)
primary key(item, whse)
)
declare @Itemcust table (
  cust_num nvarchar(20)
, item nvarchar(40)
, purch_ytd decimal(25,10)
, order_ytd decimal(25,10)
, order_ptd decimal(25,10)
primary key (cust_num, item)
)
declare @BufferItemwhse ListYesNoType
, @ItemcustPurchYtd AmtTotType
, @ItemcustOrderYtd AmtTotType
, @ItemcustOrderPtd AmtTotType
, @ItemwhseQtyAllocCoOld AmtTotType
, @ItemwhseQtyAllocCoNew AmtTotType

set @BufferItemwhse = case when @@cursor_rows > 4 then 1 else 0 end

WHILE @Severity = 0
BEGIN /* cursor loop */
   FETCH coitem_mstIupCrs INTO
     @RowPointer
   , @CoNum
   , @CoLine
   , @CoRelease
   , @QtyOrderedConv
   , @OrigQtyOrderedConv
   , @InQtyOrdered
   , @OrigQtyOrdered
   , @CoCustNum
   , @CoCustSeq
   , @CoStat
   , @CoDisc
   , @CoPrice
   , @ShipSite
   , @OldShipSite
   , @UM
   , @OldUM
   , @Item
   , @OldItem
   , @CustItem
   , @Whse
   , @OldWhse
   , @QtyShipped
   , @OldQtyShipped
   , @QtyInvoiced
   , @OldQtyInvoiced
   , @CoLcrNum
   , @Price
   , @OldPrice
   , @PriceConv
   , @OldPriceConv
   , @Disc
   , @OldDisc
   , @CorpCust
   , @CorpCred
   , @AddrCurrCode
   , @CoOrigSite
   , @RefType
   , @OldRefType
   , @RefNum
   , @OldRefNum
   , @RefLineSuf
   , @OldRefLineSuf
   , @RefRelease
   , @OldRefRelease
   , @Status
   , @OldStatus
   , @CoType
   , @CoOrderDate
   , @CoFixedRate
   , @CoExchRate
   , @DueDate
   , @OldDueDate
   , @ProjectedDate
   , @OldProjectedDate
   , @OldExportValue
   , @ExportValue
   , @CoMiscCharges
   , @CoFreight
   , @CoBlnStat
   , @CoBlnFeatStr
   , @LbrCost
   , @OldLbrCost
   , @MatlCost
   , @OldMatlCost
   , @FovhdCost
   , @OldFovhdCost
   , @VovhdCost
   , @OldVovhdCost
   , @OutCost
   , @OldOutCost
   , @TaxCode1
   , @OldTaxCode1
   , @TaxCode2
   , @OldTaxCode2
   , @QtyReady
   , @OrigSite
   , @PrgBillTot
   , @OldPrgBillTot
   , @PrgBillApp
   , @OldPrgBillApp
   , @OldQtyReturned
   , @QtyReturned
   , @Reprice
   , @FeatStr
   , @OldFeatStr
   , @CustNum
   , @CustSeq
   , @ReleaseDate
   , @PromiseDate
   , @CommCode
   , @TransNat
   , @TransNat2
   , @ProcessInd
   , @Delterm
   , @SupplQtyConvFactor
   , @Origin
   , @ConsNum
   , @EcCode
   , @Pricecode
   , @CoitemCustNum
   , @Transport
   , @Description
   , @QtyRsvd
   , @OldQtyRsvd
   , @QtyPacked
   , @Packed
   , @ShipDate
   , @UnitWeight
   , @SyncReqd
   , @LbrCostConv
   , @MatlCostConv
   , @FovhdCostConv
   , @VovhdCostConv
   , @OutCostConv
   , @CoRowPointer
   , @ConfigId
   , @CoConsignment
   , @CoWhse
   , @oldNonInvAcct
   , @newNonInvAcct
   , @oldNonInvAcctUnit1
   , @newNonInvAcctUnit1
   , @oldNonInvAcctUnit2
   , @newNonInvAcctUnit2
   , @oldNonInvAcctUnit3
   , @newNonInvAcctUnit3
   , @oldNonInvAcctUnit4
   , @newNonInvAcctUnit4
   , @oldNonInvCostConv
   , @newNonInvCostConv
   , @OldPriority
   , @Priority
   , @ManufacturerId
   , @ManufacturerItem
   , @PortalOrder
   -- ZLA
   , @ZlaForPriceConv
   -- ZPV
   , @ZpvPos

   IF @@FETCH_STATUS = -1
      BREAK

   SET @OldRefLineSuf = ISNULL(@OldRefLineSuf,0)
   SET @OldRefRelease = ISNULL(@OldRefRelease,0)
   SET @RefLineSuf    = ISNULL(@RefLineSuf,0)
   SET @RefRelease    = ISNULL(@RefRelease,0)
   SET @NonInventoryItem = 0

   -- set default value for column ref_type if trying to insert or update Null value
   IF @RefType IS NULL BEGIN
   EXEC   @Severity = dbo.GetItemRefSp    
          @Item       = @Item    
        , @CalledFrom = 'C'    
        , @RefType    = @RefType  OUTPUT     
        , @Infobar    = @Infobar  OUTPUT     
        , @Site       = @Site 
      UPDATE coitem
         SET ref_type = @RefType
      WHERE RowPointer = @RowPointer
   END
   
   IF CHARINDEX(@CoType, 'BR') > 0 AND @CustNum IS NULL
   and (@CustSeq is null or @CustSeq != 0)
      UPDATE coitem
         SET cust_seq = 0
      WHERE RowPointer = @RowPointer

   -- set coitem.co_cust_num whether CO Type is R/B/E
   IF (ISNULL(@CoitemCustNum, '') != ISNULL(@CoCustNum, '')) AND @CoCustNum IS NOT NULL
   BEGIN
      UPDATE coitem
         SET coitem.co_cust_num = @CoCustNum
      WHERE coitem.RowPointer = @RowPointer
   END

   /* if item does not exist in item master, set non-inventroy-item */
   IF NOT EXISTS (SELECT 1 FROM item_all WITH (READUNCOMMITTED) WHERE item_all.item = @Item and site_ref = @ShipSite)
      SET @NonInventoryItem = 1
   IF @NonInventoryItem = 1
      UPDATE non_inventory_item
      SET unit_cost = @newNonInvCostConv
      , unit_price = @PriceConv
      WHERE item=@Item

   /* if customer order is consigned order, warehouse should be valid customer consignment warehouse acorrding to 
      current customer's ship-to.
   */
   IF @CoConsignment = 1
   AND NOT EXISTS (SELECT 1
                   FROM   [dbo].[whse_all] with (readuncommitted)
                   WHERE  [cust_num] = @CoCustNum
                          AND [cust_seq] = @CoCustSeq
                          AND [site_ref] = @ShipSite
                          AND [consignment_type] = 'C'
                          AND [whse] = @Whse)
    BEGIN
        EXECUTE @Severity = dbo.MsgAppSp @Infobar OUTPUT
        , 'E=NoExist5'
        , '@whse'
        , '@site'
        , @ShipSite
        , '@co.cust_num'
        , @CoCustNum
        , '@co.cust_seq'
        , @CoCustSeq
        , '@whse'
        , @Whse
        , '@whse.consignment_type'
        , '@co.cust_num'
        
        BREAK
    END



   -- In case of Non-Inventoried Item, make sure account is filled in  
   IF @NonInventoryItem = 1 AND @newNonInvAcct IS NULL AND @CoType <> 'E'
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT
      , 'E=NoCompare3'
      , '@coitem.non_inv_acct', @newNonInvAcct
      , '@coitem'
      , '@coitem.co_num', @CoNum
      , '@coitem.co_line', @CoLine
      , '@coitem.co_release', @CoRelease
      IF @Severity <> 0 BREAK
   END

   if @InsertFlag = 1 or isnull(@FeatStr, '') != isnull(@OldFeatStr, '')
      -- split the IF because SQL does not stop on the first FALSE expression
      if exists (select 1 from item WITH (READUNCOMMITTED) where item.plan_flag = 1 and item.item = @Item)
      begin
         exec @Severity = dbo.FeatStrValidateSp
           @FeatStr = @FeatStr
         , @Item = @Item
         , @Infobar = @Infobar output
         , @Site = @ShipSite
         if @Severity != 0
         begin
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=IsCompare3'
            , '@item'
            , @Item
            , '@coitem'
            , '@coitem.co_num'
            , @CoNum
            , '@coitem.co_line'
            , @CoLine
            , '@coitem.co_release'
            , @CoRelease
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=IsCompare0'
            , '@item.plan_flag'
            , '@:ListYesNo:1'
            , '@item'
            break
         end
      end

-- If the Blanket Line is configurable, copy the Feature String to the Release (Issue # 72383)
   IF @InsertFlag = 1 AND @CoType = 'B' AND @CoBlnFeatStr IS NOT NULL
   BEGIN
      UPDATE coitem
      SET coitem.feat_str = @CoBlnFeatStr
      WHERE RowPointer = @RowPointer
   END

   SET @ShipSite = dbo.DefaultToLocalSite (@ShipSite)
   IF @InsertFlag = 1
   BEGIN
      IF  @CoType = 'B' AND @CoRelease IS NULL
         EXEC @Severity = dbo.NextReleaseSp
           @CoNum
         , @CoLine
         , @CoRelease  OUTPUT
         , @Infobar    OUTPUT

      IF  @CoType <> 'B' AND @CoLine IS NULL
         EXEC @Severity = dbo.NextLineSp
           @CoNum
         , @CoRelease
         , @CoLine  OUTPUT
         , @Infobar OUTPUT

      IF @Severity <> 0
         BREAK

         -- check customer for credit hold
      if @PrevCustNum != @CoCustNum and @Site = @OrigSite
      begin
         EXEC dbo.ChkcredSp
           @CoCustNum
         , @Infobar  OUTPUT

         set @PrevCustNum = @CoCustNum
      end
   END

   -- list all conditions which might need @ConvFactor.
   -- we want to avoid unnecessary database access
   -- and avoid referencing u_m_all.
   IF @InsertFlag = 1
   OR UPDATE (qty_ordered_conv)
   or update(u_m)
   or update(item)
   or update(price)
   or update(price_conv)
   or update(disc)
   or update(stat)
   or update(qty_shipped)
   or update(qty_invoiced)
   or update(qty_returned)
   or update(prg_bill_tot)
   or update(prg_bill_app)
   or update(due_date)
   or update(ship_site)
   or update(matl_cost_conv)
   or update(lbr_cost_conv)
   or update(fovhd_cost_conv)
   or update(vovhd_cost_conv)
   or update(out_cost_conv)
   or update(export_value)
   or @CoType = 'E'
   begin
      exec @Severity = dbo.GetumcfSp
        @OtherUM = @UM
      , @Item = @Item
      , @VendNum = @CoCustNum
      , @Area = 'C'
      , @ConvFactor = @ConvFactor output
      , @Infobar = @Infobar output
      , @Site = @ShipSite
      if @Severity <> 0
         break
   end

   -- The qty ordered is converted to the base item unit of measure.
   SET @QtyOrdered = @InQtyOrdered
   IF UPDATE (qty_ordered_conv) or @UM <> @OldUM
      SET @QtyOrdered  = dbo.UomConvQty ( @QtyOrderedConv, @ConvFactor, 'To Base')

   if @InsertFlag = 1 or @UM <> @OldUM or @PriceConv != @OldPriceConv
      SET   @Price = dbo.UomConvAmt(@PriceConv, @ConvFactor, 'To Base')
      
      SET @ZlaForPrice = dbo.UomConvAmt(@ZlaForPriceConv, @ConvFactor, 'To Base')
   
   IF @ParmsECReport = 1
   AND EXISTS ( SELECT 1 FROM item_all WITH (READUNCOMMITTED)
                WHERE item = @Item
                AND site_ref = @ShipSite )
   BEGIN
      SET @ExportValue = ISNULL(@ExportValue, 0.0)

      -- if SSD Value is zero
      IF @ExportValue = 0.0
      BEGIN
         -- if SSD Value is zero set it to Unit Price
         SET @ExportValue = ISNULL(@PriceConv, 0.0)

         declare @CurrencyPlaces DecimalPlacesType
         set @CurrencyPlaces = 2
         select @CurrencyPlaces = places
         from currency with (readuncommitted)
         where currency.curr_code = @AddrCurrCode

         SET @ExportValue = round(CASE WHEN @CoType = 'B'
               then @ExportValue
               else (@ExportValue * (1.0 - @Disc / 100.0))
            END, @CurrencyPlaces)
         SET @ExportValue = @ExportValue - round(@ExportValue * (@CoDisc / 100.0), @CurrencyPlaces)

         -- if Unit Price is zero set it to Item's Unit Cost (converted to CO Line/Release UM and customer's currency))
         IF @ExportValue = 0.0
         BEGIN
            SELECT @ItemCurUCost = cur_u_cost
            FROM item_all WITH (READUNCOMMITTED)
            WHERE item = @Item
            AND site_ref = @ShipSite

            -- convert Item's Unit Cost from base UM to CO Line/Release UM
            SET @ItemCurUCost = ISNULL(dbo.UomConvAmt(@ItemCurUCost, @ConvFactor, 'From Base'), 0)

            -- convert Item's Unit Cost from domestic to Customer's currency
            SET @TRate = CASE WHEN @CoFixedRate = 1 THEN @CoExchRate ELSE NULL END
            EXEC @Severity = dbo.CurrCnvtSp
                 @CurrCode     = @AddrCurrCode
               , @UseCustomsAndExciseRates = @TaxparmsTwoExchRates
               , @FromDomestic = 1
               , @UseBuyRate   = 0
               , @RoundResult  = 0
               , @Date         = @CoOrderDate
               , @TRate        = @TRate  OUTPUT
               , @Infobar      = @Infobar  OUTPUT
               , @Amount1      = @ItemCurUCost
               , @Result1      = @ExportValue  OUTPUT
               , @Site         = @Site
               , @DomCurrCode  = @CurrparmsCurrCode

            IF @Severity <> 0
               BREAK

            -- if Item's Unit Cost is not zero display a warning message
            IF @ExportValue <> 0.0
            BEGIN
               EXEC dbo.MsgAppSp @WarningMsg OUTPUT, 'E=NoCompare'
                  , '@coitem.export_value'
                  , '0'
               EXEC dbo.MsgAppSp @WarningMsg OUTPUT, 'I=WillSet0'
                  , '@coitem.export_value'
                  , '@item.cur_u_cost'
               EXEC dbo.WarningSp @WarningMsg
               SET @WarningMsg = NULL
            END
            ELSE -- if Item's Unit Cost is zero display an error message
            BEGIN
               select @FromEcCode = from_ec.ssd_ec_code
               FROM whse_all with (readuncommitted)
                  inner join country_all as from_ec with (readuncommitted) on
                     from_ec.site_ref = @ShipSite
                     and from_ec.country = whse_all.country
               where whse_all.site_ref = @ShipSite
               and whse_all.whse = @Whse

               select @ToEcCode = to_ec.ssd_ec_code
               from custaddr with (readuncommitted)
                  inner join country_all as to_ec with (readuncommitted) on
                     to_ec.site_ref = @ShipSite
                     and to_ec.country = custaddr.country
               where custaddr.cust_num = @CoCustNum
               and custaddr.cust_seq = @CoCustSeq

               if @FromEcCode is not null
               and @ToEcCode is not null
               and @FromEcCode != @ToEcCode
               begin
                  EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare1'
                              , '@coitem.export_value'
                              , '0'
                              , '@coitem'
                              , '@coitem.price'
                              , '0'
                  IF @Severity <> 0
                     BREAK
               end
            END
         END -- if Unit Price is zero
      END -- if SSD Value is zero

      UPDATE coitem
         SET export_value = @ExportValue
      WHERE RowPointer = @RowPointer
   END

   -- Create or update the itemcust record to have a matching cust_item.
   IF UPDATE (cust_item) AND @CustItem IS NOT NULL
         AND @NonInventoryItem <> 1
   BEGIN
      SET @ICCustItem = NULL
      SELECT @ICCustItem = ic.cust_item
      FROM itemcust AS ic with (readuncommitted)
      WHERE ic.cust_num = @CoCustNum
      AND   ic.item     = @Item
      AND   ISNULL(ic.cust_item, NCHAR(1)) = ISNULL(@CustItem, NCHAR(1))

      IF @ICCustItem IS NULL AND @@ROWCOUNT = 0 AND @ItemCustAdd = 1
      BEGIN
         Declare @CustItemSeq CustItemSeqType
         Select @CustItemSeq = (Max(cust_item_seq) + 1) from itemcust with (readuncommitted)
         where item = @Item and cust_num = @CoCustNum
         If @CustItemSeq is null 
            Set @CustItemSeq = 1

         INSERT INTO itemcust (cust_num, item, u_m, cust_item,cust_item_seq)
         VALUES (@CoCustNum, @Item, @UM, @CustItem , @CustItemSeq) 
         IF @@ERROR <> 0
            BREAK
      END
   END -- Updating cust_item

   IF (@RefType = 'I' AND ISNULL(@OldQtyRsvd, 0) = 0)
         AND (@InsertFlag =1 or (@Item <> @OldItem OR @Whse <> @OldWhse ) )
         AND @NonInventoryItem <> 1
   BEGIN
      SET @ItemwhseRowPointer = NULL
      SET @ItemwhseQtyOnHand  = 0
      SET @ItemwhseQtyRsvdCo  = 0
      SET @ItemwhseQtyAllocCo = 0

      SELECT
        @ItemwhseRowPointer = itemwhse_all.RowPointer
      , @ItemwhseQtyOnHand  = itemwhse_all.qty_on_hand
      , @ItemwhseQtyRsvdCo  = itemwhse_all.qty_rsvd_co
      , @ItemwhseQtyAllocCo = itemwhse_all.qty_alloc_co
      FROM itemwhse_all with (readuncommitted)
      WHERE itemwhse_all.item = @Item AND
        itemwhse_all.whse = @Whse AND
        itemwhse_all.site_ref = @ShipSite

      IF @ItemwhseRowPointer IS NOT NULL
         UPDATE coitem
         SET qty_ready = case
             when (@ItemwhseQtyOnHand - @ItemwhseQtyRsvdCo) >= (@QtyOrdered - @OldQtyShipped)
             and (@QtyOrdered - @OldQtyShipped) > 0
             then @QtyOrdered - @OldQtyShipped
             when (@ItemwhseQtyOnHand - @ItemwhseQtyRsvdCo) < (@QtyOrdered - @OldQtyShipped)
             and (@ItemwhseQtyOnHand - @ItemwhseQtyRsvdCo) > 0
             then (@ItemwhseQtyOnHand - @ItemwhseQtyRsvdCo)
             else 0
             end
         WHERE RowPointer = @RowPointer
   END

   if @OldRefType = 'I' and @RefType in ('J', 'P', 'T')
   and @CoType != 'E'
   and @Status in ('P', 'O', 'F')
   begin
      set @QtyReady = 0

      if @RefNum is not null
      begin
         if @RefType = 'J'
            select @QtyReady = qty_complete
            from job with (readuncommitted)
            where job.type = 'J'
            and job.job = @RefNum
            and job.suffix = @RefLineSuf
         else if @RefType = 'P'
            select @QtyReady = qty_received
            from poitem with (readuncommitted)
            where poitem.po_num = @RefNum
            and poitem.po_line = @RefLineSuf
            and poitem.po_release = @RefRelease
         else if @RefType = 'T'
            select @QtyReady = qty_received
            from trnitem with (readuncommitted)
            where trnitem.trn_num = @RefNum
            and trnitem.trn_line = @RefLineSuf
      end

      set @QtyReady = dbo.MinQty(@QtyReady, @QtyOrdered - @OldQtyShipped + @QtyReturned - @QtyRsvd)

      update coitem
      set qty_ready = @QtyReady
      where RowPointer = @RowPointer
      and qty_ready != @QtyReady
   end

   IF ISNULL(@OldRefNum,CHAR(1)) <> ISNULL(@RefNum,CHAR(1)) OR
      ISNULL(@OldRefLineSuf,0)  <> ISNULL(@RefLineSuf,0)    OR
      ISNULL(@OldRefRelease,0 ) <> ISNULL(@RefRelease,0) OR
     (ISNULL(@OrigQtyOrderedConv,0) <> ISNULL(@QtyOrderedConv,0) AND
     @OldRefType = 'I' )
      SET @RefChanged = 1
   ELSE
      SET @RefChanged = 0

   IF @CoType <>'E' AND(@RefChanged = 1 OR (ISNULL(@RefType,CHAR(1)) <> ISNULL(@OldRefType,CHAR(1))
     AND @InsertFlag = 0)) AND @Site = @ShipSite
   BEGIN
      IF @OldRefType = 'J' AND @OldRefNum IS NOT NULL
      BEGIN
         insert into DefineVariables (ConnectionID, ProcessID, VariableName, VariableValue)
         select @SessionId, -1, 'ClrXrefBulk:' + convert(nvarchar(36), RowPointer)
         , isnull(@OldRefType, '')
            + char(1) + isnull(job, '')
            + char(1) + cast(isnull(suffix, '-1') as nvarchar)
            + char(1) + cast(isnull(@OldRefRelease, '-1') as nvarchar)
            + char(1) + isnull(@CoNum, '')
            + char(1) + cast(isnull(@CoLine, '-1') as nvarchar)
            + char(1) + cast(isnull(@CoRelease, '-1') as nvarchar)
         from job with (readuncommitted)
         where job.root_job = @OldRefNum
         and job.root_suf = @OldRefLineSuf

         exec @Severity = dbo.ClrXrefBulkSp
           @ProcessId = @SessionId
         , @Infobar = @Infobar output
      END -- IF @OldRefType = 'J' AND @OldRefNum IS NOT NULL
      ELSE
      BEGIN
         EXEC @Severity = dbo.ClrXrefSp
           @RefType = @OldRefType
         , @RefNum = @OldRefNum
         , @RefLine = @OldRefLineSuf
         , @RefRel = @OldRefRelease
         , @ParNum = @CoNum
         , @ParLine = @CoLine
         , @ParRel = @CoRelease
         , @Infobar = @Infobar OUTPUT

         if @Severity <> 0
            break
      END

      EXEC @Severity = dbo.ChkXrefAllSp
        @CoNum = @CoNum
      , @CoLine = @CoLine
      , @CoRelease = @CoRelease
      , @OldRefType = @OldRefType
      , @NewRefType = @RefType
      , @NewRefNum = @RefNum
      , @NewRefLineSuf = @RefLineSuf
      , @NewRefRel = @RefRelease
      , @NewItem = @Item
      , @ShipSite = @ShipSite
      , @Infobar = @Infobar   OUTPUT

      IF @Severity <> 0
         BREAK
   END
   ELSE
   BEGIN
      IF @OldRefType <> 'I' AND @OldRefNum IS NOT NULL AND
      (ISNULL(@RefType,CHAR(1)) <> ISNULL(@OldRefType,CHAR(1)) OR ISNULL(@RefNum,0) <> ISNULL(@OldRefNum,0)
      OR ISNULL(@RefLineSuf,0) <> ISNULL(@OldRefLineSuf,0 )OR ISNULL(@RefRelease,0) <> ISNULL(@OldRefRelease,0))
      BEGIN
         EXEC @Severity = dbo.ClrXrefSp
           @RefType  = @OldRefType
         , @RefNum   = @OldRefNum
         , @RefLine  = @OldRefLineSuf
         , @RefRel   = @OldRefRelease
         , @ParNum   = @CoNum
         , @ParLine  = @CoLine
         , @ParRel   = @CoRelease
         , @Infobar  = @Infobar OUTPUT

          IF @Severity <> 0
            BREAK

         IF ISNULL(@ConfigId,'') <> '' AND
           (ISNULL(@OldItem,CHAR(1)) <> ISNULL(@Item,CHAR(1)) AND ISNULL(@OldItem,'') <> '') 
         BEGIN
            UPDATE coitem
            SET config_id = NULL 
            WHERE RowPointer = @RowPointer
 
            SET @Severity = @@ERROR
            IF @Severity <> 0
               BREAK
         END
      END
   END

------------------
-- Multi-Site
------------------
   IF @CoType <>'E' AND @Site <> @ShipSite
   BEGIN
      if not exists (select 1 from @RepCo where co_num = @CoNum and ship_site = @ShipSite)
      begin
         IF (@InsertFlag = 1 AND @ShipSite <> @CoOrigSite)
             OR @ShipSite <> @OldShipSite
         BEGIN

            insert into @RepCo
            values (@CoNum, @ShipSite, @CurrparmsCurrCode)

            EXEC @Severity = dbo.RepCoSp
              @pDestSite = @ShipSite -- copy to this ship-site
            , @pCoNum    = @CoNum
            , @pCurrCode = @CurrparmsCurrCode
            , @Infobar = @Infobar OUTPUT

            IF @Severity != 0
               BREAK
         END
      end
   END -- IF @CoType <>'E' AND @Site <> @ShipSite

    -- If changing Status to complete, check QtyShipped vs. QtyInvoiced
    -- This code may be packaged in a called routine. More logic may need
    -- to be added here (tpb)

   IF @CoType <> 'E' and
     ISNULL(@OldStatus, CHAR(1)) <> 'C' AND ISNULL(@Status, CHAR(1)) = 'C'
   BEGIN
      IF round(@QtyShipped - @QtyReturned - @QtyInvoiced, @PlacesQtyUnit) != 0
      BEGIN
         EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=IsCompare<>3',
           '@coitem.qty_shipped', '@coitem.qty_invoiced'
         , '@coitem'
         , '@coitem.co_num', @CoNum
         , '@coitem.co_line', @CoLine
         , '@coitem.co_release', @CoRelease
         if @QtyReturned > 0
            EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=IsCompare',
              '@coitem.qty_returned', @QtyReturned
         IF @Severity <> 0
            BREAK
      END
   END

    --  The qty ordered cannot be less than the qty shipped.

   IF round(@QtyOrdered - @QtyShipped, @PlacesQtyUnit) < 0 AND (
      @QtyOrderedConv <> @OrigQtyOrderedConv)
   BEGIN
      EXEC @Severity = dbo.MsgAppSp
        @Infobar OUTPUT
      , 'E=NoCompare>'
      , '@coitem.qty_shipped'
      , '@coitem.qty_ordered'

      IF @Severity <> 0
         BREAK
   END

   -- Check whether there is any remaining progressive billing amount to be applied
   IF (@InsertFlag = 0 AND @CoType = 'R' AND @CoOrigSite = @Site AND
       ISNULL(@OldStatus, CHAR(1)) <> 'C' AND ISNULL(@Status, CHAR(1)) = 'C' AND
       ISNULL(@PrgBillTot, 0) <> ISNULL(@PrgBillApp, 0)
      )
   BEGIN
      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'E=NoCompare2'
                     , '@coitem.stat'
                     , '@:CoitemStatus:C'
                     , '@coitem'
                     , '@coitem.co_num'
                     , @CoNum
                     , '@coitem.co_line'
                     , @CoLine

      EXEC @Severity = dbo.MsgAppSp @Infobar OUTPUT, 'I=NotEqual'
                     , '@coitem.prg_bill_tot'
                     , @PrgBillTot
                     , '@!total-appl'
                     , @PrgBillApp

      IF @Severity <> 0
         BREAK
   END

   IF (@CoType = 'B' AND ( @OldPriceConv <> @PriceConv or UPDATE (consolidate) or
      UPDATE(summarize) )) or
      (@CoType = 'R' AND (@OldPriceConv <> @PriceConv  or @OldUM <> @UM or
       @OldDisc <> @Disc or  UPDATE (consolidate) or
       UPDATE(summarize) or  UPDATE(cust_num) or UPDATE (cust_seq) or UPDATE (description) or
       UPDATE(cust_po)))
   BEGIN
      UPDATE con_inv_item
      SET con_inv_item.regen = 1
      WHERE con_inv_item.co_num   = @CoNum
      AND con_inv_item.co_line    =  @CoLine
      AND con_inv_item.co_release =  @CoRelease
      SELECT @Severity = @@ERROR
      IF @Severity <> 0
         BREAK
   END

   --  If the qty changed, reset the value in the current record and
   -- recalculate the itemwhse qty.
   if @InQtyOrdered <> @QtyOrdered
   begin
      UPDATE coitem
      SET qty_ordered = @QtyOrdered
      WHERE RowPointer = @RowPointer

      SELECT
        @Severity = @@ERROR

      IF @Severity <> 0
         BREAK
   end

   /* Calculate base unit of measure price and costs */
   /* TPB Moved here */
   if @InsertFlag = 1 or @UM <> @OldUM or @PriceConv != @OldPriceConv
   begin
      UPDATE coitem
      set price = @Price,
          co_orig_site = @OrigSite
          , zla_for_price = @ZlaForPrice	-- ZLA Default Price
      WHERE RowPointer = @RowPointer
      SELECT @Severity = @@ERROR
      IF @Severity <> 0
         BREAK
   end

   set @OnlyStatChanged = 0

   --- From as/rules/coitem/upd-obal.p (Maintaining the Customer Order Balance)
   --  NOTE: This section of code is intricately tied to code that
   --  also can run in the coIup trigger. Certain Session variables
   --  are set/checked to coordinate that. Specifically, setting
   --  Session variable CoitemUpdateCustOrderBal here suppresses
   --  calls to UobChcrSp in coIup. Please make sure you understand
   --  this code and what can happen downstream before making
   --  changes in this area.
   IF @InsertFlag = 1 OR (
      @OldStatus <> @Status or
      ISNULL(@OldPriceConv,0) <> ISNULL(@PriceConv,0) OR
      ISNULL(@OrigQtyOrderedConv,0) <> ISNULL(@QtyOrderedConv,0) OR
      ISNULL(@OldDisc,0) <> ISNULL(@Disc,0) OR
      ISNULL(@OldPrice,0) <> ISNULL(@Price,0) OR
      ISNULL(@OldQtyShipped,0) <> ISNULL(@QtyShipped,0) OR
      ISNULL(@OldQtyInvoiced,0) <> ISNULL(@QtyInvoiced,0) OR
      ISNULL(@OldQtyReturned,0) <> ISNULL(@QtyReturned,0) OR
      ISNULL(@OldPrgBillTot,0) <> ISNULL(@PrgBillTot,0) OR
      ISNULL(@OldPrgBillApp,0) <> ISNULL(@PrgBillApp,0))
   BEGIN
      SET @Adjust = 0
      
      IF @Status = 'O' AND  @CoStat = 'P'
         UPDATE co
         SET co.stat = 'O'
         WHERE co_num = @CoNum
      
      IF @CoType != 'E' AND @ShipSite = @Site
         AND dbo.VariableIsDefined('SkipCoitemUpdateCustOrderBal') = 0  /* Skip if invoicing (posted later)  Issue #5648 */
         AND @EdiInOrderPSp = 0 /* Skip if coming from EdiInOrderPSp (posted later) */
      BEGIN
         set @OnlyStatChanged = case when ((@OldStatus = 'P' and @Status = 'O') or (@OldStatus = 'O' and @Status = 'P') or (@OldStatus = 'O' and @Status = 'C')) and
         ISNULL(@OldPriceConv,0) = ISNULL(@PriceConv,0) and
         ISNULL(@OrigQtyOrderedConv,0) = ISNULL(@QtyOrderedConv,0) and
         ISNULL(@OldDisc,0) = ISNULL(@Disc,0) and
         ISNULL(@OldPrice,0) = ISNULL(@Price,0) and
         ISNULL(@OldQtyShipped,0) = ISNULL(@QtyShipped,0) and
         ISNULL(@OldQtyInvoiced,0) = ISNULL(@QtyInvoiced,0) and
         ISNULL(@OldQtyReturned,0) = ISNULL(@QtyReturned,0) and
         ISNULL(@OldPrgBillTot,0) = ISNULL(@PrgBillTot,0) and
         ISNULL(@OldPrgBillApp,0) = ISNULL(@PrgBillApp,0)
            then 1 else 0 end

         /* In order to prevent double taxation, SumCoSp must not be called when
            a parent SP is calculating taxes, indicated by dbo.TmpTaxTablesInUse() = 1. 
            Also, SumCoSp should only be called when not triggered from EdiInOrderPSp. */
         IF @TmpTaxTablesInUse = 0 AND
            @EdiInOrderPSp = 0  AND
            @OnlyStatChanged = 0
         begin
            if not exists (select 1 from @SumCo where co_num = @CoNum and site = @Site)
               insert into @SumCo
               values (@CoNum, @Site, 1, @CoPrice, 0)
         end

         -- Handle case where existing line is changed from 'P'lanned or
         -- to 'P'lanned. Need to calculate exact line amount for use
         -- in adjusting the customer order balance.

         if 1 = case when @InsertFlag = 1
         or @OldPrice != @Price
         or @OldDisc != @Disc
         or @OrigQtyOrdered != @QtyOrdered
         or @OldQtyInvoiced != @QtyInvoiced
         or @OldQtyShipped != @QtyShipped
         or @OldPrgBillTot != @PrgBillTot
         or @OldPrgBillApp != @PrgBillApp
         or @OldItem != @Item
         or isnull(@OldTaxCode1, '') != isnull(@TaxCode1, '')
         or isnull(@OldTaxCode2, '') != isnull(@TaxCode2, '')
         or (@Status IN ( 'O', 'F') and @OldStatus = 'P')
         or (@OldStatus IN ( 'O', 'F') and @Status = 'P')
         OR (@Status IN ('C') and @OldStatus IN ( 'O', 'F'))
         OR (@OldStatus IN ('C') and @Status = 'O')
         then 1
         else 0
         end
         begin
            IF (@InsertFlag = 0 or @Status ='P' OR @Status ='C') and @OldStatus in ('O', 'F')
            or (@OldStatus = 'P' and @Status = 'P')
            BEGIN
               -- In this case, the Old price info must be used because that's what
               -- would have been added to the previous customer balance.
               EXEC @Severity = dbo.GetCoitemLinePriceSp
                 @PCoNum            = @CoNum
               , @CoitemPrice       = @OldPrice
               , @CoitemDisc        = @OldDisc
               , @CoitemQtyOrdered  = @OrigQtyOrdered
               , @CoitemLbrCost     = @OldLbrCost
               , @CoitemMatlCost    = @OldMatlCost
               , @CoitemFovhdCost   = @OldFovhdCost
               , @CoitemVovhdCost   = @OldVovhdCost
               , @CoitemOutCost     = @OldOutCost
               , @CoitemQtyInvoiced = @OldQtyInvoiced
               , @CoitemQtyShipped  = @OldQtyShipped
               , @CoitemPrgBillTot  = @OldPrgBillTot
               , @CoitemPrgBillApp  = @OldPrgBillApp
               , @CoitemCoLine      = @CoLine
               , @CoitemCoRelease   = @CoRelease
               , @CoitemItem        = @OldItem
               , @CoitemTaxCode1    = @OldTaxCode1
               , @CoitemTaxCode2    = @OldTaxCode2
               , @CoitemLinePrice   = @CoitemLinePrice OUTPUT
               , @Infobar           = @Infobar OUTPUT
               , @CoitemRowPointer  = @RowPointer 

               IF @Severity <> 0
                  BREAK

               SET @Adjust = - @CoitemLinePrice
               --SET @TraceMsg = 'coitem_mstIup1: Adjust=' + CONVERT(varchar(20), @Adjust)
               --EXEC CATBERT.SLDevEnv_App.dbo.SQLTraceSp @TraceMsg, 'thoblo'
            END

            IF @Status IN ( 'O', 'F') or (@OldStatus = 'P' and @Status = 'P')
            BEGIN
               EXEC @Severity = dbo.GetCoitemLinePriceSp
                 @PCoNum            = @CoNum
               , @CoitemPrice       = @Price
               , @CoitemDisc        = @Disc
               , @CoitemQtyOrdered  = @QtyOrdered
               , @CoitemLbrCost     = @LbrCost
               , @CoitemMatlCost    = @MatlCost
               , @CoitemFovhdCost   = @FovhdCost
               , @CoitemVovhdCost   = @VovhdCost
               , @CoitemOutCost     = @OutCost
               , @CoitemQtyInvoiced = @QtyInvoiced
               , @CoitemQtyShipped  = @QtyShipped
               , @CoitemPrgBillTot  = @PrgBillTot
               , @CoitemPrgBillApp  = @PrgBillApp
               , @CoitemCoLine      = @CoLine
               , @CoitemCoRelease   = @CoRelease
               , @CoitemItem        = @Item
               , @CoitemTaxCode1    = @TaxCode1
               , @CoitemTaxCode2    = @TaxCode2
               , @CoitemLinePrice   = @CoitemLinePrice OUTPUT
               , @Infobar           = @Infobar OUTPUT
               , @CoitemRowPointer  = @RowPointer

               IF @Severity <> 0
                  BREAK

               SET @Adjust = @Adjust + @CoitemLinePrice
               --SET @TraceMsg = 'coitem_mstIup2: Adjust=' + CONVERT(varchar(20), @Adjust)
               --EXEC CATBERT.SLDevEnv_App.dbo.SQLTraceSp @TraceMsg, 'thoblo'
            END
         END

         IF @Adjust <> 0  OR  @Status  = 'P'
            EXEC @Severity = dbo.DefineVariableSp
              'CoitemUpdateCustOrderBal'
            , '1'
            , @Infobar

         -- Note: Parms to UobChcrSp are different here than calls to this
         -- in coIup.
         if @Adjust != 0
         begin
            IF not (@Status = 'P' and @OldStatus in ('P'))
            BEGIN
               EXEC @Severity = dbo.UobChcrSp
                 @CustNum     = @CoCustNum
               , @Adjust      = @Adjust
               , @AlwaysWarn  = 0 -- AlwaysWarn = FALSE
               , @AbortCredCk = @InsertFlag
               , @CoNum       = @CoNum
               , @Infobar     = @Infobar OUTPUT
               , @CoLine      = @CoLine
               , @CoRelease   = @CoRelease

               UPDATE @SumCo
               SET adjustment = adjustment + @Adjust
               WHERE co_num   = @CoNum
               AND site       = @Site
               
            END
            ELSE
            BEGIN
               update @SumCo
               set adjustment = adjustment + @Adjust
               where co_num = @CoNum
               and site = @Site
            END
         end

         IF ( ( @Status = N'P' ) OR ( @OldStatus = N'P' ) ) AND (@Status != @OldStatus)  -- Status changing to or from Planned.  
         BEGIN
            DECLARE   @OldCoitemLinePrice  AmountType
            IF ( @OldStatus = N'P' )    -- Determine Extended Discounted Price for previous.  
               SET @OldCoitemLinePrice  = 0 - ( ISNULL ( @OrigQtyOrdered , 0 ) * ( 1 - ( ISNULL ( @OldDisc , 0 ) ) / 100 ) * ( ISNULL ( @OldPriceConv , 0 ) ) )
            IF ( @Status = N'P' )       -- Determine Extended Discounted Price.  
               SET @OldCoitemLinePrice  = ( ISNULL ( @QtyOrdered , 0 ) * ( 1 - ( ISNULL ( @Disc , 0 ) ) / 100 ) * ( ISNULL ( @PriceConv , 0 ) ) )

            UPDATE @SumCo
            SET adjustment = adjustment + @OldCoitemLinePrice  -- Force Adjustment
            WHERE co_num = @CoNum
            AND site = @Site
         END   --IF ( ( @Status = N'P' ) OR ( @OldStatus = N'P' ) ) AND (@Status != @OldStatus)


         IF @Severity <> 0
            BREAK

         -- Get status (possibly changed to 'P' in CredChkSp)
         SELECT @Status = stat
         FROM   coitem
         WHERE  RowPointer = @RowPointer
      END
   END

            --  The cust_lcr record is updated to show the changes in the total
      -- price on releases.
  SET @LcrValuesChanged = 0
  IF @OrigQtyOrderedConv <> @QtyOrderedConv  OR @PriceConv <> @OldPriceConv  OR @OldDisc <> @Disc
     SET @LcrValuesChanged = 1
  IF ( @LcrValuesChanged = 1 OR @OldStatus <> @Status )
       AND  @CoLcrNum IS NOT NULL
  BEGIN

      --Subtract out old values when necessary
    IF (@InsertFlag = 0 AND @LcrValuesChanged = 1 AND          
     @OldStatus <> 'P' AND @Status <> 'P') or   
      (@InsertFlag = 0 AND      
     @OldStatus <> 'P' AND @Status = 'P') 
      BEGIN
          EXEC @Severity = dbo.CoitemUpdLcrSp
           @CoNum
         , @CoLine
         , @CoRelease
         , @OldPrice
         , @OldDisc
         , @OrigQtyOrdered
         , @OldQtyInvoiced
         , @OldQtyReturned
         , @OldQtyShipped
         , @OldItem
         , @OldTaxCode1
         , @OldTaxCode2
         , @ShipSite
         , 0  -- subsc
         , @DueDate
         , @Infobar = @Infobar  OUTPUT
         IF @Severity <> 0
           BREAK
      END

      --Add in new values when necessary
      IF @Status <> 'P' AND (
          @InsertFlag = 1 OR
          @OldStatus = 'P' OR
          @LcrValuesChanged = 1
          )
      BEGIN
         EXEC @Severity = dbo.CoitemUpdLcrSp
              @CoNum
            , @CoLine
            , @CoRelease
            , @Price
            , @Disc
            , @QtyOrdered
            , @QtyInvoiced
            , @QtyReturned
            , @QtyShipped
            , @Item
            , @TaxCode1
            , @TaxCode2
            , @ShipSite
            , 1  -- add
            , @DueDate
            , @Infobar = @Infobar  OUTPUT

         IF @Severity <> 0
           BREAK

      END

      --  If the corporate customer and credit flag are set, then the order
      -- balance is adjusted for the corporate customer AS WELL AS FOR THE
      -- co customer.  Otherwise, the balance is adjusted for the co customer.
   END -- update LCR


   /*
   ** 05/29/02 Moved status changed related stuff here
   ** since status could get changed above if call to UobChcrSp
   */
   IF (@CoType != 'E'
   and (@InsertFlag = 1 or ISNULL(@Status,CHAR(1)) <> ISNULL(@OldStatus,CHAR(1))))
   BEGIN
      EXEC @Severity = dbo.CoitemValidateStatusSp
        @CoNum
      , @CoLine
      , @OldQtyShipped
      , @OldQtyRsvd
      , @OldQtyInvoiced
      , @CoStat
      , @OldStatus
      , @Status
      , @Infobar = @Infobar         OUTPUT
      , @PlacesQtyUnit = @PlacesQtyUnit
      if @Severity <> 0
         break
   END

   IF (ISNULL(@Status,CHAR(1)) <> ISNULL(@OldStatus,CHAR(1)) OR
       ( @RefType = 'I' AND @OldRefType <> 'I' AND  @OldQtyRsvd = 0 )
        AND @CoType != 'E' AND @Site = @ShipSite)
   and (@OldStatus is not null or @Status = 'C')
   BEGIN
      EXEC @Severity = dbo.CoitemChgStatSp
        @CoNum
      , @CoLine
      , @CoRelease
      , @OldWhse
      , @OrigQtyOrdered
      , @OldQtyShipped
      , @OrigQtyOrderedConv
      , @OldPriceConv
      , @OldDisc
      , @OldUM
      , @CoDisc
      , @InsertFlag
      , @OldStatus
      , @Status
      , @Item
      , @QtyOrdered
      , @Infobar = @Infobar    OUTPUT
      , @ParmsSite = @Site

      IF @Severity <> 0
         BREAK

      if @Status = 'C'
      and @Status <> ISNULL(@OldStatus,CHAR(1))
      begin
         declare @NewQtyRsvd QtyUnitType
         select @NewQtyRsvd = qty_rsvd
         , @QtyReady = qty_ready
         from coitem
         where co_num = @CoNum
         and co_line = @CoLine
         and co_release = @CoRelease

         if @NewQtyRsvd != @QtyRsvd
         begin
            set @SyncReqd = 0
            set @QtyRsvd = @NewQtyRsvd
         end
      end
   END
   --  from  coitem/chg-stat.p
   IF @OldStatus = 'P' AND @Status = 'O'
   BEGIN
      IF @CoStat ='P' AND @CoType = 'R'
      BEGIN
         UPDATE co
         SET stat = 'O'
         WHERE co_num = @CoNum

         SET @Severity = @@ERROR
         IF @Severity <> 0
            BREAK
      END

      IF @CoType = 'B' AND @CoBlnStat = 'P'
      BEGIN
         UPDATE co_bln
         SET stat = 'O'
         WHERE co_num = @CoNum
         AND co_line = @CoLine

         SET @Severity = @@ERROR
         IF @Severity <> 0
            BREAK
      END
   END
 --  end from  coitem/chg-stat.p

   IF @CoType != 'E' AND ( (@Item <> @OldItem OR @Whse <> @OldWhse ) or @InsertFlag = 1
   or @OrigQtyOrderedConv != @QtyOrderedConv
   or @OldUM != @UM
   or @OldStatus != @Status) AND
       @Site = @ShipSite
   AND @NonInventoryItem <> 1
   BEGIN
      EXEC @Severity = dbo.UpdIwhsSp
        @ParmCoNum = @CoNum
      , @ParmCoCustNum = @CoCustNum
      , @ParmNewStat = @Status
      , @ParmOldQtyOrderedConv = @OrigQtyOrderedConv
      , @ParmOldQtyOrdered = @OrigQtyOrdered
      , @ParmOldUM = @OldUM
      , @ParmOldWhse = @OldWhse
      , @ParmNewWhse = @Whse
      , @ParmOldQtyShipped = @OldQtyShipped
      , @ParmOldStatus = @OldStatus
      , @ParmNewQtyOrderedConv = @QtyOrderedConv
      , @ParmNewQtyOrdered = @QtyOrdered
      , @ParmNewItem = @Item
      , @ParmNewUM = @UM
      , @ParmCustItem = @CustItem  
      , @ParmNewRecord = @InsertFlag
      , @Infobar = @Infobar    OUTPUT
      , @BufferItemwhse = @BufferItemwhse
      , @ItemcustPurchYtd = @ItemcustPurchYtd output
      , @ItemcustOrderYtd = @ItemcustOrderYtd output
      , @ItemcustOrderPtd = @ItemcustOrderPtd output
      , @ItemwhseQtyAllocCoOld = @ItemwhseQtyAllocCoOld output
      , @ItemwhseQtyAllocCoNew = @ItemwhseQtyAllocCoNew output

      IF @Severity <> 0
         BREAK

      if @BufferItemwhse = 1
      begin
         update @Itemcust
         set purch_ytd = purch_ytd + @ItemcustPurchYtd
         , order_ytd = order_ytd + @ItemcustOrderYtd
         , order_ptd = order_ptd + @ItemcustOrderPtd
         where cust_num = @CoCustNum
         and item = @Item
         if @@rowcount = 0
            insert into @Itemcust
            values(@CoCustNum, @Item, @ItemcustPurchYtd, @ItemcustOrderYtd, @ItemcustOrderPtd)

         if @ItemwhseQtyAllocCoOld != 0
         begin
            update @Itemwhse
            set qty_alloc_co = qty_alloc_co + @ItemwhseQtyAllocCoOld
            where item = @Item
            and whse = @OldWhse
            if @@rowcount = 0
               insert into @Itemwhse
               values(@Item, @OldWhse, @ItemwhseQtyAllocCoOld)
         end

         update @Itemwhse
         set qty_alloc_co = qty_alloc_co + @ItemwhseQtyAllocCoNew
         where item = @Item
         and whse = @Whse
         if @@rowcount = 0
            insert into @Itemwhse
            values(@Item, @Whse, @ItemwhseQtyAllocCoNew)
      end
   END

   IF  @CoType = 'E'
   BEGIN
      SET @MatlCostConv = ISNULL(@MatlCostConv,0)
      SET @LbrCostConv = ISNULL(@LbrCostConv,0)
      SET @FovhdCostConv = ISNULL(@FovhdCostConv,0)
      SET @VovhdCostConv = ISNULL(@VovhdCostConv,0)
      SET @OutCostConv = ISNULL(@OutCostConv,0)
      SET @CostConv = CASE WHEN @NonInventoryItem = 1 THEN @newNonInvCostConv 
                           ELSE (ISNULL(@MatlCostConv,0) + ISNULL(@LbrCostConv,0) +
                                 ISNULL(@FovhdCostConv,0) + ISNULL(@VovhdCostConv,0) +
                                 ISNULL(@OutCostConv,0))
                           END

      UPDATE coitem
      SET matl_cost_conv = @MatlCostConv,
          lbr_cost_conv = @LbrCostConv,
          fovhd_cost_conv = @FovhdCostConv,
          vovhd_cost_conv = @VovhdCostConv,
          out_cost_conv = @OutCostConv,
          cost_conv = @CostConv,
          matl_cost = ISNULL(dbo.UomConvAmt(@MatlCostConv, @ConvFactor, 'To Base'),0),
          lbr_cost = ISNULL(dbo.UomConvAmt(@LbrCostConv, @ConvFactor, 'To Base'),0),
          fovhd_cost = ISNULL(dbo.UomConvAmt(@FovhdCostConv, @ConvFactor, 'To Base'),0),
          vovhd_cost = ISNULL(dbo.UomConvAmt(@VovhdCostConv, @ConvFactor, 'To Base'),0),
          out_cost = ISNULL(dbo.UomConvAmt(@OutCostConv, @ConvFactor, 'To Base'),0),
          cost = ISNULL(dbo.UomConvAmt(@CostConv, CASE WHEN @NonInventoryItem = 1 THEN 1 ELSE @ConvFactor END, 'To Base'),0)
      WHERE RowPointer = @RowPointer
      SELECT @Severity = @@ERROR

      IF @Severity <> 0
         BREAK

   END
   ELSE
   IF (ISNULL(@OldItem,CHAR(1)) <> ISNULL(@Item,CHAR(1))  OR
   ISNULL(@OldShipSite,CHAR(1)) <> ISNULL(@ShipSite,CHAR(1))  OR
   (ISNULL(@oldNonInvCostConv,0) <> ISNULL(@newNonInvCostConv,0) AND @NonInventoryItem = 1))
   and @CalledFromCopy is null
   and @EdiInOrderPSp = 0
   BEGIN
      DECLARE @InvParmsCostItemAtWhse ListYesNoType
      SELECT @InvParmsCostItemAtWhse = cost_item_at_whse
      FROM invparms_all WITH (readuncommitted)
      WHERE invparms_all.site_ref = @ShipSite
      
      IF @InvParmsCostItemAtWhse = 0
      BEGIN
         SELECT
           @LbrCost    = ISNULL(item.lbr_cost,0)
         , @MatlCost   = ISNULL(item.matl_cost,0)
         , @FovhdCost  = ISNULL(item.fovhd_cost,0)
         , @VovhdCost  = ISNULL(item.vovhd_cost,0)
         , @OutCost    = ISNULL(item.out_cost,0)
         , @Cost       = ISNULL(item.lbr_cost,0) + ISNULL(item.matl_cost,0) +
                         ISNULL(item.fovhd_cost,0) + ISNULL(item.vovhd_cost,0) +
                         ISNULL(item.out_cost,0)
         FROM item_all AS item with (readuncommitted)
         WHERE item.item = @Item
         AND item.site_ref = @ShipSite
      END
      ELSE
      BEGIN
         SELECT
           @LbrCost    = ISNULL(itemwhse.lbr_cost,0)
         , @MatlCost   = ISNULL(itemwhse.matl_cost,0)
         , @FovhdCost  = ISNULL(itemwhse.fovhd_cost,0)
         , @VovhdCost  = ISNULL(itemwhse.vovhd_cost,0)
         , @OutCost    = ISNULL(itemwhse.out_cost,0)
         , @Cost       = ISNULL(itemwhse.lbr_cost,0) + ISNULL(itemwhse.matl_cost,0) +
                         ISNULL(itemwhse.fovhd_cost,0) + ISNULL(itemwhse.vovhd_cost,0) +
                         ISNULL(itemwhse.out_cost,0)
         FROM itemwhse_all AS itemwhse with (readuncommitted)
         WHERE itemwhse.item = @Item
         AND itemwhse.site_ref = @ShipSite
         AND itemwhse.whse = @Whse
      END

      /* NonInventoryItem */
      IF @NonInventoryItem = 1
      BEGIN
          SET @MatlCost = 0
          SET @LbrCost = 0
          SET @FovhdCost = 0
          SET @VovhdCost = 0
          SET @OutCost = 0
          SET @Cost = @newNonInvCostConv     
      END

      UPDATE coitem
      SET matl_cost = ISNULL(@MatlCost,0),
          lbr_cost = ISNULL(@LbrCost,0),
          fovhd_cost = ISNULL(@FovhdCost,0),
          vovhd_cost = ISNULL(@VovhdCost,0),
          out_cost = ISNULL(@OutCost,0),
          cost = ISNULL(@Cost,0),
          matl_cost_conv = ISNULL(dbo.UomConvAmt(@MatlCost, @ConvFactor, 'From Base'),0),
          lbr_cost_conv =  ISNULL(dbo.UomConvAmt(@LbrCost, @ConvFactor, 'From Base'),0),
          fovhd_cost_conv =  ISNULL(dbo.UomConvAmt(@FovhdCost, @ConvFactor, 'From Base'),0),
          vovhd_cost_conv =  ISNULL(dbo.UomConvAmt(@VovhdCost, @ConvFactor, 'From Base'),0),
          out_cost_conv =  ISNULL(dbo.UomConvAmt(@OutCost, @ConvFactor, 'From Base'),0),
          cost_conv =  ISNULL(dbo.UomConvAmt(@Cost, CASE WHEN @NonInventoryItem = 1 THEN 1 ELSE @ConvFactor END, 'From Base'),0)
      WHERE RowPointer = @RowPointer
      SELECT @Severity = @@ERROR
      IF @Severity <> 0
         BREAK
   END
   else if @InsertFlag = 0
   and @QtyShipped != @OldQtyShipped
   begin
      IF @NonInventoryItem = 1
      BEGIN
         set @ConvFactor = 1
         SET @MatlCost = 0
         SET @LbrCost = 0
         SET @FovhdCost = 0
         SET @VovhdCost = 0
         SET @OutCost = 0
         SET @Cost = @newNonInvCostConv
      END
      else
      begin
         SET @MatlCost = ISNULL(@MatlCost, 0)
         SET @LbrCost = ISNULL(@LbrCost, 0)
         SET @FovhdCost = ISNULL(@FovhdCost, 0)
         SET @VovhdCost = ISNULL(@VovhdCost, 0)
         SET @OutCost = ISNULL(@OutCost, 0)
         SET @Cost = @MatlCost + @LbrCost + @FovhdCost + @VovhdCost + @OutCost
      end

      UPDATE coitem
      SET matl_cost = @MatlCost
      , lbr_cost = @LbrCost
      , fovhd_cost = @FovhdCost
      , vovhd_cost = @VovhdCost
      , out_cost = @OutCost
      , cost = @Cost
      , matl_cost_conv = ISNULL(dbo.UomConvAmt(@MatlCost, @ConvFactor, 'From Base'), 0)
      , lbr_cost_conv = ISNULL(dbo.UomConvAmt(@LbrCost, @ConvFactor, 'From Base'), 0)
      , fovhd_cost_conv = ISNULL(dbo.UomConvAmt(@FovhdCost, @ConvFactor, 'From Base'), 0)
      , vovhd_cost_conv = ISNULL(dbo.UomConvAmt(@VovhdCost, @ConvFactor, 'From Base'), 0)
      , out_cost_conv = ISNULL(dbo.UomConvAmt(@OutCost, @ConvFactor, 'From Base'), 0)
      , cost_conv = ISNULL(dbo.UomConvAmt(@Cost, @ConvFactor, 'From Base'), 0)
      WHERE RowPointer = @RowPointer
   end
   /*  code from  as/rules/coitem/sum.p  */
   --- done in  SumCoSp   ----------

   /* Calculate base unit of measure price and costs */
   if @InsertFlag = 1 or @UM <> @OldUM or @PriceConv != @OldPriceConv
   begin
      UPDATE coitem
      set price = @Price,
          co_orig_site = @OrigSite
      WHERE RowPointer = @RowPointer
      SELECT @Severity = @@ERROR
      IF @Severity <> 0
         BREAK
   end

   /* Update Xrefd Project */
   IF ( @InsertFlag = 1 OR ( UPDATE (ref_type) or UPDATE(ref_num)
         -- things that affect the Contract Revenue calculation
         or @PriceConv != @OldPriceConv or @OrigQtyOrderedConv != @QtyOrderedConv or @Disc != @OldDisc))
     AND @Site = @ShipSite
   BEGIN
      if @RefType = 'K' and @RefNum is not null
         exec @Severity = dbo.ProjContRevSp
           @CoNum
         , @CoLine
         , @CoRelease
         , @Infobar = @Infobar output
      IF @Severity <> 0
        BREAK
   END
/* this code from rules/coitem/chg-stat.p  */
   IF @OldStatus = 'O' AND @Status = 'P'
-- If the status of all line/releases is now Planned,
-- change the header to Planned.
   BEGIN
      IF @CoRelease = 0
         SELECT TOP 1 @CoitemRowPointer = RowPointer
         FROM coitem
         WHERE co_num = @CoNum
         AND co_line <> @CoLine
         AND stat <> 'P'
      ELSE
         SELECT TOP 1 @CoitemRowPointer = RowPointer
         FROM coitem
         WHERE co_num = @CoNum
         AND co_line = @CoLine
         AND co_release <> @CoRelease
         AND stat <> 'P'


      IF @CoitemRowPointer IS NULL AND @CoBlnStat = 'O' AND @CoType = 'B'
      BEGIN
         SELECT TOP 1 @CoBlnRowPointer = RowPointer
         FROM co_bln
         WHERE co_num = @CoNum
         AND co_line <> @CoLine
         AND stat <> 'P'

         IF  @CoBlnRowPointer IS NULL AND  @CoStat = 'O'
         BEGIN
            UPDATE coitem
            SET stat = 'P'
            WHERE co_num = @CoNum and co_line = @CoLine and co_release = @CoRelease
            SET @Severity = @@ERROR
            IF @Severity <> 0
               BREAK

            UPDATE co_bln
            SET stat = 'P'
            WHERE co_num = @CoNum
            AND co_line = @CoLine
            SET @Severity = @@ERROR
            IF @Severity <> 0
               BREAK

            UPDATE co
            SET stat = 'P'
            WHERE co_num = @CoNum
            SET @Severity = @@ERROR
            IF @Severity <> 0
              BREAK
         END

      END
   END
   IF @CoType = 'R' AND UPDATE (stat) AND @Status = 'C'
   BEGIN
      if not exists (select 1 from @CoStatus where co_num = @CoNum)
         insert into @CoStatus values(@CoNum)
   END
   else IF @CoType = 'B' AND UPDATE (stat) AND @Status = 'C'
   and @SkipCoBlnStatusUpdate = 0
   BEGIN
      SELECT TOP 1 @CoitemRowPointer = RowPointer
      FROM coitem
      WHERE co_num = @CoNum
      AND co_line = @CoLine
      AND co_release <> @CoRelease
      AND stat <> 'C'

      IF @CoitemRowPointer IS NULL AND  @CoBlnStat <>  'C'
      BEGIN
         UPDATE co_bln
         SET stat = 'C'
         WHERE co_num = @CoNum
         AND co_line = @CoLine
         and stat != 'C'

         SET @Severity = @@ERROR
         IF @Severity <> 0
            BREAK
      END
   END
/*  end code from rules/coitem/chg-stat.p */
------------------
-- Multi-Site
------------------

   IF @CoType <> 'E'
   BEGIN
      -- as/rules/rep/coitem.p
      -- replicate from Originating Site to Shipping site
      IF @Site <> @ShipSite AND
       ISNULL(@SyncReqd, 0) = 0 AND
       ( @InsertFlag = 1 OR (
       ISNULL(@OldShipSite,CHAR(1)) <> ISNULL(@ShipSite,CHAR(1)) OR
       ISNULL(@OldItem,CHAR(1)) <> ISNULL(@Item,CHAR(1)) OR
       ISNULL(@OldStatus,CHAR(1)) <> ISNULL(@Status,CHAR(1)) OR
       ISNULL(@OldUM,CHAR(1)) <> ISNULL(@UM,CHAR(1)) OR
       ISNULL(@OldPriceConv,0) <> ISNULL(@PriceConv,0) OR
       ISNULL(@OrigQtyOrderedConv,0) <> ISNULL(@QtyOrderedConv,0) OR
       ISNULL(@OldDisc,0) <> ISNULL(@Disc,0) OR
       ISNULL(@OldTaxCode1,CHAR(1))<> ISNULL(@TaxCode1,CHAR(1)) OR
       ISNULL(@OldTaxCode2,CHAR(1))<> ISNULL(@TaxCode2,CHAR(1)) OR
       ISNULL(@OldPrice,0) <> ISNULL(@Price,0) OR
       ISNULL(@OldWhse,CHAR(1)) <> ISNULL(@Whse,CHAR(1)) OR
       ISNULL(@OldRefType,CHAR(1))<> ISNULL(@RefType,CHAR(1)) OR
       UPDATE(cust_item) OR UPDATE(feat_str) OR UPDATE(promise_date) OR UPDATE(pricecode) OR
       UPDATE (description)    OR UPDATE(due_date) OR UPDATE(reprice) OR UPDATE(cust_num) OR
       UPDATE(cust_seq) OR UPDATE(release_date) OR UPDATE(comm_code) OR UPDATE(trans_nat) OR UPDATE(trans_nat_2) OR
       UPDATE(process_ind) OR UPDATE(delterm) OR UPDATE(suppl_qty_conv_factor) OR UPDATE(origin) OR
       UPDATE (cons_num) OR UPDATE(export_value) OR UPDATE(ec_code) OR UPDATE(config_id) OR
       UPDATE(co_cust_num) OR UPDATE(transport) OR UPDATE(NoteExistsFlag) OR
       UPDATE(manufacturer_id) OR UPDATE(manufacturer_item)))
      BEGIN
     -- Obtain value of session variable to be passed to
      -- remote ship site to check credit limit
       EXEC dbo.GetVariableSp
            @VariableName   = 'AllowOverCreditLimit'
          , @DefaultValue   = 0
          , @DeleteVariable = 1
          , @VariableValue  = @AllowOverCreditLimit OUTPUT
          , @Infobar        = @WarningMsg OUTPUT

         SET @AllowOverCreditLimit = ISNULL(@AllowOverCreditLimit, 0)
         SET @PromiseDate121Str = CONVERT(NVARCHAR(100), @PromiseDate, 121)
         SET @DueDate121Str = CONVERT(NVARCHAR(100), @DueDate, 121)
         SET @ReleaseDate121Str = CONVERT(NVARCHAR(100), @ReleaseDate, 121)
         SET @ProjectedDate121Str = CONVERT(NVARCHAR(100), @ProjectedDate, 121)
         
         EXEC @Severity = dbo.RemoteMethodCallSp
           @Site        = @ShipSite
         , @IdoName     = NULL
         , @MethodName  = 'RepCoitemSp'
         , @Infobar     = @Infobar OUTPUT
         , @Parm1Value  = @ShipSite
         , @Parm2Value  = @CoNum
         , @Parm3Value  = @CoLine
         , @Parm4Value  = @CoRelease
         , @Parm5Value  = @Item
         , @Parm6Value  = @CustItem
         , @Parm7Value  = @FeatStr
         , @Parm8Value  = @Status
         , @Parm9Value  = @PromiseDate121Str
         , @Parm10Value = @Pricecode
         , @Parm11Value = @UM
         , @Parm12Value = @Description
         , @Parm13Value = @CoOrigSite
         , @Parm14Value = @QtyOrdered
         , @Parm15Value = @Disc
         , @Parm16Value = @Price
         , @Parm17Value = @DueDate121Str
         , @Parm18Value = @Reprice
         , @Parm19Value = @CustNum
         , @Parm20Value = @CustSeq
         , @Parm21Value = @ReleaseDate121Str
         , @Parm22Value = @Whse
         , @Parm23Value = @CommCode
         , @Parm24Value = @TransNat
         , @Parm25Value = @ProcessInd
         , @Parm26Value = @Delterm
         , @Parm27Value = @SupplQtyConvFactor
         , @Parm28Value = @Origin
         , @Parm29Value = @ConsNum
         , @Parm30Value = @TaxCode1
         , @Parm31Value = @TaxCode2
         , @Parm32Value = @ExportValue
         , @Parm33Value = @EcCode
         , @Parm34Value = @QtyOrderedConv
         , @Parm35Value = @PriceConv
         , @Parm36Value = @CoitemCustNum
         , @Parm37Value = @Transport
         , @Parm38Value = @RefType
         , @Parm39Value = @ProjectedDate121Str
         , @Parm40Value = NULL
         , @Parm41Value = NULl
         , @Parm42Value = NULL
         , @Parm43Value = NULL
         , @Parm44Value = NULL
         , @Parm45Value = NULL
         , @Parm46Value = NULL
         , @Parm47Value = NULL
         , @Parm48Value = NULL
         , @Parm49Value = 'A'
         , @Parm50Value = 1
         , @Parm51Value = @TransNat2
         , @Parm52Value = @PlanOnSave
         , @Parm53Value = @ApsPlannerUpdate
         , @Parm54Value = @EdiInOrderPSp
         , @Parm55Value = @ConfigId
         , @Parm56Value = @AllowOverCreditLimit
         , @Parm57Value = @newNonInvAcct  
         , @Parm58Value = @newNonInvAcctUnit1  
         , @Parm59Value = @newNonInvAcctUnit2  
         , @Parm60Value = @newNonInvAcctUnit3  
         , @Parm61Value = @newNonInvAcctUnit4
         , @Parm62Value = @ManufacturerId
         , @Parm63Value = @ManufacturerItem
         , @Parm64Value = @PrgBillTot
         , @Parm65Value = @PrgBillApp
         , @Parm66Value = 1 -- @RepFromTrigger

         IF @Severity <> 0
            BREAK

         IF @ApsPlannerUpdate = 0
         BEGIN
            /* Set current site's coitem record stat to 'P' when any other site's stat was set to 'P' */
            IF EXISTS ( SELECT *
                        FROM coitem_all WITH (READUNCOMMITTED)
                        WHERE co_num = @CoNum AND co_line = @CoLine AND co_release = @CoRelease
                        AND site_ref <> @OrigSite
                        AND stat = 'P' )
               UPDATE coitem
                  SET stat = 'P'
               WHERE co_num = @CoNum and co_line = @CoLine and co_release = @CoRelease

            /* Set current site's co Credit Hold ship site's Credit Hold was set */
            IF EXISTS ( SELECT *
                        FROM co_all WITH (READUNCOMMITTED)
                        WHERE co_num = @CoNum
                        AND site_ref = @ShipSite
                        AND credit_hold = 1)
            BEGIN
               EXEC @Severity = dbo.SetordchSp @CoNum, @CreditHoldReason

               IF @Severity <> 0
                  BREAK
            END 

            if not exists (select 1 from @SumCo where co_num = @CoNum and site = @ShipSite)
               insert into @SumCo
               values (@CoNum, @ShipSite, 0, @CoPrice, 0)
         END
      END

      -- Get status (possibly changed to 'P' in CredChkSp in the other site)
      SELECT @Status = stat
      FROM   coitem
      WHERE  RowPointer = @RowPointer

      IF @OldShipSite <> @ShipSite  AND
       @OldShipSite <> @CoOrigSite AND
       @OldShipSite IS NOT NULL
      BEGIN
         EXEC @Severity = dbo.RemoteMethodCallSp
           @Site        = @OldShipSite
         , @IdoName     = NULL
         , @MethodName  = 'DeleteCoitemSp'
         , @Infobar     = @Infobar OUTPUT
         , @Parm1Value  = @CoNum
         , @Parm2Value  = @CoLine
         , @Parm3Value  = @CoRelease
         , @Parm4Value  = 1    -- @RepFromTrigger
         
         IF @Severity != 0
            BREAK
      END
   END

   -- LOG COITEM with a status of ORDERED
   IF  @Status = 'O' AND ( @OldStatus = 'P' OR @InsertFlag = 1 )
   BEGIN
      IF @CalledFromCopy is null
      BEGIN
         EXEC @Severity = dbo.ItemlogSp
           @CoNum
         , @CoLine
         , @CoRelease
         , @Item
         , @OldItem
         , 0
         , @QtyOrderedConv
         , 0
         , @PriceConv
         , 0
         , @Disc
         , 0
         , @CoDisc
         , NULL        --old-due-date
         , @DueDate    --new-due-date
         , NULL        -- old-projected-date
         , @ProjectedDate  --new-projected-date
         , 'A'         -- action
         ,  @ConvFactor -- conversion facor
         , NULL        --  old-um
         , @UM             -- new-um
         , @Infobar = @Infobar  OUTPUT
         IF @Severity <> 0
            BREAK
      END
   END
   ELSE IF ( @Status IN ('O','F') AND @InsertFlag = 0) OR (@OldStatus = 'O' AND @Status IN ('F','C'))
   BEGIN
      IF (ISNULL(@OrigQtyOrderedConv,0)  <> ISNULL(@QtyOrderedConv,0)  OR
          ISNULL(@OldDueDate, convert(datetime, 0))  <> ISNULL(@DueDate, convert(datetime, 0)) OR
          ISNULL(@OldPriceConv,0) <> ISNULL(@PriceConv,0) OR
          ISNULL(@OldDisc,0) <> ISNULL(@Disc,0) OR
          ISNULL(@OldUM,0) <> ISNULL(@UM,0) )
      BEGIN
         IF @CalledFromCopy is null
         BEGIN
            EXEC @Severity = dbo.ItemlogSp
              @CoNum
            , @CoLine
            , @CoRelease
            , @Item
            , @OldItem
            , @OrigQtyOrderedConv
            , @QtyOrderedConv
            , @OldPriceConv
            , @PriceConv
            , @OldDisc
            , @Disc
            , @CoDisc
            , @CoDisc
            , @OldDueDate         --old-due-date
            , @DueDate    --new-due-date
            , @OldProjectedDate        -- old-projected-date
            , @ProjectedDate  --new-projected-date
            , 'U'         -- action
            , @ConvFactor  -- conversion factor
            , @OldUM      --  old-um
            , @UM             -- new-um
            , @Infobar = @Infobar  OUTPUT
            IF @Severity <> 0
               BREAK
         END
      END
   END

   IF @TmpTaxTablesInUse = 0 AND
      @EdiInOrderPSp = 0  AND
       (@InsertFlag = 1 OR
       (ISNULL(@OldUM,CHAR(1)) <> ISNULL(@UM,CHAR(1)) OR
       ISNULL(@OldItem,CHAR(1)) <> ISNULL(@Item,CHAR(1)) OR
       ISNULL(@OldPriceConv,0) <> ISNULL(@PriceConv,0) OR
       ISNULL(@OrigQtyOrderedConv,0) <> ISNULL(@QtyOrderedConv,0) OR
       ISNULL(@OldDisc,0) <> ISNULL(@Disc,0) OR
       ISNULL(@OldTaxCode1,CHAR(1))<> ISNULL(@TaxCode1,CHAR(1)) OR
       ISNULL(@OldTaxCode2,CHAR(1))<> ISNULL(@TaxCode2,CHAR(1)) OR
       ISNULL(@OldPrice,0) <> ISNULL(@Price,0) OR
       ISNULL(@OldMatlCost, 0) != ISNULL(@MatlCost, 0) OR
       ISNULL(@OldLbrCost, 0) != ISNULL(@LbrCost, 0) OR
       ISNULL(@OldFovhdCost, 0) != ISNULL(@FovhdCost, 0) OR
       ISNULL(@OldVovhdCost, 0) != ISNULL(@VovhdCost, 0) OR
       ISNULL(@OldOutCost, 0) != ISNULL(@OutCost, 0) OR
       ISNULL(@OldQtyShipped,0) <> ISNULL(@QtyShipped,0) OR
       ISNULL(@OldQtyInvoiced,0) <> ISNULL(@QtyInvoiced,0) OR
       ISNULL(@OldQtyReturned,0) <> ISNULL(@QtyReturned,0) OR
       ISNULL(@OldPrgBillTot,0) <> ISNULL(@PrgBillTot,0) OR
       ISNULL(@OldPrgBillApp,0) <> ISNULL(@PrgBillApp,0)))
   BEGIN
      if not exists (select 1 from @SumCo where co_num = @CoNum and site = @Site)
         insert into @SumCo
         values (@CoNum, @Site, 0, @CoPrice, 0)
   END
-- warning message
   IF @Site = @ShipSite
   and @OnlyStatChanged = 0
   BEGIN
      IF @CoDisc<>0 AND (ISNULL(@OldDisc,0)<>ISNULL(@Disc,0) or ISNULL(@PriceConv,0)<>ISNULL(@OldPriceConv,0)
          or ISNULL(@QtyOrderedConv,0)<>ISNULL(@OrigQtyOrderedConv,0))
      BEGIN
         SET @WarningMsg = null
         EXEC dbo.MsgAppSp @WarningMsg  OUTPUT, 'I=Changed'
         , '@co.disc'
         , '@co'

         EXEC dbo.MsgAppSp @WarningMsg  OUTPUT, 'W=MayNeedToRecalculate'
         , '@co.price'
         , '@co.disc'
         EXEC @Severity = dbo.WarningSp @WarningMsg
         SET @WarningMsg = NULL
      END
   END
------------------
-- Multi-Site
------------------
   -- Replicate from Shipping Site to Originating Site
   -- Set sync_reqd to 1, so that replication occurs only from
   -- Shipping Site to Originating site, and not vice versa, and
   -- thus eliminate getting into a loop.
   IF @Site = @ShipSite AND @CoOrigSite <> @ShipSite and ISNULL(@SyncReqd, 0) = 0 AND @ApsPlannerUpdate = 0
   and @CoType != 'E'
   BEGIN
      SET @ShipDate121Str = CONVERT(NVARCHAR(100), @ShipDate, 121)
      EXEC @Severity = dbo.RemoteMethodCallSp
        @Site        = @CoOrigSite
      , @IdoName     = NULL
      , @MethodName  = 'RepCoitemSp'
      , @Infobar     = @Infobar OUTPUT
      , @Parm1Value  = @ShipSite
      , @Parm2Value  = @CoNum
      , @Parm3Value  = @CoLine
      , @Parm4Value  = @CoRelease
      , @Parm5Value  = NULL
      , @Parm6Value  = NULL
      , @Parm7Value  = NULL
      , @Parm8Value  = @Status
      , @Parm9Value  = NULL
      , @Parm10Value = NULL
      , @Parm11Value = NULL
      , @Parm12Value = NULL
      , @Parm13Value = NULL
      , @Parm14Value = NULL
      , @Parm15Value = @Disc
      , @Parm16Value = @Price
      , @Parm17Value = NULL
      , @Parm18Value = NULL
      , @Parm19Value = @CustNum
      , @Parm20Value = @CustSeq
      , @Parm21Value = NULL
      , @Parm22Value = NULL
      , @Parm23Value = NULL
      , @Parm24Value = NULL
      , @Parm25Value = NULL
      , @Parm26Value = NULL
      , @Parm27Value = @SupplQtyConvFactor
      , @Parm28Value = NULL
      , @Parm29Value = @ConsNum
      , @Parm30Value = NULL
      , @Parm31Value = NULL
      , @Parm32Value = @ExportValue
      , @Parm33Value = NULL
      , @Parm34Value = NULL
      , @Parm35Value = @PriceConv
      , @Parm36Value = NULL
      , @Parm37Value = NULL
      , @Parm38Value = @RefType
      , @Parm39Value = NULL
      , @Parm40Value = @QtyShipped
      , @Parm41Value = @QtyReturned
      , @Parm42Value = @QtyRsvd
      , @Parm43Value = @QtyReady
      , @Parm44Value = @QtyPacked
      , @Parm45Value = @Packed
      , @Parm46Value = @ShipDate121Str
      , @Parm47Value = @QtyInvoiced
      , @Parm48Value = @UnitWeight
      , @Parm49Value = 'RU'
      , @Parm50Value = 1
      , @Parm51Value = @TransNat2 
      , @Parm52Value = @PlanOnSave
      , @Parm53Value = @ApsPlannerUpdate
      , @Parm54Value = @EdiInOrderPSp
      , @Parm55Value = @ConfigId
      , @Parm56Value = 0 /* value for AllowOverCreditLimit */
      , @Parm57Value = @newNonInvAcct  
      , @Parm58Value = @newNonInvAcctUnit1  
      , @Parm59Value = @newNonInvAcctUnit2  
      , @Parm60Value = @newNonInvAcctUnit3  
      , @Parm61Value = @newNonInvAcctUnit4    
      , @Parm62Value = @ManufacturerId
      , @Parm63Value = @ManufacturerItem
      , @Parm64Value = @PrgBillTot
      , @Parm65Value = @PrgBillApp
      , @Parm66Value = 1  -- @RepFromTrigger
      
      IF @Severity != 0
         BREAK
   END

   IF @CoOrigSite <> @ShipSite
   and dbo.SkipRemoteUpdate() = 0
   and @CoType != 'E'
   begin
        -- copy notes for coitem
      set @OtherSite = case when @ShipSite = @Site then @CoOrigSite else @ShipSite end

        -- build the where clause for notes copy
      EXEC @Severity = dbo.BuildWhereClauseSp
        @WhereClause = @WhereClause OUTPUT
      , @Key1Name    = 'co_num'
      , @Key1Value   = @CoNum
      , @Key2Name    = 'co_line'
      , @Key2Value   = @CoLine
      , @Key3Name    = 'co_release'
      , @Key3Value   = @CoRelease

      IF @Severity != 0
         BREAK

      EXEC @Severity = dbo.TransferNotesToSiteSp
        @ToSite        = @OtherSite
      , @TableName     = 'coitem'
      , @RowPointer    = @RowPointer
      , @ToWhereClause = @WhereClause
      , @ToRowPointer  = NULL
      , @DeleteFirst   = 1
      , @Infobar       = @Infobar OUTPUT

      IF @Severity != 0
         BREAK
   END
   
   
   SELECT @AutoShipDemandingSiteCO = po.auto_ship_demanding_site_co
   FROM po INNER JOIN poitem ON po.po_num = poitem.po_num
   WHERE poitem.po_num = @RefNum
         AND poitem.po_line = @RefLineSuf
         AND poitem.po_release = @RefRelease
         AND @RefType = 'P'

   -- Fire System Event: CustomerOrderAmountUpdate   
   IF (@InsertFlag = 1 OR UPDATE(stat) OR UPDATE(qty_ordered_conv) OR UPDATE(disc) OR UPDATE(price_conv))
      AND @Status IN ('O', 'F', 'C' )
   BEGIN
      EXEC @Severity = dbo.Event_CustomerOrderAmountUpdateSp
           @CoNum
         , @CoLine            
         , @QtyOrderedConv    
         , @Disc              
         , @PriceConv         
         , @Infobar  OUTPUT
      IF @Severity != 0
         BREAK 
   END

   UPDATE coitem
   SET sync_reqd = 0
   WHERE RowPointer = @RowPointer
   and sync_reqd = 1

   SET @Severity = @@ERROR
   IF @Severity <> 0
      BREAK

   if @CoType <> 'E' and
      @ShipSite = @Site and
      (update(qty_ordered) or update(qty_ordered_conv) or update(due_date) or UPDATE(stat)) and
      @MrpParmReqSrc = 'B'
   begin
      -- buffer it up to minimize rework
      if not exists (select 1 from @Forecast where item = @Item)
         insert into @Forecast
         values (@Item)
   end

   EXEC dbo.UndefineVariableSp
     'CoitemUpdateCustOrderBal'
   , @Infobar

   if @InsertFlag = 1
   or @Item != @OldItem
   or @Whse != @OldWhse
   or @Status != @OldStatus
   or @QtyOrdered != @OrigQtyOrdered
   or @QtyShipped != @OldQtyShipped
   or @QtyRsvd != @OldQtyRsvd
   or isnull(@RefNum, '') != isnull(@OldRefNum, '')
   or isnull(@RefLineSuf, -1) != isnull(@OldRefLineSuf, -1)
   or isnull(@RefRelease, -1) != isnull(@OldRefRelease, -1)
   or isnull(@DueDate, '1900-01-01') != isnull(@OldDueDate, '1900-01-01')
      -- buffer it up to minimize rework
      if not exists (select 1 from @NetChange where item = @Item)
         insert into @NetChange
         values (@Item)

   -- Order priority
   IF TRIGGER_NESTLEVEL(OBJECT_ID('dbo.aps_seq_mstIup')) = 0 AND
      TRIGGER_NESTLEVEL(OBJECT_ID('dbo.aps_seq_mstDel')) = 0 AND
      @InsertFlag = 0 AND
      @CoType != 'E'
   BEGIN
      IF ISNULL(@Status, CHAR(1)) IN ('O','P')
      BEGIN
         IF (@OldPriority IS NOT NULL) AND (@Priority IS NULL)
         BEGIN
            DELETE aps_seq
            WHERE aps_seq.rule_type = 4
              AND aps_seq.rule_value = LTRIM(@CoNum) + '-' + CONVERT(nvarchar, @CoLine)
         END
         ELSE IF (@OldPriority IS NULL) AND (@Priority IS NOT NULL)
         BEGIN
            INSERT INTO aps_seq (rule_type, rule_value, priority)
            VALUES (4, LTRIM(@CoNum) + '-' + CONVERT(nvarchar, @CoLine), @Priority)
         END
         ELSE IF ISNULL(@OldPriority, 0) != ISNULL(@Priority, 0)
         BEGIN
            UPDATE aps_seq
              SET aps_seq.priority = @Priority
            WHERE aps_seq.rule_type = 4
              AND aps_seq.rule_value = LTRIM(@CoNum) + '-' + CONVERT(nvarchar, @CoLine)
         END
      END
      ELSE IF ISNULL(@OldStatus, CHAR(1)) IN ('O','P')
      BEGIN
         DELETE aps_seq
         WHERE aps_seq.rule_type = 4
           AND aps_seq.rule_value = LTRIM(@CoNum) + '-' + CONVERT(nvarchar, @CoLine)
      END
   END
   IF @CoType != 'E' AND
      @Priority IS NOT NULL AND
      ISNULL(@Status, CHAR(1)) IN ('O','P') AND
      @InsertFlag = 1
   BEGIN
      INSERT INTO aps_seq (rule_type, rule_value, priority)
      VALUES (4, LTRIM(@CoNum) + '-' + CONVERT(nvarchar, @CoLine), @Priority)
   END
   
   IF @InsertFlag = 0 AND @QtyShipped > @OldQtyShipped AND @PortalOrder = 1 AND @ParmsSite = @CoOrigSite 
   AND (SELECT Active FROM EventTrigger WHERE EventName = 'OrderShippingAlert') = '1'
   AND EXISTS (SELECT 1 FROM PublicationSubscriber WHERE PublicationName = 'OrderShippingAlert' AND LTRIM(KeyValue) = LTRIM(@CoCustNum))
   BEGIN
      INSERT INTO TrackRows(SessionID, RowPointer, TrackedOperType)
      VALUES (@RowPointer, NEWID(), 'coitem')
   END
   
   -- recalculate freight charge
   IF @InsertFlag = 1
   OR UPDATE (item) 
   OR UPDATE (qty_ordered_conv)
   BEGIN
      EXEC CalcUpdCOFreightChargeSp @CoNum
   END
   
END   /* cursor loop */
CLOSE coitem_mstIupCrs
DEALLOCATE coitem_mstIupCrs

if @BufferCoitem = 1 and @ZpvPos is null
begin
   -- update existing records first
   update DefineVariables
   set VariableValue = convert(nvarchar(1), sc.update_order_bal) + '|' + convert(nvarchar(25), sc.orig_price) + '|' + convert(nvarchar(25), sc.adjustment)
   from @SumCo as sc
      inner join DefineVariables on
         DefineVariables.ConnectionID = @SessionID
      and DefineVariables.ProcessID = -1
      and DefineVariables.VariableName = 'SumCo=' + convert(nvarchar(10), sc.co_num) + convert(nvarchar(10), sc.site)

   -- then create new ones
   insert into DefineVariables (ConnectionID, ProcessID, VariableName, VariableValue)
   select @SessionID, -1, 'SumCo='
      + convert(nvarchar(10), sc.co_num) + space(10 - len(sc.co_num)) + convert(nvarchar(10), sc.site)
   , convert(nvarchar(1), sc.update_order_bal) + '|' + convert(nvarchar(25), sc.orig_price) + '|' + convert(nvarchar(25), sc.adjustment)
   from @SumCo as sc
   where not exists (select 1 from DefineVariables with (readuncommitted)
      where DefineVariables.ConnectionID = @SessionID
      and DefineVariables.ProcessID = -1
      and DefineVariables.VariableName = 'SumCo=' + convert(nvarchar(10), sc.co_num) + convert(nvarchar(10), sc.site))

   insert into DefineVariables (ConnectionID, ProcessID, VariableName, VariableValue)
    select @SessionID, -1, 'RepCo=' + Case when len(sc.co_num)< 10 
        then convert(nvarchar(10), sc.co_num) + Space(10-len(sc.co_num)) + convert(nvarchar(10), sc.ship_site)
        else  convert(nvarchar(10), sc.co_num)  + convert(nvarchar(10), sc.ship_site) END, sc.curr_code
   from @RepCo as sc
   where not exists (select 1 from DefineVariables with (readuncommitted)
      where DefineVariables.ConnectionID = @SessionID
      and DefineVariables.ProcessID = -1
      and DefineVariables.VariableName = 'RepCo=' + convert(nvarchar(10), sc.co_num) + convert(nvarchar(10), sc.ship_site))
end
else if @ZpvPos is null
begin
   declare @UpdateOrderBal ListYesNoType
   declare SumCoCrs cursor local fast_forward for
   select co_num, site, update_order_bal, orig_price, adjustment
   from @SumCo

   open SumCoCrs

   while @Severity = 0
   begin
      fetch SumCoCrs into
        @CoNum
      , @ShipSite
      , @UpdateOrderBal
      , @CoPrice
      , @Adjust

      if @@fetch_status != 0
         break

      if @ShipSite = @Site OR (@CoType = 'E' AND @PortalOrder = 1)
      begin
         if @UpdateOrderBal = 1
            EXEC @Severity = dbo.DefineVariableSp 'CoitemUpdateCustOrderBal', '1', @Infobar2
         EXEC @Severity = dbo.SumCoSp @CoNum, @Infobar OUTPUT
         , @NewTotalPrice = @NewTotalPrice output
         if @UpdateOrderBal = 1
         begin
            EXEC dbo.UndefineVariableSp 'CoitemUpdateCustOrderBal', @Infobar2

            -- adjust for line rounding differences
            if @Adjust + @CoPrice != @NewTotalPrice
            begin
               select @CoCustNum = cust_num
               from co with (readuncommitted)
               where co_num = @CoNum

               set @Adjust = @NewTotalPrice - (@Adjust + @CoPrice)

               EXEC @Severity = dbo.UobChcrSp
                 @CustNum     = @CoCustNum
               , @Adjust      = @Adjust
               , @AlwaysWarn  = 0 -- AlwaysWarn = FALSE
               , @AbortCredCk = 0
               , @CoNum       = @CoNum
               , @Infobar     = @Infobar OUTPUT
            end
         end
      end
      else
         exec @Severity = dbo.RemoteMethodCallSp
           @Site = @ShipSite
         , @IdoName = NULL
         , @MethodName = 'SumCoSp'
         , @Infobar = @Infobar output
         , @Parm1Value = @CoNum
         , @Parm2Value = @Infobar
         , @Parm3Value = 0
         , @Parm4Value = 0
   end
   close SumCoCrs
   deallocate SumCoCrs
end

IF @Severity != 0
BEGIN
   EXEC dbo.RaiseErrorSp
     @Infobar
   , @Severity
   , 1
   EXEC @Severity = dbo.RollbackTransactionSp
     @Severity
   IF @Severity != 0
   BEGIN
      ROLLBACK TRANSACTION
      RETURN
   END
END

if @BufferItemwhse = 1
AND @NonInventoryItem <> 1
begin
   update itemcust
   set purch_ytd = itemcust.purch_ytd + buf.purch_ytd
   , order_ytd = itemcust.order_ytd + buf.order_ytd
   , order_ptd = itemcust.order_ptd + buf.order_ptd
   from itemcust
      inner join @Itemcust as buf on
         buf.cust_num = itemcust.cust_num
         and buf.item = itemcust.item
         and (buf.purch_ytd != 0
            or buf.order_ytd != 0
            or buf.order_ptd != 0)

   update itemwhse
   set qty_alloc_co = itemwhse.qty_alloc_co + buf.qty_alloc_co
   from itemwhse
      inner join @Itemwhse as buf on
         buf.item = itemwhse.item
         and buf.whse = itemwhse.whse
         and buf.qty_alloc_co != 0
end

declare forecastCrs cursor local fast_forward for
select item
from @Forecast

open forecastCrs

while 1 = 1
begin
   fetch forecastCrs into
     @Item

   if @@fetch_status != 0
      break

   exec dbo.ForecastCalcSp
     @Item
end
close forecastCrs
deallocate forecastCrs

declare netchangeCrs cursor local fast_forward for
select item
from @NetChange

open netchangeCrs

while 1 = 1
begin
   fetch netchangeCrs into
     @Item

   if @@fetch_status != 0
      break

   exec dbo.ItemSetNcSp
     @Item = @Item
end
close netchangeCrs
deallocate netchangeCrs

IF @InsertFlag = 1
BEGIN
   IF dbo.SkipAllUpdate() = 0
   AND (dbo.VariableIsDefined(N'ApsPlannerUpdate') = 0)
   AND dbo.Populate_AllTables('coitem_mst') = 1
   BEGIN
      -- Always fire Replication triggers for local Site's coitem_mst_all, even when coitem_mst data came from a remote Site:
      EXEC dbo.SetTriggerStateSp 0, 1, 0, @SavedState OUTPUT, @Infobar OUTPUT

      -- Any local changes for this site are duplicated in the _all table.
      INSERT INTO coitem_mst_all (
         [site_ref]
         , [co_num]
         , [co_line]
         , [co_release]
         , [item]
         , [qty_ordered]
         , [qty_ready]
         , [qty_shipped]
         , [qty_packed]
         , [disc]
         , [price]
         , [ref_type]
         , [ref_num]
         , [ref_line_suf]
         , [ref_release]
         , [due_date]
         , [ship_date]
         , [reprice]
         , [cust_item]
         , [qty_invoiced]
         , [qty_returned]
         , [feat_str]
         , [stat]
         , [cust_num]
         , [cust_seq]
         , [prg_bill_tot]
         , [prg_bill_app]
         , [release_date]
         , [promise_date]
         , [whse]
         , [comm_code]
         , [trans_nat]
         , [process_ind]
         , [delterm]
         , [unit_weight]
         , [origin]
         , [cons_num]
         , [tax_code1]
         , [tax_code2]
         , [export_value]
         , [ec_code]
         , [transport]
         , [u_m]
         , [qty_ordered_conv]
         , [price_conv]
         , [co_cust_num]
         , [packed]
         , [qty_rsvd]
         , [ship_site]
         , [sync_reqd]
         , [co_orig_site]
         , [NoteExistsFlag]
         , [RecordDate]
         , [RowPointer]
         , [description]
         , [pricecode]
         , [CreatedBy]
         , [UpdatedBy]
         , [CreateDate]
         , [projected_date]
         , [cost]
         , [trans_nat_2]
         , [suppl_qty_conv_factor]
         , [days_shipped_before_due_date_tolerance]
         , [days_shipped_after_due_date_tolerance]
         , [shipped_over_ordered_qty_tolerance]
         , [shipped_under_ordered_qty_tolerance]
         , [invoice_hold]
         , [manufacturer_id]
         , [manufacturer_item]
         , [qty_picked]
         , [cgs_total]
         , [cost_conv]
         , [promotion_code]
         )
      SELECT
         @Site
         , coitem_mst.[co_num]
         , coitem_mst.[co_line]
         , coitem_mst.[co_release]
         , coitem_mst.[item]
         , coitem_mst.[qty_ordered]
         , coitem_mst.[qty_ready]
         , coitem_mst.[qty_shipped]
         , coitem_mst.[qty_packed]
         , coitem_mst.[disc]
         , coitem_mst.[price]
         , coitem_mst.[ref_type]
         , coitem_mst.[ref_num]
         , coitem_mst.[ref_line_suf]
         , coitem_mst.[ref_release]
         , coitem_mst.[due_date]
         , coitem_mst.[ship_date]
         , coitem_mst.[reprice]
         , coitem_mst.[cust_item]
         , coitem_mst.[qty_invoiced]
         , coitem_mst.[qty_returned]
         , coitem_mst.[feat_str]
         , coitem_mst.[stat]
         , coitem_mst.[cust_num]
         , coitem_mst.[cust_seq]
         , coitem_mst.[prg_bill_tot]
         , coitem_mst.[prg_bill_app]
         , coitem_mst.[release_date]
         , coitem_mst.[promise_date]
         , coitem_mst.[whse]
         , coitem_mst.[comm_code]
         , coitem_mst.[trans_nat]
         , coitem_mst.[process_ind]
         , coitem_mst.[delterm]
         , coitem_mst.[unit_weight]
         , coitem_mst.[origin]
         , coitem_mst.[cons_num]
         , coitem_mst.[tax_code1]
         , coitem_mst.[tax_code2]
         , coitem_mst.[export_value]
         , coitem_mst.[ec_code]
         , coitem_mst.[transport]
         , coitem_mst.[u_m]
         , coitem_mst.[qty_ordered_conv]
         , coitem_mst.[price_conv]
         , coitem_mst.[co_cust_num]
         , coitem_mst.[packed]
         , coitem_mst.[qty_rsvd]
         , coitem_mst.[ship_site]
         , coitem_mst.[sync_reqd]
         , coitem_mst.[co_orig_site]
         , coitem_mst.[NoteExistsFlag]
         , coitem_mst.[RecordDate]
         , coitem_mst.[RowPointer]
         , coitem_mst.[description]
         , coitem_mst.[pricecode]
         , coitem_mst.[CreatedBy]
         , coitem_mst.[UpdatedBy]
         , coitem_mst.[CreateDate]
         , coitem_mst.[projected_date]
         , coitem_mst.[cost]
         , coitem_mst.[trans_nat_2]
         , coitem_mst.[suppl_qty_conv_factor]
         , coitem_mst.[days_shipped_before_due_date_tolerance]
         , coitem_mst.[days_shipped_after_due_date_tolerance]
         , coitem_mst.[shipped_over_ordered_qty_tolerance]
         , coitem_mst.[shipped_under_ordered_qty_tolerance]
         , coitem_mst.[invoice_hold]
         , coitem_mst.[manufacturer_id]
         , coitem_mst.[manufacturer_item]
         , coitem_mst.[qty_picked]
         , coitem_mst.[cgs_total]
         , coitem_mst.[cost_conv]
         , coitem_mst.[promotion_code]
      FROM inserted AS ii
      -- Join back by RowPointer to the new rows in the affected table,
      -- because the coitem_mstIup trigger might have modified the new rows after we inserted them above,
      -- which would have rendered our copy of the "inserted" data dirty.
      INNER JOIN coitem_mst WITH (READUNCOMMITTED) ON coitem_mst.RowPointer = ii.RowPointer
   
      -- Restore trigger state:
      EXEC dbo.RestoreTriggerStateSp 0, @SavedState, @Infobar OUTPUT
   END
END

set @Partition = isnull(dbo.DefinedValue('ApsSyncDeferred'), newid())

if update(projected_date)
   update co
   set projected_date = comax.max_date
   from co
   inner join (
      select ii.co_num, max(ii.projected_date) as max_date
      from inserted ii
      where ii.projected_date is not null
      group by ii.co_num
   ) as comax on co.co_num = comax.co_num
   where co.type in ('R', 'B')
     and isnull(co.projected_date, '1900-01-01') != isnull(comax.max_date, '1900-01-01')
   
if update(stat) or
   update(qty_ordered) or
   update(qty_ordered_conv) or
   update(qty_shipped) or
   update(qty_rsvd)

   delete ORDER000
   from inserted
   join coitem on coitem.rowpointer = inserted.rowpointer
   join deleted on deleted.rowpointer = inserted.rowpointer
   join ORDER000 on ORDER000.OrderRowPointer = inserted.rowpointer
   where
      coitem.stat in ('F', 'C', 'H', 'Q') or
      coitem.qty_ordered - coitem.qty_shipped - coitem.qty_rsvd = 0

if update(item) or
   update(stat) or
   update(qty_ordered) or
   update(qty_ordered_conv) or
   update(qty_shipped) or
   update(qty_rsvd) or
   update(due_date) or
   update(promise_date) or
   update(ref_type) or
   update(ref_num) or
   update(ref_line_suf) or
   update(ship_site) or
   update(whse)
begin

   update coitem
   set
      projected_date = coitem.due_date
   from inserted
   join coitem on coitem.RowPointer = inserted.rowpointer
   inner join Trackrows with (readuncommitted) on coitem.RowPointer = TrackRows.RowPointer
      and TrackRows.TrackedOperType = 'Sync coitem'
      and TrackRows.SessionId = @Partition
   where
      coitem.qty_ordered - coitem.qty_shipped - coitem.qty_rsvd <= 0
      and coitem.projected_date is null

   if @InsertFlag = 0 or @PlanOnSave = 0
   begin
      insert into tmp_aps_sync (
         SessionId, RefRowPointer, SyncType)
      select
         @Partition
        ,inserted.rowpointer
        ,'No plan on save'
      from inserted
      where not exists( select * from tmp_aps_sync with (readuncommitted) where SessionId = @Partition and RefRowPointer = inserted.rowpointer)     
   end

   insert into TrackRows (
      SessionId, RowPointer, TrackedOperType)
   select
      @Partition
     ,inserted.rowpointer
     ,'Sync coitem'
   from inserted
   where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = inserted.rowpointer)

   if @@rowcount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
   begin
      exec dbo.ApsSyncCustomerOrderSp @Partition
      delete from TrackRows where SessionId = @Partition
   end
end

if update(ref_type) or
   update(ref_num) or
   update(ref_line_suf) or
   update(ref_release) 
begin
     if exists (select top 1 rowpointer from deleted where ref_type = 'J'  )
     begin
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,job.rowpointer
            ,'Sync job'
          from deleted
          join job with (readuncommitted) on
            job.job = deleted.ref_num and
            job.suffix = deleted.ref_line_suf and
            deleted.ref_type ='J'
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = job.rowpointer)
    
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0  
          begin
               exec dbo.ApsSyncJobOrderSp @Partition  
               delete from TrackRows where Sessionid = @Partition         
          end
     end
        
     if exists (select top 1 rowpointer from deleted where ref_type = 'P' )
     begin
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,poitem.rowpointer
            ,'Sync poitem'
          from deleted
          join poitem WITH (READUNCOMMITTED) on
            poitem.po_num = deleted.ref_num and
            poitem.po_line = deleted.ref_line_suf and
            deleted.ref_type ='P' and
            poitem.po_release = deleted.ref_release
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = poitem.rowpointer)
                 
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
          begin
            exec dbo.ApsSyncPurchaseOrderSp @Partition
            delete from TrackRows where Sessionid = @Partition
          end
     end

     if exists (select top 1 rowpointer from deleted where ref_type =  'R' )
     begin   
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,preqitem.rowpointer
            ,'Sync preqitem'
          from deleted
          join preqitem with (readuncommitted) on
            preqitem.req_num = deleted.ref_num and
            preqitem.req_line = deleted.ref_line_suf and
            deleted.ref_type ='R' 
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = preqitem.rowpointer)
                
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
          begin
            exec dbo.ApsSyncPreqOrderSp @Partition
            delete from TrackRows where Sessionid = @Partition
          end
     end

     if exists (select top 1 rowpointer from deleted where ref_type = 'T' )
     begin   
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,trnitem.rowpointer
            ,'Sync trnitem'
          from deleted
          join trnitem WITH (READUNCOMMITTED) on
            trnitem.trn_num = deleted.ref_num and
            trnitem.trn_line = deleted.ref_line_suf and
            deleted.ref_type ='T' 
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = trnitem.rowpointer)
                 
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
          begin
            exec dbo.ApsSyncTransferOrderSp @Partition
            delete from TrackRows where Sessionid = @Partition
          end
     end
end

if update(item) or
   update(ref_type) or
   update(ref_num) or
   update(ref_line_suf) or
   update(ref_release) or
   update(stat) or
   update(qty_ordered) or
   update(qty_ordered_conv) or
   update(qty_shipped) or
   update(qty_rsvd) 
begin

     if exists (select top 1 rowpointer from inserted where ref_type =  'J' )
     begin   
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,job.rowpointer
            ,'Sync job'
          from inserted
          join job with (readuncommitted) on
            job.job = inserted.ref_num and
            job.suffix = inserted.ref_line_suf and
            inserted.ref_type ='J' 
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = job.rowpointer)
                
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
            begin
              exec dbo.ApsSyncJobOrderSp @Partition
              delete from TrackRows where Sessionid = @Partition
            end
      end

      if exists (select top 1 rowpointer from inserted where ref_type = 'P' )
      begin   
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,poitem.rowpointer
            ,'Sync poitem'
          from inserted
          join poitem WITH (READUNCOMMITTED) on
            poitem.po_num = inserted.ref_num and
            poitem.po_line = inserted.ref_line_suf and
            poitem.po_release = inserted.ref_release and
            inserted.ref_type ='P'
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = poitem.rowpointer)
                 
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
          begin
            exec dbo.ApsSyncPurchaseOrderSp @Partition
            delete from TrackRows where Sessionid = @Partition
          end
      end

      if exists (select top 1 rowpointer from inserted where ref_type = 'R' )
      begin   
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,preqitem.rowpointer
            ,'Sync preqitem'
          from inserted
          join preqitem with (readuncommitted) on
            preqitem.req_num = inserted.ref_num and
            preqitem.req_line = inserted.ref_line_suf and
            inserted.ref_type ='R'
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = preqitem.rowpointer)
                 
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
          begin
            exec dbo.ApsSyncPreqOrderSp @Partition
            delete from TrackRows where Sessionid = @Partition
          end
      end

      if exists (select top 1 rowpointer from inserted where ref_type = 'T' )
      begin   
          insert into TrackRows (
             SessionId, RowPointer, TrackedOperType)
          select distinct
            @Partition
            ,trnitem.rowpointer
            ,'Sync trnitem'
          from inserted
          join trnitem WITH (READUNCOMMITTED) on
            trnitem.trn_num = inserted.ref_num and
            trnitem.trn_line = inserted.ref_line_suf and
            inserted.ref_type ='T' 
          where not exists( select * from TrackRows with (readuncommitted) where SessionId = @Partition and RowPointer = trnitem.rowpointer)

   
          if @@RowCount <> 0 and dbo.VariableIsDefined('ApsSyncDeferred') = 0
          begin
            exec dbo.ApsSyncTransferOrderSp @Partition
            delete from TrackRows where Sessionid = @Partition
          end
      end


end
-- ZPV
declare
	@TotShipped		QtyUnitNoNegType,
	@TotInvoiced	QtyUnitNoNegType,
	@TotOrdered		QtyUnitNoNegType
	
if update(qty_shipped) or update(qty_invoiced)
begin
	select
		@TotShipped = isnull((select sum(coi.qty_shipped) from coitem coi where coi.co_num = @CoNum and coi.co_line = @CoLine),0)
	,	@TotInvoiced = isnull((select sum(coi.qty_invoiced) from coitem coi where coi.co_num = @CoNum and coi.co_line = @CoLine),0)
	,	@TotOrdered = isnull((select sum(coi.qty_ordered) from coitem coi where coi.co_num = @CoNum and coi.co_line = @CoLine),0)
		
	update co_bln
		set co_bln.zpv_qty_shipped	= @TotShipped,
			co_bln.zpv_qty_invoiced = @TotInvoiced
		where co_bln.co_num = @CoNum and co_bln.co_line = @CoLine
		
	if @TotShipped >= @TotOrdered
	update co_mst	
		set zpv_stat_internal = 'D02'
	where co_num = @CoNum

	if @TotShipped < @TotOrdered and @TotShipped > 0
	update co_mst	
		set zpv_stat_internal = 'D03'
	where co_num = @CoNum

end
-- ZPV




-- Maintenance of Audit-columns is now performed by the generated triggers coitemInsert and coitemUpdatePenultimate.

-- Maintenance of coitem_all is now performed by the generated triggers coitemInsert and coitemUpdatePenultimate.

GO

EXEC sp_settriggerorder @triggername=N'[dbo].[coitem_mstIup]', @order=N'First', @stmttype=N'INSERT'
GO

EXEC sp_settriggerorder @triggername=N'[dbo].[coitem_mstIup]', @order=N'First', @stmttype=N'UPDATE'
GO
