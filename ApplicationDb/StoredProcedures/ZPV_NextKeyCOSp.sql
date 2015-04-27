/****** Object:  StoredProcedure [dbo].[º]    Script Date: 10/08/2014 14:54:29 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_NextKeyCOSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_NextKeyCOSp]
GO


/****** Object:  StoredProcedure [dbo].[ZPV_NextKeyCOSp]    Script Date: 10/08/2014 14:54:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_NextKeyCOSp] (
	@POS		varchar(15)
,	@NextCoNum	CoNumType OUTPUT
,	@Infobar	InfobarType   OUTPUT
)
AS


DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

declare
	@Prefix		varchar(10)
,	@NextCo		numeric(10)
,	@LenCo		int
,	@MiddleCo	varchar(10)
,	@LenMiddle	int
,	@Largo		int
,	@LenPrefix	int

select @Prefix = isnull(pos.prefix,'') from zpv_co_pos pos where pos.pos_code = @POS

set @Largo  = 10
set @LenPrefix = len(@Prefix)

select top 1 
	@NextCo = cast(ltrim(substring(co.co_num,@LenPrefix,10)) as numeric(10)) + 1 
from co_mst co 
where co.zpv_pos = @POS 
order by co.co_num desc

if @NextCo is null set @NextCo = 1

select 
	@LenCo = len(@NextCo)
,	@LenMiddle = @Largo - len(@NextCo) - len(@Prefix)
,	@MiddleCo = ''

while @LenMiddle > 0 
begin
	select 
		@MiddleCo = @MiddleCo + '0'
	,	@LenMiddle = @LenMiddle - 1 
end

select @NextCoNum = cast(@Prefix as varchar(10)) + cast(@MiddleCo as varchar(10)) + cast(@NextCo as varchar(10))

return @severity

GO

