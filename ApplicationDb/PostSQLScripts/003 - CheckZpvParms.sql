disable trigger co_mstIup on co_mst;
go
disable trigger co_bln_mstIup on co_bln_mst;
go
disable trigger coitem_mstIup on coitem_mst;
go

DECLARE 
	@Site SiteType,
	@Infobar	InfobarType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

if not exists(select 1 from zpv_parms where parms_key = 0)
begin
	insert into zpv_parms(
		parms_key,
		ref_site)
	values(
		0,
		@Site)
end

begin
	update zpv_drawer set check_in = 0 where check_in is null
	update zpv_drawer_trans set relief_num = 0 where relief_num is null
	update zpv_drawer_trans set from_relief_num = 0 where from_relief_num is null
end

begin
	update co_mst set	zpv_inv_num				= 0 where zpv_inv_num			is null
	update co_mst set	zpv_payment_generated	= 0 where zpv_payment_generated is null
	--update co_mst set	zpv_cust_seq			= 0 where zpv_cust_seq			is null
	update co_mst set	zpv_disc_freight		= 0 where zpv_disc_freight		is null
	update co_mst set	zpv_order_freight		= 0 where zpv_order_freight		is null
	update co_mst set	zpv_co_markup			= 0 where zpv_co_markup			is null
	update co_mst set	zpv_fixed_price			= 0 where zpv_fixed_price		is null
	--update co_mst set	zpv_freecharge_amount	= 0 where zpv_freecharge_amount is null

	update co_bln_mst	set zpv_qty_shipped		= 0 where zpv_qty_shipped		is null
	update co_bln_mst	set zpv_qty_returned	= 0 where zpv_qty_returned		is null
	update co_bln_mst	set zpv_qty_invoiced	= 0 where zpv_qty_invoiced		is null
	update co_bln_mst	set zpv_prg_bill_app	= 0 where zpv_prg_bill_app		is null
	update co_bln_mst	set zpv_prg_bill_tot	= 0 where zpv_prg_bill_tot		is null
	update co_bln_mst	set zpv_promotion_disc	= 0 where zpv_promotion_disc	is null
	update co_bln_mst	set zpv_co_disc			= 0 where zpv_co_disc			is null
	update co_bln_mst	set zpv_res_temp		= 0 where zpv_res_temp			is null
	--update co_bln_mst	set zpv_freecharge_rate	= 0 where zpv_freecharge_rate	is null
	--update co_bln_mst	set zpv_freecharge_amount	= 0 where zpv_freecharge_amount			is null
	--update co_bln_mst	set zpv_cust_seq		= 0 where zpv_cust_seq			is null

	--update coitem_mst	set zpv_cust_seq		= 0 where zpv_cust_seq			is null
end
go

enable trigger co_mstIup on co_mst;
go
enable trigger co_bln_mstIup on co_bln_mst;
go
enable trigger coitem_mstIup on coitem_mst;
go
