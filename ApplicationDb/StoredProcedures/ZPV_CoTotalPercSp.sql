/****** Object:  StoredProcedure [dbo].[ZPV_CoTotalPercSp]    Script Date: 30/12/2014 10:48:17 a.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CoTotalPercSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CoTotalPercSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CoTotalPercSp]    Script Date: 30/12/2014 10:48:17 a.m. ******/
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
CREATE PROCEDURE [dbo].[ZPV_CoTotalPercSp]  (
	@CoNum		CoNumType,
	@Amount		AmountType,
	@SalesTax1	AmountType,
	@Cuit		varchar(20),
	@OrderDate	DateType,
	@TaxAmount	AmountType	output
) AS


DECLARE
  @Severity INT

SET  @Severity = 0
SET @TaxAmount = 0

declare
	@CustState		StateType

declare
	@TaxTypeId		varchar(20),
	@StateProvId	varchar(5),
	@TaxMin			AmountType,
	@TaxCode		TaxCodeType,
	@FromAmount		AmountType,
	@ToAmount		AmountType,
	@FixAmount		AmountType,
	@Percent		TaxRateType,
	@ExceedOn		AmountType,
	@PadronId		varchar(20),
	@ApplyTo		varchar(1),
	@ApplyToAmt		varchar(2),
	@ScaleTo		varchar(1),
	@ScaleToAmt		varchar(2)

select @CustState = co.zpv_bill_state from co where co.co_num = @CoNum
if @CustState is null
begin
	select @CustState = parms.[state] from parms where parm_key = 0
end

declare TaxCur cursor for	
select
	tax.tax_type_id,
	isnull(tax.state_province_id,''),
	isnull(tax.tax_min,0),
	tax.tax_code,
	isnull(sca.from_amount,0),
	isnull(sca.to_amount,999999999999),
	isnull(sca.fix_amount,0),
	isnull(sca.[percent],0),
	isnull(sca.exceed_on,0),
	tax.padron_id,
	tat.apply_to,
	isnull(tat.apply_to_amount,0),
	tat.scale_to,
	isnull(tat.scale_amount,0)
from zla_co_tax_mst cotax
inner join zla_tax_group_mst tax on tax.group_id = cotax.tax_group_id and (tax.state_province_id = @CustState or tax.state_province_id is null)
inner join zla_tax_type_mst tat on tat.id = tax.tax_type_id
inner join zla_tax_scales_mst sca on sca.tax_type_id = tax.tax_type_id and sca.group_id = tax.group_id and @Amount between sca.from_amount and sca.to_amount
where
	cotax.co_num = @CoNum

open TaxCur
fetch next from TaxCur
into
	@TaxTypeId,
	@StateProvId,
	@TaxMin,
	@TaxCode,
	@FromAmount,
	@ToAmount,
	@FixAmount,
	@Percent,
	@ExceedOn,
	@PadronId,
	@ApplyTo,
	@ApplyToAmt,
	@ScaleTo,
	@ScaleToAmt
while @@FETCH_STATUS = 0
begin
	if @PadronId is not null --Percepción con Padron 
	begin
		select 
			@Percent = isnull(pad.perception_pct,0)
		from zla_padron_mst pad					
		where
			pad.padron = @PadronId and
			pad.tax_reg_num = @Cuit and
			@OrderDate between pad.from_date and pad.to_date
	end
	
	if @ApplyToAmt = 'I'
			select	@TaxAmount = isnull(@TaxAmount,0)	+ 
					((@SalesTax1 - isnull(@ExceedOn,0)) * (isnull(@Percent,0) / 100) + isnull(@FixAmount,0))
	if @ApplyToAmt = 'NA'
			select	@TaxAmount = isnull(@TaxAmount,0)	+ 0
	if @ApplyToAmt = 'NP'
			select	@TaxAmount = isnull(@TaxAmount,0)	+ 
					((@Amount - isnull(@ExceedOn,0)) * (isnull(@Percent,0) / 100) + isnull(@FixAmount,0))
	if @ApplyToAmt = 'NT'
			select	@TaxAmount = isnull(@TaxAmount,0)	+ 
					((@Amount - isnull(@ExceedOn,0)) * (isnull(@Percent,0) / 100) + isnull(@FixAmount,0))
	if @ApplyToAmt = 'SI'
			select	@TaxAmount = isnull(@TaxAmount,0)	+ 
					((@Amount - isnull(@ExceedOn,0)) * (isnull(@Percent,0) / 100) + isnull(@FixAmount,0))
	if @ApplyToAmt = 'T'
			select	@TaxAmount = isnull(@TaxAmount,0)	+ 
					(((@SalesTax1 + @Amount) - isnull(@ExceedOn,0)) * (isnull(@Percent,0) / 100) + isnull(@FixAmount,0))
	if @ApplyToAmt = 'TP'
			select	@TaxAmount = @TaxAmount	+ 
					(((@SalesTax1 + @Amount) - isnull(@ExceedOn,0)) * (isnull(@Percent,0) / 100) + isnull(@FixAmount,0))
	
	
	--if @TaxAmount < @TaxMin select @TaxAmount = 0
	
	fetch next from TaxCur
	into
		@TaxTypeId,
		@StateProvId,
		@TaxMin,
		@TaxCode,
		@FromAmount,
		@ToAmount,
		@FixAmount,
		@Percent,
		@ExceedOn,
		@PadronId,
		@ApplyTo,
		@ApplyToAmt,
		@ScaleTo,
		@ScaleToAmt
end
close TaxCur
deallocate TaxCur

set @TaxAmount = ROUND(@TaxAmount,2)

RETURN @Severity






GO

