/****** Object:  StoredProcedure [dbo].[ZPV_GetCoLineDueDateSp]    Script Date: 11/06/2014 16:24:27 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GetCoLineDueDateSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GetCoLineDueDateSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GetCoLineDueDateSp]    Script Date: 11/06/2014 16:24:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





/* $Header: /ApplicationDB/Stored Procedures/GetVendorParmSp.sp 7     3/04/10 1:23p Dahn $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZAR_GetVendorInfoSp.sp $
 *
 * SL9.00 7 ljb LBenetton Thu Apr 17 13:00:00 2014
 * Initial Program
 *
 */
CREATE PROCEDURE [dbo].[ZPV_GetCoLineDueDateSp]  (
  @pItem		ItemType,
  @pQty			QtyUnitType,
  @pDueDate		DateType output,
  @Infobar		InfobarType output
) 
AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_GetCoLineDueDateSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_GetCoLineDueDateSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      EXEC @EXTGEN_SpName
		@pItem,
		@pQty,
		@pDueDate output,
		@Infobar output
      -- ETP routine must take over all desired functionality of this standard routine:
      RETURN 0
   END
   -- End of Generic External Touch Point code.
 
DECLARE
  @Severity INT

SET  @Severity = 0

declare
	@QtyOnHand	QtyUnitType
		
select @QtyOnHand = whse.qty_on_hand from itemwhse_mst whse where whse.item = @pItem

select @QtyOnHand

if @QtyOnHand > 0 
begin
	set @pDueDate = GETDATE() + 2
end

if @QtyOnHand <= 0
begin
	if exists(select * from poitem_mst poi where poi.item = @pItem and poi.qty_ordered > poi.qty_received) 
	begin
		select @pDueDate = poi.due_date + 2 from poitem_mst poi where poi.item = @pItem and poi.qty_ordered > poi.qty_received
	end
	else
	begin
		select @pDueDate = GETDATE() + item.lead_time + 2 from item_mst item where item.item = @pItem
		if @pDueDate is null set @pDueDate = getdate() + 62
	end
end

return @Severity
GO

