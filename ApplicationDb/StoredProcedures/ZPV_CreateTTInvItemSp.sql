/****** Object:  StoredProcedure [dbo].[ZPV_CreateTTInvItemSp]    Script Date: 16/01/2015 03:12:36 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CreateTTInvItemSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CreateTTInvItemSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CreateTTInvItemSp]    Script Date: 16/01/2015 03:12:36 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_CreateTTInvItemSp] (
	@pCoNum			CoNumType	
,	@Infobar		InfobarType OUTPUT
)
AS

declare
	@TTInvItemCoNum		CoNumType
,	@TTInvItemCoLine	CoLineType
,	@TTInvItemItem		ItemType
,	@TTInvItemDescription	DescriptionType
,	@TTInvItemQtyInvoiced	QtyUnitType
,	@TTInvItemQtyNulled		QtyUnitType
,	@TTInvItemTotalInvoiced	AmountType
,	@TTInvItemTotalNulled	AmountType

delete from zpv_tt_invitem

insert into zpv_tt_invitem(
	co_num
,	co_line
,	item
,	description
,	qty_invoiced
,	total_invoiced
,	qty_nulled
,	total_nulled)
select
	inv.co_num,
	inv.co_line,
	inv.item,
	item.description,
	sum(inv.qty_invoiced),
	sum(inv.price),
	sum(inv.qty_invoiced),
	sum(inv.price)
from inv_item_mst inv
inner join item_mst item on item.item = inv.item
where inv.co_num = @pCoNum
group by inv.co_num, inv.co_line, inv.item, item.description



GO

