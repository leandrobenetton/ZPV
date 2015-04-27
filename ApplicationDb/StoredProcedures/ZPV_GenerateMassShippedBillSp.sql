/****** Object:  StoredProcedure [dbo].[ZPV_GenerateMassShippedBillSp]    Script Date: 30/12/2014 10:48:36 a.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GenerateMassShippedBillSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GenerateMassShippedBillSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GenerateMassShippedBillSp]    Script Date: 30/12/2014 10:48:36 a.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Archive: /ApplicationDB/Stored Procedures/CoUpdateCommSlsmanSp.sp $
 *
 * SL8.02 11 rs4588 Dahn Thu Mar 04 10:28:55 2010
 * RS4588 Copyright header changes
 *
 * $NoKeywords: $
 */

CREATE PROCEDURE [dbo].[ZPV_GenerateMassShippedBillSp] (
	@CustNum		CustNumType
,	@Infobar InfobarType OUTPUT
)
AS

declare @Severity int

set @Severity = 0

declare 
	@CoNum			CoNumType
,	@ZlaArTypeId	ZlaArTypeIdType

declare CurCoBill cursor for
select
	co_num
from zpv_tt_cobill	
where	cust_num = @CustNum
open CurCoBill
fetch next from CurCoBill
into @CoNum
while @@FETCH_STATUS = 0
begin
	select 
		@ZlaArTypeId = co.zla_ar_type_id
	from co
	where co.co_num = @CoNum

	EXEC	@Severity = [dbo].[ZPV_GenerateShippedBillSp]
		@CoNum = @CoNum,
		@ZlaArTypeId = @ZlaArTypeId,
		@Infobar = @Infobar OUTPUT

	fetch next from CurCoBill
	into @CoNum
end
close CurCoBill
deallocate CurCoBill

RETURN @Severity
GO

