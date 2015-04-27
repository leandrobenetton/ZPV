/*
SELECT
	ORDINAL_POSITION,
	TABLE_NAME,
	COLUMN_NAME,
	DOMAIN_NAME,
	DATA_TYPE,
	CHARACTER_MAXIMUM_LENGTH,
	NUMERIC_PRECISION,
	NUMERIC_PRECISION_RADIX
FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name like 'zpv%' and ORDINAL_POSITION > 7 --and TABLE_NAME like '%mst' and (COLUMN_NAME like 'zpv%' or  COLUMN_NAME like 'zwm%')
ORDER BY TABLE_NAME, ORDINAL_POSITION
*/

-- co_bln_mst --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_ship_whse')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_ship_whse] [dbo].[WhseType] NULL --40

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_res_whse')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_res_whse] [dbo].[WhseType] NULL --41

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_shiptype')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_shiptype] [varchar](4) NULL --42

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_lot')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_lot] [dbo].[LotType] NULL --43

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_total')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_total] [dbo].[AmountType] NULL --44

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_total_disc')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_total_disc] [dbo].[AmountType] NULL --45

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_tax_code1')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_tax_code1] [dbo].[TaxCodeType] NULL --46

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_tax_code2')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_tax_code2] [dbo].[TaxCodeType] NULL --47

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_qty_shipped')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_qty_shipped] [dbo].[QtyTotlType] NULL --48

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_qty_returned')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_qty_returned] [dbo].[QtyTotlType] NULL --49

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_qty_invoiced')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_qty_invoiced] [dbo].[QtyTotlType] NULL --50

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_prg_bill_tot')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_prg_bill_tot] [dbo].[AmountType] NULL --51

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_prg_bill_app')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_prg_bill_app] [dbo].[AmountType] NULL --52

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_stat')
ALTER TABLE [dbo].[co_bln_mst] ADD [zpv_stat] varchar(5) NULL --53

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_promotion_code')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_promotion_code varchar(10) NULL --54

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_unit_price')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_unit_price [dbo].[AmountType] NULL --55

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_promotion_disc')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_promotion_disc decimal(11,3) NULL --56

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_co_disc')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_co_disc decimal(11,3) NULL --57

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_freight_apply')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_freight_apply dbo.ListYesNoType NULL --58

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_sales_tax')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_sales_tax dbo.AmountType NULL --59

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_sales_tax2')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_sales_tax2 dbo.AmountType NULL --60

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_loc')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_loc dbo.LocType NULL --61

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_res_temp')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_res_temp dbo.ListYesNoType NULL --62

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_bln_mst' AND COLUMN_NAME = 'zpv_obs_producto')
ALTER TABLE [dbo].[co_bln_mst] ADD zpv_obs_producto varchar(4000) NULL --63


-- co_mst --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_fiscal_name')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_fiscal_name varchar(100) NULL --134

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_addr1')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_addr1 [dbo].[AddressType] NULL --135

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_addr2')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_addr2 [dbo].[AddressType] NULL --136

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_addr3')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_addr3 [dbo].[AddressType] NULL --137

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_addr4')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_addr4 [dbo].[AddressType] NULL --138

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_city')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_city [dbo].[CityType] NULL --139

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_state')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_state [dbo].[StateType] NULL --140

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_zip')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_zip [dbo].[PostalCodeType] NULL --141

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_county')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_county [dbo].[CountyType] NULL --142

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_country')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_country [dbo].[CountryType] NULL --143

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_cuit')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_cuit [dbo].[ZpvCuitType] NULL --144

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_stat')
ALTER TABLE [dbo].[co_mst] ADD zpv_stat [varchar](3) NULL --145

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_stat_internal')
ALTER TABLE [dbo].[co_mst] ADD zpv_stat_internal [varchar](3) NULL --146

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_inv_num')
ALTER TABLE [dbo].[co_mst] ADD zpv_inv_num [dbo].[InvNumType] NULL --147

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_payment_generated')
ALTER TABLE [dbo].[co_mst] ADD zpv_payment_generated [dbo].[ListYesNoType] NULL --148

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_email')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_email varchar(100) NULL --149

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_phone')
ALTER TABLE [dbo].[co_mst] ADD zpv_phone [dbo].[PhoneType] NULL --150

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_slsman')
ALTER TABLE [dbo].[co_mst] ADD zpv_slsman [dbo].[SlsmanType] NULL --151

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_slsman_s')
ALTER TABLE [dbo].[co_mst] ADD zpv_slsman_s [dbo].[SlsmanType] NULL --152

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_pos')
ALTER TABLE [dbo].[co_mst] ADD zpv_pos varchar(15) NULL --153

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_bill_type_doc')
ALTER TABLE [dbo].[co_mst] ADD zpv_bill_type_doc varchar(10) NULL --154

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_drawer')
ALTER TABLE [dbo].[co_mst] ADD zpv_drawer varchar(15) NULL --155

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_disc_freight')
ALTER TABLE [dbo].[co_mst] ADD zpv_disc_freight dbo.OrderDiscType NULL --156

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_order_freight')
ALTER TABLE [dbo].[co_mst] ADD zpv_order_freight dbo.AmountType NULL --157

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_co_markup')
ALTER TABLE [dbo].[co_mst] ADD zpv_co_markup dbo.OrderDiscType NULL --158

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_slsman_s_perc')
ALTER TABLE [dbo].[co_mst] ADD zpv_slsman_s_perc dbo.OrderDiscType NULL --159

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_markup')
ALTER TABLE [dbo].[co_mst] ADD zpv_markup dbo.OrderDiscType NULL --160

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_user')
ALTER TABLE [dbo].[co_mst] ADD zpv_user dbo.UsernameType NOT NULL DEFAULT (suser_sname()) --161

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_fixed_price')
ALTER TABLE [dbo].[co_mst] ADD zpv_fixed_price dbo.ListYesNoType NULL DEFAULT ((0)) --162

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_convenio')
ALTER TABLE [dbo].[co_mst] ADD zpv_convenio varchar(10) NULL --163

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_follow')
ALTER TABLE [dbo].[co_mst] ADD zpv_follow varchar(10) NULL --164

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_f12')
ALTER TABLE [dbo].[co_mst] ADD zpv_f12 numeric(12) NULL --165

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_logis_stat1')
ALTER TABLE [dbo].[co_mst] ADD zpv_logis_stat1 varchar(10) NULL --166

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_logis_stat2')
ALTER TABLE [dbo].[co_mst] ADD zpv_logis_stat2 varchar(10) NULL --167

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'co_mst' AND COLUMN_NAME = 'zpv_f12')
ALTER TABLE [dbo].[co_mst] ADD zpv_f12 numeric(12) NULL --168

-- coitem_mst --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'coitem_mst' AND COLUMN_NAME = 'zpv_ship_whse')
ALTER TABLE [dbo].[coitem_mst] ADD [zpv_ship_whse] [dbo].[WhseType] NULL --120

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'coitem_mst' AND COLUMN_NAME = 'zpv_lot')
ALTER TABLE [dbo].[coitem_mst] ADD [zpv_lot] [dbo].[LotType] NULL --121

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'coitem_mst' AND COLUMN_NAME = 'zwm_ship_code')
ALTER TABLE [dbo].[coitem_mst] ADD zwm_ship_code [dbo].ShipCodeType NULL --122

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'coitem_mst' AND COLUMN_NAME = 'zpv_obs')
ALTER TABLE [dbo].[coitem_mst] ADD zpv_obs varchar(500) NULL --123

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'coitem_mst' AND COLUMN_NAME = 'zpv_loc')
ALTER TABLE [dbo].[coitem_mst] ADD zpv_loc dbo.LocType NULL --124

-- custaddr_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'custaddr_mst' AND COLUMN_NAME = 'zwm_route')
ALTER TABLE [dbo].custaddr_mst ADD zwm_route [varchar](15) NULL --44

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'custaddr_mst' AND COLUMN_NAME = 'zpv_obs')
ALTER TABLE [dbo].custaddr_mst ADD zpv_obs [varchar](5000) NULL --46

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'custaddr_mst' AND COLUMN_NAME = 'zpv_geoloc')
ALTER TABLE [dbo].custaddr_mst ADD zpv_geoloc [varchar](30) NULL --47

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'custaddr_mst' AND COLUMN_NAME = 'zpv_transport')
ALTER TABLE [dbo].custaddr_mst ADD zpv_transport ListYesNoType NULL --48

-- item_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'item_mst' AND COLUMN_NAME = 'zpv_exclusive')
ALTER TABLE [dbo].item_mst ADD zpv_exclusive ListYesNoType NULL DEFAULT ((0))

-- posm_drawer_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_drawer_mst' AND COLUMN_NAME = 'zpv_pos_code')
ALTER TABLE [dbo].posm_drawer_mst ADD zpv_pos_code varchar(15) NULL --28

-- posm_pay_type_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_credit_generate')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD [zpv_credit_generate] dbo.ListYesNoType NULL --34

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_discount')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_discount dbo.ApDiscType NULL --35

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_ret_code')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_ret_code varchar(10) NULL --36

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_from_date')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_from_date dbo.DateType NULL --37

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_to_date')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_to_date dbo.DateType NULL --38

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_terms_code')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_terms_code dbo.TermsCodeType NULL --39

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_ar_type_id')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_ar_type_id dbo.ZlaArTypeIdType NULL --40

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'posm_pay_type_mst' AND COLUMN_NAME = 'zpv_tax')
ALTER TABLE [dbo].[posm_pay_type_mst] ADD zpv_tax dbo.ListYesNoType NULL --41


-- price_promotion_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'price_promotion_mst' AND COLUMN_NAME = 'zpv_group_desc')
ALTER TABLE [dbo].[price_promotion_mst] ADD [zpv_group_desc] varchar(10) NULL --44

-- pricecode_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'pricecode_mst' AND COLUMN_NAME = 'markup1')
ALTER TABLE [dbo].[pricecode_mst] ADD [markup1] decimal(10,3) NULL 

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'pricecode_mst' AND COLUMN_NAME = 'markup2')
ALTER TABLE [dbo].[pricecode_mst] ADD [markup2] decimal(10,3) NULL 

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'pricecode_mst' AND COLUMN_NAME = 'markup3')
ALTER TABLE [dbo].[pricecode_mst] ADD [markup3] decimal(10,3) NULL 

-- slsclass_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'slsclass_mst' AND COLUMN_NAME = 'zpv_disc_max')
ALTER TABLE [dbo].[slsclass_mst] ADD zpv_disc_max dbo.OrderDiscType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'slsclass_mst' AND COLUMN_NAME = 'zpv_master')
ALTER TABLE [dbo].[slsclass_mst] ADD zpv_master dbo.ListYesNoType NULL --12

-- terms_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'terms_mst' AND COLUMN_NAME = 'zpv_group_desc')
ALTER TABLE [dbo].[terms_mst] ADD [zpv_group_desc] varchar(10) NULL --25

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'terms_mst' AND COLUMN_NAME = 'zpv_type')
ALTER TABLE [dbo].[terms_mst] ADD zpv_type varchar(1) NULL --26

-- zla_ar_hdr_mst
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zla_ar_hdr_mst' AND COLUMN_NAME = 'zpv_amount')
ALTER TABLE [dbo].[zla_ar_hdr_mst] ADD [zpv_amount] AmountType NULL DEFAULT((0))

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zla_ar_hdr_mst' AND COLUMN_NAME = 'zpv_clearing')
ALTER TABLE [dbo].[zla_ar_hdr_mst] ADD [zpv_clearing] ZpvClearingType NULL 

------------------------------------------------------------ZPV--------------------------------------------------------------------
-- zpv_ar_clearing
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_clearing' AND COLUMN_NAME = 'posm_pay_type')
ALTER TABLE [dbo].zpv_ar_clearing ADD posm_pay_type dbo.POSMPayTypeType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_clearing' AND COLUMN_NAME = 'bank_code')
ALTER TABLE [dbo].zpv_ar_clearing ADD bank_code dbo.BankCodeType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_clearing' AND COLUMN_NAME = 'ar_pay_type')
ALTER TABLE [dbo].zpv_ar_clearing ADD ar_pay_type dbo.ZlaLastTranIdType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_clearing' AND COLUMN_NAME = 'amount_applied')
ALTER TABLE [dbo].zpv_ar_clearing ADD amount_applied dbo.AmountType NULL DEFAULT((0)) --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_clearing' AND COLUMN_NAME = 'stat')
ALTER TABLE [dbo].zpv_ar_clearing ADD stat varchar(1) NULL  --12

-- zpv_ar_clearing_expenses
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_clearing_expenses' AND COLUMN_NAME = 'ar_pay_id')
ALTER TABLE [dbo].zpv_ar_clearing_expenses ADD ar_pay_id dbo.ZlaArPayIdType NULL  --8

-- zpv_ar_payments --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ar_pay_id')
ALTER TABLE [dbo].zpv_ar_payments ADD ar_pay_id dbo.ZlaArPayIdType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'pay_seq')
ALTER TABLE [dbo].zpv_ar_payments ADD pay_seq int NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'pay_type')
ALTER TABLE [dbo].zpv_ar_payments ADD pay_type varchar(30) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'pay_date')
ALTER TABLE [dbo].zpv_ar_payments ADD pay_date dbo.DateType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'due_date')
ALTER TABLE [dbo].zpv_ar_payments ADD due_date dbo.DateType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'curr_code')
ALTER TABLE [dbo].zpv_ar_payments ADD curr_code dbo.CurrCodeType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'amount')
ALTER TABLE [dbo].zpv_ar_payments ADD amount dbo.AmountType NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'bank_code')
ALTER TABLE [dbo].zpv_ar_payments ADD bank_code dbo.BankCodeType NULL --15

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'check_num')
ALTER TABLE [dbo].zpv_ar_payments ADD check_num numeric(10) NULL --16

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'exch_rate')
ALTER TABLE [dbo].zpv_ar_payments ADD exch_rate dbo.ExchRateType NULL --17

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'for_amount')
ALTER TABLE [dbo].zpv_ar_payments ADD for_amount dbo.AmountType NULL --18

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'site_ref')
ALTER TABLE [dbo].zpv_ar_payments ADD site_ref dbo.SiteType NULL --19

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_name')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_name dbo.NameType NULL --20

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_due_date')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_due_date dbo.DateType NULL --21

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_number')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_number varchar(30) NULL --22

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_auth_code')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_auth_code varchar(10) NULL --23

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_phone')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_phone varchar(30) NULL --24

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_emit')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_emit varchar(50) NULL --25

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_bank')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_bank varchar(50) NULL --26

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'pay_cc')
ALTER TABLE [dbo].zpv_ar_payments ADD pay_cc dbo.ListYesNoType NULL --27

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_order_by')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_order_by dbo.FlagNyType NULL --28

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_bank')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_bank dbo.BankCodeType NULL --29

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_check_date')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_check_date dbo.DateType NULL --30

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_cuit')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_cuit varchar(30) NULL --31

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_description')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_description varchar(60) NULL --32

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_check_3ros')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_check_3ros dbo.FlagNyType NULL --33

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_due_date')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_due_date dbo.DateType NULL --34

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_cupon')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_cupon varchar(30) NULL --35

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cc_quotes')
ALTER TABLE [dbo].zpv_ar_payments ADD cc_quotes int NULL --36

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'tax_document')
ALTER TABLE [dbo].zpv_ar_payments ADD tax_document varchar(30) NULL --37

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'posted')
ALTER TABLE [dbo].zpv_ar_payments ADD posted dbo.FlagNyType NULL --38

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'drawer')
ALTER TABLE [dbo].zpv_ar_payments ADD drawer varchar(15) NULL --39

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'cust_num')
ALTER TABLE [dbo].zpv_ar_payments ADD cust_num dbo.CustNumType NOT NULL --40

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'apply')
ALTER TABLE [dbo].zpv_ar_payments ADD apply dbo.FlagNyType NULL --41

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'clearing')
ALTER TABLE [dbo].zpv_ar_payments ADD clearing dbo.ZpvClearingType NULL --42

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_ar_payments' AND COLUMN_NAME = 'ck_approv_num')
ALTER TABLE [dbo].zpv_ar_payments ADD ck_approv_num varchar(15) NULL --43



-- zpv_bank_ptype --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'bank_id')
ALTER TABLE [dbo].zpv_bank_ptype ADD bank_id dbo.BankCodeType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'posm_pay_type')
ALTER TABLE [dbo].zpv_bank_ptype ADD posm_pay_type dbo.POSMPayTypeType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'credit_memo')
ALTER TABLE [dbo].zpv_bank_ptype ADD credit_memo dbo.BankCodeType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'zla_ar_type_id')
ALTER TABLE [dbo].zpv_bank_ptype ADD zla_ar_type_id dbo.ZlaArTypeIdType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'term_disc')
ALTER TABLE [dbo].zpv_bank_ptype ADD term_disc dbo.FlagNyType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'disc')
ALTER TABLE [dbo].zpv_bank_ptype ADD disc dbo.TaxRateType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'ret_code')
ALTER TABLE [dbo].zpv_bank_ptype ADD ret_code varchar(10) NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'from_date')
ALTER TABLE [dbo].zpv_bank_ptype ADD from_date dbo.DateType NULL --15

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'to_date')
ALTER TABLE [dbo].zpv_bank_ptype ADD to_date dbo.DateType NULL --16

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_bank_ptype' AND COLUMN_NAME = 'zla_doc_id')
ALTER TABLE [dbo].zpv_bank_ptype ADD zla_doc_id dbo.ZlaDocumentIdType NULL --17

-- zpv_co_codes
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_codes' AND COLUMN_NAME = 'end_user_type')
ALTER TABLE [dbo].[zpv_co_codes] ADD end_user_type dbo.EndUserTypeType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_codes' AND COLUMN_NAME = 'cust_type')
ALTER TABLE [dbo].[zpv_co_codes] ADD cust_type dbo.CustTypeType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_codes' AND COLUMN_NAME = 'ret_code')
ALTER TABLE [dbo].[zpv_co_codes] ADD ret_code varchar(10) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_codes' AND COLUMN_NAME = 'credit_limit')
ALTER TABLE [dbo].[zpv_co_codes] ADD credit_limit dbo.FlagNyType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_codes' AND COLUMN_NAME = 'doc_id')
ALTER TABLE [dbo].[zpv_co_codes] ADD doc_id  varchar(10) NULL --12


-- zpv_co_payments --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'co_num')
ALTER TABLE [dbo].[zpv_co_payments] ADD co_num dbo.CoNumType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'pay_seq')
ALTER TABLE [dbo].[zpv_co_payments] ADD pay_seq int NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'pay_type')
ALTER TABLE [dbo].[zpv_co_payments] ADD pay_type varchar(30) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'pay_date')
ALTER TABLE [dbo].[zpv_co_payments] ADD pay_date dbo.DateType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'due_date')
ALTER TABLE [dbo].[zpv_co_payments] ADD due_date dbo.DateType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'amount')
ALTER TABLE [dbo].[zpv_co_payments] ADD amount dbo.AmountType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'curr_code')
ALTER TABLE [dbo].[zpv_co_payments] ADD curr_code dbo.CurrCodeType NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'bank_code')
ALTER TABLE [dbo].[zpv_co_payments] ADD bank_code dbo.BankCodeType NULL --15

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'check_num')
ALTER TABLE [dbo].[zpv_co_payments] ADD check_num numeric(10) NULL --16

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'exch_rate')
ALTER TABLE [dbo].[zpv_co_payments] ADD exch_rate dbo.ExchRateType NULL --17

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'for_amount')
ALTER TABLE [dbo].[zpv_co_payments] ADD for_amount dbo.AmountType NULL --18

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'site_ref')
ALTER TABLE [dbo].[zpv_co_payments] ADD site_ref dbo.SiteType NULL --19

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_name')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_name dbo.NameType NULL --20

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_due_date')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_due_date dbo.DateType NULL --21

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_number')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_number varchar(30) NULL --22

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_auth_code')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_auth_code varchar(10) NULL --23

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_phone')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_phone varchar(30) NULL --24

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_emit')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_emit varchar(50) NULL --25

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_bank')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_bank varchar(50) NULL --26

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'pay_cc')
ALTER TABLE [dbo].[zpv_co_payments] ADD pay_cc dbo.ListYesNoType NULL --27

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_order_by')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_order_by dbo.FlagNyType NULL --28

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_bank')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_bank dbo.BankCodeType NULL --29

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_check_date')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_check_date dbo.DateType NULL --30

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_cuit')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_cuit varchar(30) NULL --31

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_description')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_description varchar(60) NULL --32

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_check_3ros')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_check_3ros dbo.FlagNyType NULL --33

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_due_date')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_due_date dbo.DateType NULL --34

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_cupon')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_cupon varchar(30) NULL --35

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'cc_quotes')
ALTER TABLE [dbo].[zpv_co_payments] ADD cc_quotes int NULL --36

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'tax_document')
ALTER TABLE [dbo].[zpv_co_payments] ADD tax_document varchar(30) NULL --37

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'posted')
ALTER TABLE [dbo].[zpv_co_payments] ADD posted dbo.FlagNyType NULL --38

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'drawer')
ALTER TABLE [dbo].[zpv_co_payments] ADD drawer varchar(15) NULL --39

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ar_pay_id')
ALTER TABLE [dbo].[zpv_co_payments] ADD ar_pay_id dbo.ZlaArPayIdType NULL --40

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_payments' AND COLUMN_NAME = 'ck_approv_num')
ALTER TABLE [dbo].[zpv_co_payments] ADD ck_approv_num varchar(15) NULL --41


-- zpv_co_pos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_pos' AND COLUMN_NAME = 'pos_code')
ALTER TABLE [dbo].zpv_co_pos ADD pos_code varchar(15) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_pos' AND COLUMN_NAME = 'description')
ALTER TABLE [dbo].zpv_co_pos ADD [description] dbo.DescriptionType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_pos' AND COLUMN_NAME = 'prefix')
ALTER TABLE [dbo].zpv_co_pos ADD [prefix] varchar(10) NULL --10

-- zpv_co_ret_code --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'ret_code')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD ret_code varchar(10) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'type')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD [type] varchar(20) NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'description')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD description varchar(50) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'days')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD days int NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'site_ref')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD site_ref dbo.SiteType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'reservation')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD reservation dbo.FlagNyType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'stop_tranfer')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD stop_tranfer dbo.FlagNyType NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_ret_code' AND COLUMN_NAME = 'GroupId')
ALTER TABLE [dbo].[zpv_co_ret_code] ADD GroupId dbo.TokenType NULL --15

-- zpv_co_retentions --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'co_num')
ALTER TABLE [dbo].[zpv_co_retentions] ADD co_num dbo.CoNumType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'ret_seq')
ALTER TABLE [dbo].[zpv_co_retentions] ADD ret_seq int NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'ret_code')
ALTER TABLE [dbo].[zpv_co_retentions] ADD ret_code varchar(10) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'ret_type')
ALTER TABLE [dbo].[zpv_co_retentions] ADD ret_type varchar(30) NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'ret_date')
ALTER TABLE [dbo].[zpv_co_retentions] ADD ret_date dbo.DateType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'site_ref')
ALTER TABLE [dbo].[zpv_co_retentions] ADD site_ref dbo.SiteType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_retentions' AND COLUMN_NAME = 'active')
ALTER TABLE [dbo].[zpv_co_retentions] ADD active int NULL --14

-- zpv_co_stat --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_stat' AND COLUMN_NAME = 'description')
ALTER TABLE [dbo].[zpv_co_stat] ADD [description] varchar(60) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_stat' AND COLUMN_NAME = 'sl_stat')
ALTER TABLE [dbo].[zpv_co_stat] ADD sl_stat varchar(1) NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_stat' AND COLUMN_NAME = 'hidden')
ALTER TABLE [dbo].[zpv_co_stat] ADD hidden varchar(1) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_stat' AND COLUMN_NAME = 'stat')
ALTER TABLE [dbo].[zpv_co_stat] ADD stat varchar(3) NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_co_stat' AND COLUMN_NAME = 'site_ref')
ALTER TABLE [dbo].[zpv_co_stat] ADD site_ref dbo.SiteType NULL --12

-- zpv_cobln_res --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'co_num')
ALTER TABLE [dbo].[zpv_cobln_res] ADD co_num dbo.CoNumType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'co_line')
ALTER TABLE [dbo].[zpv_cobln_res] ADD co_line dbo.CoLineType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'whse')
ALTER TABLE [dbo].[zpv_cobln_res] ADD whse dbo.WhseType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'lot')
ALTER TABLE [dbo].[zpv_cobln_res] ADD lot dbo.LotType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'qty_reserved')
ALTER TABLE [dbo].[zpv_cobln_res] ADD qty_reserved decimal(10,10) NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'trans_date')
ALTER TABLE [dbo].[zpv_cobln_res] ADD trans_date dbo.DateType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_res' AND COLUMN_NAME = 'item')
ALTER TABLE [dbo].[zpv_cobln_res] ADD item dbo.ItemType NULL --14

-- zpv_cobln_retention --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'co_num')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD co_num dbo.CoNumType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'ret_code')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD ret_code varchar(10) NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'ret_date')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD ret_date dbo.DateType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'ret_seq')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD ret_seq int NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'ret_type')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD ret_type varchar(30) NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'site_ref')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD site_ref dbo.SiteType NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'co_line')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD co_line dbo.CoLineType NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_cobln_retention' AND COLUMN_NAME = 'active')
ALTER TABLE [dbo].[zpv_cobln_retention] ADD active int NULL --15

-- zpv_drawer
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'drawer')
ALTER TABLE [dbo].[zpv_drawer] ADD drawer varchar(15) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'description')
ALTER TABLE [dbo].[zpv_drawer] ADD [description] DescriptionType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'closed')
ALTER TABLE [dbo].[zpv_drawer] ADD closed FlagNyType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'bank_code')
ALTER TABLE [dbo].[zpv_drawer] ADD bank_code BankCodeType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'bank_code_draft')
ALTER TABLE [dbo].[zpv_drawer] ADD bank_code_draft BankCodeType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'pos')
ALTER TABLE [dbo].[zpv_drawer] ADD pos varchar(15) NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'check_in')
ALTER TABLE [dbo].[zpv_drawer] ADD check_in FlagNyType NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'check_in_date')
ALTER TABLE [dbo].[zpv_drawer] ADD check_in_date CurrentDateType NULL --15

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'check_in_user')
ALTER TABLE [dbo].[zpv_drawer] ADD check_in_user UsernameType NULL --16

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'locked')
ALTER TABLE [dbo].[zpv_drawer] ADD locked FlagNyType NULL --17

-- zpv_drawer_pos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_pos' AND COLUMN_NAME = 'pos')
ALTER TABLE [dbo].[zpv_drawer_pos] ADD pos varchar(15) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_pos' AND COLUMN_NAME = 'drawer')
ALTER TABLE [dbo].[zpv_drawer_pos] ADD drawer varchar(15) NULL --9

-- zpv_drawer_ptype
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_ptype' AND COLUMN_NAME = 'drawer')
ALTER TABLE [dbo].[zpv_drawer_ptype] ADD drawer varchar(15) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_ptype' AND COLUMN_NAME = 'posm_pay_type')
ALTER TABLE [dbo].[zpv_drawer_ptype] ADD posm_pay_type POSMPayTypeType NULL --9

-- zpv_drawer_trans
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'trans_num')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD trans_num MatlTransNumType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'type')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD [type] varchar(1) NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'relief_num')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD relief_num MatlTransNumType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'trans_date')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD trans_date DateType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'packet')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD packet varchar(15) NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'drawer')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD drawer varchar(15) NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'glbank_rowpointer')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD glbank_rowpointer RowPointerType NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'copay_rowpointer')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD copay_rowpointer RowPointerType NULL --15

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'amount')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD amount AmountType NULL --16

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'curr_code')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD curr_code CurrCodeType NULL --17

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'exch_rate')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD exch_rate ExchRateType NULL --18

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'for_amount')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD for_amount AmountType NULL --19

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'apply_date')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD apply_date DateType NULL --20

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'ar_type_id')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD ar_type_id ZlaArTypeIdType NULL --21

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'co_num')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD co_num CoNumType NULL --22

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'zla_bank_type')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD zla_bank_type ZlaBankType NULL --23

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'pending')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD pending ListYesNoType NULL --24

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'from_drawer')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD from_drawer varchar(15) NULL --25

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'from_relief_num')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD from_relief_num MatlTransNumType NULL --26

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'amount_tranfer')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD amount_tranfer AmountType NULL --27

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'for_amount_tranfer')
ALTER TABLE [dbo].[zpv_drawer_trans] ADD for_amount_tranfer AmountType NULL --28

-- zpv_group_desc --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_group_desc' AND COLUMN_NAME = 'zpv_group_desc')
ALTER TABLE [dbo].[zpv_group_desc] ADD zpv_group_desc varchar(10) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_group_desc' AND COLUMN_NAME = 'terms_code')
ALTER TABLE [dbo].[zpv_group_desc] ADD terms_code dbo.TermsCodeType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_group_desc' AND COLUMN_NAME = 'promotion_code')
ALTER TABLE [dbo].[zpv_group_desc] ADD promotion_code dbo.PromotionCodeType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_group_desc' AND COLUMN_NAME = 'rank')
ALTER TABLE [dbo].[zpv_group_desc] ADD [rank] int NULL --11

-- zpv_parms --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'parms_key')
ALTER TABLE [dbo].zpv_parms ADD parms_key dbo.ParmKeyType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ref_site')
ALTER TABLE [dbo].zpv_parms ADD ref_site dbo.SiteType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'inv_to_ship_acct')
ALTER TABLE [dbo].zpv_parms ADD inv_to_ship_acct dbo.AcctType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'inv_to_ship_acct_unit1')
ALTER TABLE [dbo].zpv_parms ADD inv_to_ship_acct_unit1 dbo.UnitCode1Type NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'inv_to_ship_acct_unit2')
ALTER TABLE [dbo].zpv_parms ADD inv_to_ship_acct_unit2 dbo.UnitCode2Type NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'inv_to_ship_acct_unit3')
ALTER TABLE [dbo].zpv_parms ADD inv_to_ship_acct_unit3 dbo.UnitCode3Type NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'inv_to_ship_acct_unit4')
ALTER TABLE [dbo].zpv_parms ADD inv_to_ship_acct_unit4 dbo.UnitCode4Type NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'purch_disc_acct')
ALTER TABLE [dbo].zpv_parms ADD purch_disc_acct dbo.AcctType NULL --15

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'purch_disc_acct_unit1')
ALTER TABLE [dbo].zpv_parms ADD purch_disc_acct_unit1 dbo.UnitCode1Type NULL --16

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'purch_disc_acct_unit2')
ALTER TABLE [dbo].zpv_parms ADD purch_disc_acct_unit2 dbo.UnitCode2Type NULL --17

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'purch_disc_acct_unit3')
ALTER TABLE [dbo].zpv_parms ADD purch_disc_acct_unit3 dbo.UnitCode3Type NULL --18

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'purch_disc_acct_unit4')
ALTER TABLE [dbo].zpv_parms ADD purch_disc_acct_unit4 dbo.UnitCode4Type NULL --19

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'rcpt_disc_acct')
ALTER TABLE [dbo].zpv_parms ADD rcpt_disc_acct dbo.AcctType NULL --20

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'rcpt_disc_acct_unit1')
ALTER TABLE [dbo].zpv_parms ADD rcpt_disc_acct_unit1 dbo.UnitCode1Type NULL --21

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'rcpt_disc_acct_unit2')
ALTER TABLE [dbo].zpv_parms ADD rcpt_disc_acct_unit2 dbo.UnitCode2Type NULL --22

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'rcpt_disc_acct_unit3')
ALTER TABLE [dbo].zpv_parms ADD rcpt_disc_acct_unit3 dbo.UnitCode3Type NULL --23

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'rcpt_disc_acct_unit4')
ALTER TABLE [dbo].zpv_parms ADD rcpt_disc_acct_unit4 dbo.UnitCode4Type NULL --24

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cost_variation_acct')
ALTER TABLE [dbo].zpv_parms ADD cost_variation_acct dbo.AcctType NULL --25

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cost_variation_acct_unit1')
ALTER TABLE [dbo].zpv_parms ADD cost_variation_acct_unit1 dbo.UnitCode1Type NULL --26

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cost_variation_acct_unit2')
ALTER TABLE [dbo].zpv_parms ADD cost_variation_acct_unit2 dbo.UnitCode2Type NULL --27

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cost_variation_acct_unit3')
ALTER TABLE [dbo].zpv_parms ADD cost_variation_acct_unit3 dbo.UnitCode3Type NULL --28

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cost_variation_acct_unit4')
ALTER TABLE [dbo].zpv_parms ADD cost_variation_acct_unit4 dbo.UnitCode4Type NULL --29

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'lasttran_id')
ALTER TABLE [dbo].zpv_parms ADD lasttran_id varchar(10) NULL --30

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'freight_amt')
ALTER TABLE [dbo].zpv_parms ADD freight_amt dbo.AmountType NULL --31

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'sum_credit_memo')
ALTER TABLE [dbo].zpv_parms ADD sum_credit_memo dbo.FlagNyType NULL --32

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'generic_cust_type')
ALTER TABLE [dbo].zpv_parms ADD generic_cust_type dbo.CustTypeType NULL --33

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cgs_acct')
ALTER TABLE [dbo].zpv_parms ADD cgs_acct dbo.AcctType NULL --34

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cgs_acct_unit1')
ALTER TABLE [dbo].zpv_parms ADD cgs_acct_unit1 dbo.UnitCode1Type NULL --35

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cgs_acct_unit2')
ALTER TABLE [dbo].zpv_parms ADD cgs_acct_unit2 dbo.UnitCode2Type NULL --36

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cgs_acct_unit3')
ALTER TABLE [dbo].zpv_parms ADD cgs_acct_unit3 dbo.UnitCode3Type NULL --37

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'cgs_acct_unit4')
ALTER TABLE [dbo].zpv_parms ADD cgs_acct_unit4 dbo.UnitCode4Type NULL --38

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ctrl_fiscal')
ALTER TABLE [dbo].zpv_parms ADD ctrl_fiscal dbo.FlagNyType NULL --39

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'on_account_type')
ALTER TABLE [dbo].zpv_parms ADD on_account_type dbo.POSMPayTypeType NULL --40

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'check_tax')
ALTER TABLE [dbo].zpv_parms ADD check_tax decimal(10,6) NULL --41

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'iibb_tax')
ALTER TABLE [dbo].zpv_parms ADD iibb_tax decimal(10,6) NULL --42

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'com_tax')
ALTER TABLE [dbo].zpv_parms ADD com_tax decimal(10,6) NULL --43

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'opcost_tax')
ALTER TABLE [dbo].zpv_parms ADD opcost_tax decimal(10,6) NULL --44

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'prq_prefix')
ALTER TABLE [dbo].zpv_parms ADD prq_prefix dbo.PreqPrefixType NULL --45

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ret_code_customer_hold')
ALTER TABLE [dbo].zpv_parms ADD ret_code_customer_hold varchar(5) NULL --46

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ret_code_terms')
ALTER TABLE [dbo].zpv_parms ADD ret_code_terms varchar(5) NULL --47

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ret_code_credit_limit')
ALTER TABLE [dbo].zpv_parms ADD ret_code_credit_limit varchar(5) NULL --48

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ret_code_balance_due')
ALTER TABLE [dbo].zpv_parms ADD ret_code_balance_due varchar(5) NULL --49

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ret_code_freight')
ALTER TABLE [dbo].zpv_parms ADD ret_code_freight varchar(5) NULL --50

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'credit_hold_reason')
ALTER TABLE [dbo].zpv_parms ADD credit_hold_reason ReasonCodeType NULL --51

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ret_code_wait_check')
ALTER TABLE [dbo].zpv_parms ADD ret_code_wait_check varchar(5) NULL --52

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'time_res_temp')
ALTER TABLE [dbo].zpv_parms ADD time_res_temp numeric(3) NULL --53

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'time_reserve')
ALTER TABLE [dbo].zpv_parms ADD time_reserve numeric(3) NULL --54

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'ship_code')
ALTER TABLE [dbo].zpv_parms ADD ship_code dbo.ShipCodeType NULL --55

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'prepaid_ar_type_id_inv')
ALTER TABLE [dbo].zpv_parms ADD prepaid_ar_type_id_inv dbo.ZlaArTypeIdType NULL --56

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'prepaid_ar_type_id_nc')
ALTER TABLE [dbo].zpv_parms ADD prepaid_ar_type_id_nc dbo.ZlaArTypeIdType NULL --57

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'prepaid_fix_price')
ALTER TABLE [dbo].zpv_parms ADD prepaid_fix_price numeric(5,2) NULL DEFAULT ((0)) --58

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'big_retail_cust_type')
ALTER TABLE [dbo].zpv_parms ADD big_retail_cust_type dbo.CustTypeType NULL  --59

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_parms' AND COLUMN_NAME = 'data_import_path')
ALTER TABLE [dbo].zpv_parms ADD data_import_path varchar(255) NULL  --60


-- zpv_pos_enduser --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_pos_enduser' AND COLUMN_NAME = 'pos_code')
ALTER TABLE [dbo].zpv_pos_enduser ADD lasttran_id varchar(15) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_pos_enduser' AND COLUMN_NAME = 'end_user_type')
ALTER TABLE [dbo].zpv_pos_enduser ADD lasttran_id dbo.EndUserTypeType NULL --9

-- zpv_rg1817 --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'cuit')
ALTER TABLE [dbo].[zpv_rg1817] ADD cuit varchar(11) NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'denominacion')
ALTER TABLE [dbo].[zpv_rg1817] ADD denominacion varchar(30) NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'imp_ganancias')
ALTER TABLE [dbo].[zpv_rg1817] ADD imp_ganancias varchar(2) NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'imp_iva')
ALTER TABLE [dbo].[zpv_rg1817] ADD imp_iva varchar(2) NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'monotributo')
ALTER TABLE [dbo].[zpv_rg1817] ADD monotributo varchar(2) NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'int_soc')
ALTER TABLE [dbo].[zpv_rg1817] ADD int_soc varchar(1) NULL --13

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'empleador')
ALTER TABLE [dbo].[zpv_rg1817] ADD empleador varchar(1) NULL --14

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_rg1817' AND COLUMN_NAME = 'mono_act')
ALTER TABLE [dbo].[zpv_rg1817] ADD mono_act varchar(2) NULL --15

-- zpv_terms_ptype --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_terms_ptype' AND COLUMN_NAME = 'terms_code')
ALTER TABLE [dbo].zpv_terms_ptype ADD terms_code dbo.TermsCodeType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_terms_ptype' AND COLUMN_NAME = 'posm_pay_type')
ALTER TABLE [dbo].zpv_terms_ptype ADD posm_pay_type dbo.POSMPayTypeType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_terms_ptype' AND COLUMN_NAME = 'cust_type')
ALTER TABLE [dbo].zpv_terms_ptype ADD cust_type dbo.CustTypeType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_terms_ptype' AND COLUMN_NAME = 'disc_co')
ALTER TABLE [dbo].zpv_terms_ptype ADD disc_co dbo.ListYesNoType NULL DEFAULT((0)) --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_terms_ptype' AND COLUMN_NAME = 'disc_promo')
ALTER TABLE [dbo].zpv_terms_ptype ADD disc_promo dbo.ListYesNoType NULL DEFAULT((0)) --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_terms_ptype' AND COLUMN_NAME = 'disc_lines')
ALTER TABLE [dbo].zpv_terms_ptype ADD disc_lines dbo.ListYesNoType NULL DEFAULT((0)) --13

-- zpv_tt_arpmtd
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_tt_arpmtd' AND COLUMN_NAME = 'cust_num')
ALTER TABLE [dbo].zpv_tt_arpmtd ADD cust_num dbo.CustNumType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_tt_arpmtd' AND COLUMN_NAME = 'inv_num')
ALTER TABLE [dbo].zpv_tt_arpmtd ADD inv_num dbo.InvNumType NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_tt_arpmtd' AND COLUMN_NAME = 'dom_amt_applied')
ALTER TABLE [dbo].zpv_tt_arpmtd ADD dom_amt_applied dbo.AmountType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_tt_arpmtd' AND COLUMN_NAME = 'co_num')
ALTER TABLE [dbo].zpv_tt_arpmtd ADD co_num dbo.CoNumType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_tt_arpmtd' AND COLUMN_NAME = 'for_amt_applied')
ALTER TABLE [dbo].zpv_tt_arpmtd ADD for_amt_applied dbo.AmountType NULL --12

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_tt_arpmtd' AND COLUMN_NAME = 'exch_rate')
ALTER TABLE [dbo].zpv_tt_arpmtd ADD exch_rate dbo.ExchRateType NULL --13


-- zpv_user_pos --
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_user_pos' AND COLUMN_NAME = 'Username')
ALTER TABLE [dbo].zpv_user_pos ADD Username dbo.UsernameType NULL --8

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_user_pos' AND COLUMN_NAME = 'pos_code')
ALTER TABLE [dbo].zpv_user_pos ADD pos_code varchar(15) NULL --9

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_user_pos' AND COLUMN_NAME = 'EndUserType')
ALTER TABLE [dbo].zpv_user_pos ADD EndUserType dbo.EndUserTypeType NULL --10

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_user_pos' AND COLUMN_NAME = 'pos_default')
ALTER TABLE [dbo].zpv_user_pos ADD pos_default dbo.ListYesNoType NULL --11

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_user_pos' AND COLUMN_NAME = 'user_master')
ALTER TABLE [dbo].zpv_user_pos ADD user_master dbo.ListYesNoType NULL --12

------------------------------------------------------------------------------------------------------------------------------------------
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer' AND COLUMN_NAME = 'check_in' AND COLUMN_DEFAULT IS NOT NULL)
ALTER TABLE [dbo].[zpv_drawer] ADD  CONSTRAINT [DF_zpv_drawer_check_in]  DEFAULT ((0)) FOR [check_in]

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'relief_num' AND COLUMN_DEFAULT IS NOT NULL)
ALTER TABLE [dbo].[zpv_drawer_trans] ADD  CONSTRAINT [DF_zpv_drawer_trans_relief_num]  DEFAULT ((0)) FOR [relief_num]

IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'zpv_drawer_trans' AND COLUMN_NAME = 'from_relief_num' AND COLUMN_DEFAULT IS NOT NULL)
ALTER TABLE [dbo].[zpv_drawer_trans] ADD  CONSTRAINT [DF_zpv_drawer_trans_from_relief_num]  DEFAULT ((0)) FOR [from_relief_num]

------------------------------------------------------------------------------------------------------------------------------------------

/* Alteraciones de campos existentes **/
ALTER TABLE dbo.zpv_co_pos ALTER COLUMN prefix varchar(10)


