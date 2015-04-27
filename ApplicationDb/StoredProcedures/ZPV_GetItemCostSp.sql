/****** Object:  StoredProcedure [dbo].[ZPV_GetItemCostSp]    Script Date: 30/12/2014 10:49:16 a.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GetItemCostSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GetItemCostSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GetItemCostSp]    Script Date: 30/12/2014 10:49:16 a.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_GetItemCostSp] (
	@Item		ItemType,
	@Whse		WhseType,
	@Loc		LocType,
	@Lot		LotType,
	@UM			UMType,
	@Cost		AmountType	   OUTPUT,
	@CostMarkUp	LineDiscType   OUTPUT,
	@Infobar    Infobar        OUTPUT
)
AS

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

if @Lot is null
begin
	select
		@Cost = item.unit_cost
	from item_mst item
	where
		item.item = @Item
end
else
begin
	if exists(select * from item where lot_tracked = 1 and item = @Item)
	begin
		select
			@Cost = item.unit_cost
		from item_mst item
		where
			item.item = @Item
	end	
	else
	begin
		set @Cost = 0
	end
end

return @severity




GO

