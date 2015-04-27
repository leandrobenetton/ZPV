/****** Object:  StoredProcedure [dbo].[ZPV_SetOrderCoReleasesSp]    Script Date: 30/12/2014 10:48:07 a.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_SetOrderCoReleasesSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_SetOrderCoReleasesSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_SetOrderCoReleasesSp]    Script Date: 30/12/2014 10:48:07 a.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




/* $Header: /ApplicationDB/Stored Procedures/ZPV_POSARPaymentGenerateSp.sp 3     3/04/10 10:13a Dahn $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/ZPV_POSARPaymentGenerateSp.sp $
 *
 * SL9.00.10 1 ljb Benetton Fri May 16 13:00:00 2014

 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_SetOrderCoReleasesSp] (
	@CoNum			CoNumType = null,
	@Stat			varchar(1) = null,
	@Infobar         InfobarType     OUTPUT
) AS

 
DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@CoLine		int,
	@CoRelease	int,
	@CoitemStat	varchar(1),
	@CoitemQtyOrdered	QtyUnitNoNegType,
	@CoitemQtyShipped	QtyUnitNoNegType,
	@CoitemQtyReturned	QtyUnitNoNegType

declare
	@CoBlnStat	varchar(1)	

if @Stat = 'O'	
begin
	update co
		set co.stat = 'O'
	where	co.co_num = @CoNum

	update co_bln
		set co_bln.stat = 'O'
	where	co_bln.co_num = @CoNum
end

declare CurReleases cursor for
select
	coi.co_line,
	coi.co_release,
	coi.stat,
	coi.qty_ordered,
	coi.qty_shipped,
	coi.qty_returned
from coitem coi
open CurReleases
fetch next from CurReleases
into
	@CoLine,
	@CoRelease,
	@CoitemStat,
	@CoitemQtyOrdered,
	@CoitemQtyShipped,
	@CoitemQtyReturned
while @@FETCH_STATUS = 0
begin
	if @CoitemQtyShipped = 0 
	begin
		if @Stat = 'O'
		begin
			update coitem
				set coitem.stat = 'O'
			where	coitem.co_num = @CoNum 
				and	coitem.co_line = @CoLine
				and coitem.co_release = @CoRelease

		end
			
		if @Stat = 'P'
		begin
			update coitem
				set coitem.stat = 'P'
			where	coitem.co_num = @CoNum 
				and	coitem.co_line = @CoLine
				and coitem.co_release = @CoRelease

		end		
	end
	
	fetch next from CurReleases
	into
		@CoLine,
		@CoRelease,
		@CoitemStat,
		@CoitemQtyOrdered,
		@CoitemQtyShipped,
		@CoitemQtyReturned
end
close CurReleases
deallocate CurReleases

if @Stat = 'P'	
begin
	update co_bln
		set co_bln.stat = 'P'
	where	co_bln.co_num = @CoNum
end


			 
RETURN




GO

