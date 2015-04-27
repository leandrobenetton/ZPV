/****** Object:  Trigger [co_bln_mstIup]    Script Date: 28/12/2014 05:35:57 p.m. ******/
IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'co_bln_mstIup' AND xtype = 'TR')
DROP TRIGGER [dbo].[co_bln_mstIup]
GO

/****** Object:  Trigger [dbo].[co_bln_mstIup]    Script Date: 28/12/2014 05:35:57 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[co_bln_mstIup]
ON [dbo].[co_bln_mst]
FOR INSERT, UPDATE
AS
   IF @@ROWCOUNT = 0 RETURN
   
   IF TRIGGER_NESTLEVEL(OBJECT_ID(N'dbo.co_bln_mstUpdatePenultimate')) > 0
      RETURN
   SET NOCOUNT ON

   IF dbo.SkipBaseTrigger() = 1
      RETURN
   
   DECLARE @Site SiteType
	, @InsertFlag tinyint
	, @MrpParmReqSrc MrpReqSrcType

	SELECT @Site = prm.site
	FROM parms AS prm with (readuncommitted)
	WHERE prm.parm_key = 0

	SELECT
	@InsertFlag = CASE
    WHEN EXISTS ( SELECT 1 FROM deleted ) THEN 0
      ELSE 1
    END

   DECLARE @Today DateType
   SET @Today = dbo.GetSiteDate(GETDATE())

   DECLARE @UserName LongListType
   SET @UserName = dbo.UserNameSp()

   DECLARE @UpdateRecordDate bit
   SET @UpdateRecordDate = CASE WHEN dbo.VariableIsDefined(N'SkipRecordDate') = 0 THEN 1 ELSE 0 END

   
   DECLARE 
		@CoNum CoNumType,
		@CoLine CoLineType,
		@CoShipToDef CustSeqType,
		@CoType	varchar(1)

	DECLARE
		@CoitemItem				ItemType,
		@CoitemDisc				decimal(8,3),
		@CoitemCost				AmountType,
		@CoitemCostConv			AmountType,
		@CoitemPrice			AmountType,
		@CoitemPriceConv		AmountType,
		@CoitemDueDate			DateType,
		@CoitemCustNum			CustNumType,
		@CoitemCustSeq			int,
		@CoitemWhse				WhseType,
		@CoitemUm				UMType,
		@CoitemShipSite			SiteType,
		@CoitemDescription		DescriptionType,
		@CoitemZlaForPrice		AmountType,
		@CoitemZlaForPriceConv	AmountType,
		@CoitemZrtShipWhse		WhseType,
		@CoitemZrtLot			LotType,
		@CoitemZwmShipCode		ShipCodeType,
		@CoitemTaxCode1			TaxCodeType,
		@CoitemTaxCode2			TaxCodeType
		
   SELECT 
		@CoNum = ii.co_num,
		@CoLine = ii.co_line
	FROM inserted ii


	SELECT TOP(1)
		@CoShipToDef = cus.cust_seq 
	FROM customer cus, custaddr cad, co
	WHERE
		co.co_num	 = @CoNum and 
		cus.cust_num = co.cust_num and 
		cus.tax_reg_num1 = co.zpv_bill_cuit and
		cad.cust_num = cus.cust_num and
		cad.cust_seq = cus.cust_seq
	ORDER BY cus.cust_num, cus.tax_reg_num1, cad.zpv_transport DESC	
	
	SELECT @CoType = co.type from co where co.co_num = @CoNum

	if @InsertFlag = 1 and @CoType = 'B'
	begin
		insert into coitem
		   ([co_num]			--1
		   ,[co_line]			--2
		   ,[co_release]		--3
		   ,[item]				--4
		   ,[qty_ordered]		--5
		   ,[qty_ready]			--6
		   ,[qty_shipped]		--7
		   ,[qty_packed]		--8
		   ,[disc]				--9
		   ,[cost]				--10
		   ,[price]				--11
		   ,[ref_type]			--12
		   ,[ref_num]			--13
		   ,[ref_line_suf]		--14
		   ,[ref_release]		--15
		   ,[due_date]			--16
		   ,[ship_date]			--17
		   ,[reprice]			--23
		   ,[cust_item]			--24
		   ,[qty_invoiced]		--25
		   ,[qty_returned]		--26
		   ,[cgs_total]			--27
		   ,[feat_str]			--28
		   ,[stat]				--29
		   ,[cust_num]			--30
		   ,[cust_seq]			--31
		   ,[prg_bill_tot]		--32
		   ,[prg_bill_app]		--33
		   ,[release_date]		--34
		   ,[promise_date]		--35
		   ,[whse]				--36
		   ,[wks_basis]			--37
		   ,[wks_value]			--38
		   ,[comm_code]			--39
		   ,[trans_nat]			--40
		   ,[process_ind]		--41
		   ,[delterm]			--42
		   ,[unit_weight]		--43
		   ,[origin]			--44
		   ,[cons_num]			--45
		   ,[tax_code1]			--46
		   ,[tax_code2]			--47
		   ,[export_value]		--48
		   ,[ec_code]			--49
		   ,[transport]			--50
		   ,[pick_date]			--51
		   ,[pricecode]			--52
		   ,[u_m]				--53
		   ,[qty_ordered_conv]	--54
		   ,[price_conv]		--55
		   ,[co_cust_num]		--56
		   ,[packed]			--57
		   ,[bol]				--58
		   ,[qty_rsvd]			--59
		   ,[matl_cost]			--60
		   ,[lbr_cost]			--61
		   ,[fovhd_cost]		--62
		   ,[vovhd_cost]		--63
		   ,[out_cost]			--64
		   ,[cgs_total_matl]	--65
		   ,[cgs_total_lbr]		--66
		   ,[cgs_total_fovhd]	--67
		   ,[cgs_total_vovhd]	--68
		   ,[cgs_total_out]		--69
		   ,[cost_conv]			--70
		   ,[matl_cost_conv]	--71
		   ,[lbr_cost_conv]		--72
		   ,[fovhd_cost_conv]	--73
		   ,[vovhd_cost_conv]	--74
		   ,[out_cost_conv]		--75
		   ,[ship_site]			--76
		   ,[sync_reqd]			--77
		   ,[co_orig_site]		--78
		   ,[cust_po]			--79
		   ,[rma_num]			--80
		   ,[rma_line]			--81
		   ,[projected_date]	--82
		   ,[consolidate]		--83
		   ,[inv_freq]			--84
		   ,[summarize]			--85
		   ,[description]		--86
		   ,[config_id]			--87
		   ,[trans_nat_2]		--88
		   ,[suppl_qty_conv_factor]	--89
		   ,[print_kit_components]	--90
		   ,[external_reservation_ref]	--91
		   ,[non_inv_acct]		--92
		   ,[non_inv_acct_unit1]	--93
		   ,[non_inv_acct_unit2]	--94
		   ,[non_inv_acct_unit3]	--95
		   ,[non_inv_acct_unit4]	--96
		   ,[days_shipped_before_due_date_tolerance]	--97
		   ,[days_shipped_after_due_date_tolerance]		--98
		   ,[shipped_over_ordered_qty_tolerance]		--99
		   ,[shipped_under_ordered_qty_tolerance]		--100
		   ,[priority]			--101
		   ,[invoice_hold]		--102
		   ,[manufacturer_id]	--103
		   ,[manufacturer_item]	--104
		   ,[qty_picked]		--105
		   ,[fs_inc_num]		--106
		   ,[promotion_code]	--107
		   ,[zla_for_price]		--108
		   ,[zla_for_price_conv]	--109
		   ,[zpv_ship_whse]			--110
		   ,[zpv_lot]				--111
		   ,[zwm_ship_code]	)		--112
		select
		   ii.co_num,			--1
		   ii.co_line,			--2
		   1,					--3
		   ii.item,				--4
		   ii.blanket_qty_conv,		--5
		   0,					--6
		   0,					--7
		   0,					--8
		   isnull(ii.zpv_co_disc,0) + isnull(ii.zpv_promotion_disc,0),	--9
		   ii.cost_conv,		--10
		   ii.cont_price_conv,	--11
		   'I',					--12
		   null,				--13
		   0,					--14
		   0,					--15
		   ii.promise_date,		--16
		   null,				--17
		    1,					--23
		   ii.cust_item,		--24
		   0,					--25
		   0,					--26
		   0,					--27
		   ii.feat_str,			--28
		   'P',				--29
		   co.cust_num,			--30
		   co.cust_seq,			--31
		   0,					--32
		   0,					--33
		   null,				--34
		   ii.promise_date,		--35
		   ii.zpv_res_whse,		--36
		   null,				--37
		   0,					--38
		   null,				--39
		   null,				--40
		   null,				--41
		   null,				--42
		   0,					--43
		   null,				--44
		   0,					--45
		   ii.zpv_tax_code1,		--46
		   ii.zpv_tax_code2,		--47
		   0,					--48
		   null,				--49
		   null,				--50
		   null,				--51
		   null,				--52
		   ii.u_m,				--53
		   ii.blanket_qty_conv,	--54
		   ii.cont_price_conv,	--55
		   co.cust_num,			--56
		   0,					--57
		   0,					--58
		   0,					--59
		   ii.cost_conv,		--60
		   0,					--61
		   0,					--62
		   0,					--63
		   0,					--64
		   0,					--65
		   0,					--66
		   0,					--67
		   0,					--68
		   0,					--69
		   0,					--70
		   0,					--71
		   0,					--72
		   0,					--73
		   0,					--74
		   0,					--75
		   ii.ship_site,		--76
		   0,					--77
		   ii.ship_site,		--78
		   null,				--79
		   null,				--80
		   0,					--81
		   null,				--82
		   0,					--83
		   'W',					--84
		   0,					--85
		   ii.description,		--86
		   null,				--87
		   null,				--88
		   1,					--89
		   0,					--90
		   null,				--91
		   null,				--92
		   null,				--93
		   null,				--94
		   null,				--95
		   null,				--96
		   ii.days_shipped_before_due_date_tolerance,	--97
		   ii.days_shipped_after_due_date_tolerance,	--98
		   ii.shipped_over_ordered_qty_tolerance,		--99
		   ii.shipped_under_ordered_qty_tolerance,		--100
		   null,				--101
		   0,					--102
		   null,				--103
		   null,				--104
		   0,					--105
		   null,				--106
		   null,				--107
		   ii.cont_price,		--108
		   ii.cont_price_conv,	--109
		   ii.zpv_ship_whse,	--110
		   ii.zpv_lot,			--111
		   ii.zpv_shiptype		--112
		FROM inserted ii
		LEFT OUTER JOIN co ON co.co_num = ii.co_num
		LEFT OUTER JOIN item AS it WITH (READUNCOMMITTED) ON it.item = ii.item 		
	end
	
	if UPDATE(blanket_qty_conv) and @InsertFlag = 0 and @CoType = 'B'
	begin
		UPDATE co_bln SET blanket_qty = blanket_qty_conv WHERE co_num = @CoNum AND co_line = @CoLine
		
		delete from coitem where coitem.co_num = @CoNum and coitem.co_line = @CoLine
		insert into coitem
		   ([co_num]			--1
		   ,[co_line]			--2
		   ,[co_release]		--3
		   ,[item]				--4
		   ,[qty_ordered]		--5
		   ,[qty_ready]			--6
		   ,[qty_shipped]		--7
		   ,[qty_packed]		--8
		   ,[disc]				--9
		   ,[cost]				--10
		   ,[price]				--11
		   ,[ref_type]			--12
		   ,[ref_num]			--13
		   ,[ref_line_suf]		--14
		   ,[ref_release]		--15
		   ,[due_date]			--16
		   ,[ship_date]			--17
		   ,[reprice]			--23
		   ,[cust_item]			--24
		   ,[qty_invoiced]		--25
		   ,[qty_returned]		--26
		   ,[cgs_total]			--27
		   ,[feat_str]			--28
		   ,[stat]				--29
		   ,[cust_num]			--30
		   ,[cust_seq]			--31
		   ,[prg_bill_tot]		--32
		   ,[prg_bill_app]		--33
		   ,[release_date]		--34
		   ,[promise_date]		--35
		   ,[whse]				--36
		   ,[wks_basis]			--37
		   ,[wks_value]			--38
		   ,[comm_code]			--39
		   ,[trans_nat]			--40
		   ,[process_ind]		--41
		   ,[delterm]			--42
		   ,[unit_weight]		--43
		   ,[origin]			--44
		   ,[cons_num]			--45
		   ,[tax_code1]			--46
		   ,[tax_code2]			--47
		   ,[export_value]		--48
		   ,[ec_code]			--49
		   ,[transport]			--50
		   ,[pick_date]			--51
		   ,[pricecode]			--52
		   ,[u_m]				--53
		   ,[qty_ordered_conv]	--54
		   ,[price_conv]		--55
		   ,[co_cust_num]		--56
		   ,[packed]			--57
		   ,[bol]				--58
		   ,[qty_rsvd]			--59
		   ,[matl_cost]			--60
		   ,[lbr_cost]			--61
		   ,[fovhd_cost]		--62
		   ,[vovhd_cost]		--63
		   ,[out_cost]			--64
		   ,[cgs_total_matl]	--65
		   ,[cgs_total_lbr]		--66
		   ,[cgs_total_fovhd]	--67
		   ,[cgs_total_vovhd]	--68
		   ,[cgs_total_out]		--69
		   ,[cost_conv]			--70
		   ,[matl_cost_conv]	--71
		   ,[lbr_cost_conv]		--72
		   ,[fovhd_cost_conv]	--73
		   ,[vovhd_cost_conv]	--74
		   ,[out_cost_conv]		--75
		   ,[ship_site]			--76
		   ,[sync_reqd]			--77
		   ,[co_orig_site]		--78
		   ,[cust_po]			--79
		   ,[rma_num]			--80
		   ,[rma_line]			--81
		   ,[projected_date]	--82
		   ,[consolidate]		--83
		   ,[inv_freq]			--84
		   ,[summarize]			--85
		   ,[description]		--86
		   ,[config_id]			--87
		   ,[trans_nat_2]		--88
		   ,[suppl_qty_conv_factor]	--89
		   ,[print_kit_components]	--90
		   ,[external_reservation_ref]	--91
		   ,[non_inv_acct]		--92
		   ,[non_inv_acct_unit1]	--93
		   ,[non_inv_acct_unit2]	--94
		   ,[non_inv_acct_unit3]	--95
		   ,[non_inv_acct_unit4]	--96
		   ,[days_shipped_before_due_date_tolerance]	--97
		   ,[days_shipped_after_due_date_tolerance]		--98
		   ,[shipped_over_ordered_qty_tolerance]		--99
		   ,[shipped_under_ordered_qty_tolerance]		--100
		   ,[priority]			--101
		   ,[invoice_hold]		--102
		   ,[manufacturer_id]	--103
		   ,[manufacturer_item]	--104
		   ,[qty_picked]		--105
		   ,[fs_inc_num]		--106
		   ,[promotion_code]	--107
		   ,[zla_for_price]		--108
		   ,[zla_for_price_conv]	--109
		   ,[zpv_ship_whse]			--110
		   ,[zpv_lot]				--111
		   ,[zwm_ship_code]	)		--112
		select
		   ii.co_num,			--1
		   ii.co_line,			--2
		   1,					--3
		   ii.item,				--4
		   ii.blanket_qty_conv,		--5
		   0,					--6
		   0,					--7
		   0,					--8
		   isnull(ii.zpv_co_disc,0) + isnull(ii.zpv_promotion_disc,0),	--9
		   ii.cost_conv,		--10
		   ii.cont_price_conv,	--11
		   'I',					--12
		   null,				--13
		   0,					--14
		   0,					--15
		   ii.promise_date,		--16
		   null,				--17
		   1,					--23
		   ii.cust_item,		--24
		   0,					--25
		   0,					--26
		   0,					--27
		   ii.feat_str,			--28
		   'P',				--29
		   co.cust_num,			--30
		   co.cust_seq,			--31
		   0,					--32
		   0,					--33
		   null,				--34
		   ii.promise_date,		--35
		   ii.zpv_res_whse,		--36
		   null,				--37
		   0,					--38
		   null,				--39
		   null,				--40
		   null,				--41
		   null,				--42
		   0,					--43
		   null,				--44
		   0,					--45
		   ii.zpv_tax_code1,		--46
		   ii.zpv_tax_code2,		--47
		   0,					--48
		   null,				--49
		   null,				--50
		   null,				--51
		   null,				--52
		   ii.u_m,				--53
		   ii.blanket_qty_conv,	--54
		   ii.cont_price_conv,	--55
		   co.cust_num,			--56
		   0,					--57
		   0,					--58
		   0,					--59
		   ii.cost_conv,		--60
		   0,					--61
		   0,					--62
		   0,					--63
		   0,					--64
		   0,					--65
		   0,					--66
		   0,					--67
		   0,					--68
		   0,					--69
		   0,					--70
		   0,					--71
		   0,					--72
		   0,					--73
		   0,					--74
		   0,					--75
		   ii.ship_site,		--76
		   0,					--77
		   ii.ship_site,		--78
		   null,				--79
		   null,				--80
		   0,					--81
		   null,				--82
		   0,					--83
		   'W',					--84
		   0,					--85
		   ii.description,		--86
		   null,				--87
		   null,				--88
		   1,					--89
		   0,					--90
		   null,				--91
		   null,				--92
		   null,				--93
		   null,				--94
		   null,				--95
		   null,				--96
		   ii.days_shipped_before_due_date_tolerance,	--97
		   ii.days_shipped_after_due_date_tolerance,	--98
		   ii.shipped_over_ordered_qty_tolerance,		--99
		   ii.shipped_under_ordered_qty_tolerance,		--100
		   null,				--101
		   0,					--102
		   null,				--103
		   null,				--104
		   0,					--105
		   null,				--106
		   null,				--107
		   ii.cont_price,		--108
		   ii.cont_price_conv,	--109
		   ii.zpv_ship_whse,	--110
		   ii.zpv_lot,			--111
		   ii.zpv_shiptype		--112
		FROM inserted ii
		LEFT OUTER JOIN co ON co.co_num = ii.co_num
		LEFT OUTER JOIN item AS it WITH (READUNCOMMITTED) ON it.item = ii.item 		
	end
	else
	begin
		if exists(select 1 from coitem where coitem.co_num = @CoNum and coitem.co_line = @CoLine)
		begin
			select
				@CoitemItem				= coitem.item,
				@CoitemDisc				= coitem.disc,
				@CoitemCost				= coitem.cost,
				@CoitemCost				= coitem.cost_conv,
				@CoitemPrice			= coitem.price,
				@CoitemPrice			= coitem.price_conv,
				@CoitemDueDate			= coitem.due_date,
				@CoitemCustNum			= coitem.cust_num,
				@CoitemCustSeq			= coitem.cust_seq,
				@CoitemWhse				= coitem.whse,
				@CoitemUm				= coitem.u_m,		
				@CoitemShipSite			= coitem.ship_site,
				@CoitemDescription		= coitem.[description],
				@CoitemZlaForPrice		= coitem.zla_for_price,
				@CoitemZlaForPriceConv	= coitem.zla_for_price_conv,
				@CoitemZrtShipWhse		= coitem.zpv_ship_whse,
				@CoitemZrtLot			= coitem.zpv_lot,
				@CoitemZwmShipCode		= coitem.zwm_ship_code,
				@CoitemTaxCode1			= coitem.tax_code1,
				@CoitemTaxCode2			= coitem.tax_code2
			from coitem				
			where coitem.co_num = @CoNum and coitem.co_line = @CoLine
		end
		begin
			if @CoitemItem is not null and @CoitemUm is not null
			begin
				update coitem_mst
					set item		= isnull(cob.item, @CoitemItem),
						disc		= isnull(cob.zpv_co_disc,0) + isnull(cob.zpv_promotion_disc,0),
						cost		= isnull(cob.cost_conv, @CoitemCostConv),
						cost_conv	= isnull(cob.cost_conv, @CoitemCostConv),
						price		= isnull(cob.cont_price_conv, @CoitemPrice),
						due_date	= isnull(cob.promise_date, @CoitemDueDate),
						cust_num	= isnull(co.cust_num, @CoitemCustNum),
						cust_seq	= isnull(co.cust_seq, @CoitemCustSeq),
						whse		= isnull(cob.zpv_ship_whse,@CoitemWhse),
						u_m			= isnull(cob.u_m, @CoitemUM),
						price_conv	= isnull(cob.cont_price_conv,@CoitemPriceConv),
						ship_site	= isnull(cob.ship_site,@CoitemShipSite),
						[description]	= isnull(cob.[description],@CoitemDescription),
						zla_for_price	= isnull(cob.cont_price,@CoitemZlaForPrice),
						zla_for_price_conv	= isnull(cob.cont_price_conv,@CoitemZlaForPriceConv),
						zpv_ship_whse	= isnull(cob.zpv_ship_whse,@CoitemZrtShipWhse),
						zpv_lot			= isnull(cob.zpv_lot,@CoitemZrtLot),
						zwm_ship_code	= isnull(cob.zpv_shiptype,@CoitemZwmShipCode),
						tax_code1		= isnull(cob.zpv_tax_code1,@CoitemTaxCode1),
						tax_code2		= isnull(cob.zpv_tax_code2,@CoitemTaxCode2)
				from coitem_mst coi
				join co_bln_mst cob on cob.co_num = @CoNum and cob.co_line = @CoLine
				join co on co.co_num = @CoNum
				where
					coi.co_num = @CoNum and coi.co_line = @CoLine and coi.qty_shipped = 0
			end					
		end
	end

	begin --Impuestos por release
		delete from zla_coitem_tax_mst where co_num = @CoNum and co_line = @CoLine

		insert into zla_coitem_tax_mst(
			site_ref,
			co_num,
			co_line,
			co_release,
			tax_group_id)
		select
			co.site_ref,
			co.co_num,
			@CoLine,
			1,
			co.tax_group_id
		from zla_co_tax_mst co
		where
			co.co_num = @CoNum
	end
	
   RETURN


GO
EXEC sp_settriggerorder @triggername=N'[dbo].[co_bln_mstIup]', @order=N'First', @stmttype=N'UPDATE'