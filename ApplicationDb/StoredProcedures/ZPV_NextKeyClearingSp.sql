/****** Object:  StoredProcedure [dbo].[ZPV_NextKeyClearingSp]    Script Date: 16/02/2015 01:03:49 a.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_NextKeyClearingSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_NextKeyClearingSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_NextKeyClearingSp]    Script Date: 16/02/2015 01:03:49 a.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ZPV_NextKeyClearingSp] (
	@NextClearing	ZpvClearingType OUTPUT
,	@Infobar	InfobarType   OUTPUT
)
AS

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

declare
	@Prefix		varchar(3)
,	@NextCle	numeric(10)
,	@LenCo		int
,	@MiddleCo	varchar(10)
,	@LenMiddle	int
,	@Largo		int
,	@LenPrefix	int

--select @Prefix = isnull(pos.prefix,'') from zpv_co_pos pos where pos.pos_code = @POS

--set @Largo  = 10
--set @LenPrefix = len(@Prefix) + 1

--select top 1 
--	@NextCo = cast(ltrim(substring(co.co_num,@LenPrefix,10)) as numeric(10)) + 1 
--from co_mst co 
--where co.zpv_pos = @POS 
--order by co.co_num desc

--if @NextCo is null set @NextCo = 1

--select 
--	@LenCo = len(@NextCo)
--,	@LenMiddle = @Largo - len(@NextCo) - len(@Prefix)
--,	@MiddleCo = ''

--while @LenMiddle > 0 
--begin
--	select 
--		@MiddleCo = @MiddleCo + '0'
--	,	@LenMiddle = @LenMiddle - 1 
--end

select top 1 @NextCle = cast(cl.clearing as numeric(10)) + 1 from zpv_ar_clearing cl where cl.clearing is not null order by cl.clearing desc
if @NextCle is null set @NextCle = 1

select @NextClearing = cast(@NextCle as varchar(10))

return @severity

GO

