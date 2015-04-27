/****** Object:  StoredProcedure [dbo].[ZPV_CheckCORetentionsSp]    Script Date: 16/01/2015 03:14:32 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CheckCORetentionsSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CheckCORetentionsSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CheckCORetentionsSp]    Script Date: 16/01/2015 03:14:32 p.m. ******/
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
CREATE PROCEDURE [dbo].[ZPV_CheckCORetentionsSp] (
	@CoNum			CoNumType ,
	@RetCode		varchar(5) ,
	@Active			ListYesNoType,
	@Infobar         InfobarType     OUTPUT
) AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare 
	@CustNum	CustNumType
,	@ZpvStatInternal varchar(5)
,	@TotalPayment	AmountType
,	@TotalInvoiced	AmountType
,	@GenCustType	CustTypeType
,	@CusCustType	CustTypeType
,	@ExistsRetCredit	ListYesNoType
,	@RetDefault		varchar(5)

declare
	@RetCodeCustomerHold	varchar(5)
,	@RetCodeCreditLimit		varchar(5)
,	@RetCodeTerms			varchar(5)
,	@RetCodeBalanceDue		varchar(5)
,	@RetCodeFreight			varchar(5)
,	@RetCodeWaitCheck		varchar(5)

select 
	@ZpvStatInternal	= co.zpv_stat_internal
,	@CustNum			= co.cust_num
,	@RetDefault			= isnull(cod.ret_code,'')
,	@CusCustType		= cus.cust_type
from co_mst co
inner join customer_mst cus 
	on  cus.cust_num = co.cust_num
	and	cus.cust_seq = 0
inner join zpv_co_codes cod 
	on	cod.end_user_type	= co.end_user_type
	and	cod.cust_type		= cus.cust_type
where co.co_num = @CoNum

select
	@RetCodeBalanceDue	= par.ret_code_balance_due
,	@RetCodeCreditLimit	= par.ret_code_credit_limit
,	@RetCodeCustomerHold	= par.ret_code_customer_hold
,	@RetCodeTerms		= par.ret_code_terms
,	@RetCodeFreight		= par.ret_code_freight
,	@GenCustType		= par.generic_cust_type
,	@RetCodeWaitCheck	= par.ret_code_wait_check
from zpv_parms par
where par.parms_key = 0

select
	@TotalPayment = isnull(sum(a.amount),0)
from zpv_co_payments a 
where a.co_num = @CoNum
		
select
	@TotalInvoiced = (isnull(b.price,0) + isnull(b.sales_tax,0) + isnull(b.sales_tax_2,0) + isnull(b.freight,0) + isnull(b.misc_charges,0))
from co_mst b 
where b.co_num = @CoNum

if exists(select 1 from zpv_co_retentions ret 
	where	ret.active = 1
		and ret.co_num  = @CoNum 
		and	ret.ret_code <> @RetDefault
		and	(ret.ret_code = @RetCodeBalanceDue or
			ret.ret_code = @RetCodeCreditLimit or
			ret.ret_code = @RetCodeCustomerHold or
			ret.ret_code = @RetCodeTerms))
set @ExistsRetCredit = 1
else
set @ExistsRetCredit = 0

-- Retencion por flete
if @RetCode = @RetCodeFreight and @Active = 0
begin
	if @ZpvStatInternal = 'M02' and @TotalInvoiced = @TotalPayment
	begin
		update co 
			set co.zpv_stat_internal = 
				case 
					when @CusCustType = @GenCustType  and @ExistsRetCredit = 1 then 'O92'
					when @CusCustType = @GenCustType  and @ExistsRetCredit = 0 then 'M03'
					when @CusCustType <> @GenCustType and @ExistsRetCredit = 1 then 'O04'
					when @CusCustType <> @GenCustType and @ExistsRetCredit = 0 then 'M03'
				end
		where co.co_num = @CoNum
	end
	if @ZpvStatInternal = 'M02' and @TotalInvoiced <> @TotalPayment
	begin
		select 'Flete'
		update co 
			set co.zpv_stat_internal = 
				case 
					when @CusCustType = @GenCustType  and @ExistsRetCredit = 1 then 'O92'
					when @CusCustType = @GenCustType  and @ExistsRetCredit = 0 then 'M07'
					when @CusCustType <> @GenCustType and @ExistsRetCredit = 1 then 'O04'
					when @CusCustType <> @GenCustType and @ExistsRetCredit = 0 then 'M07'
				end
		where co.co_num = @CoNum
	end
end

-- Retencion por flete
if @RetCode = @RetCodeFreight and @Active = 1
begin
	if @ZpvStatInternal = 'O92' 
	or @ZpvStatInternal = 'M03' 
	or @ZpvStatInternal = 'O04'
	begin
		update co 
			set co.zpv_stat_internal = 'M02'
		where co.co_num = @CoNum
	end
end

-- Quita Retencion por credito
if @Active = 0 and 
	(	@RetCode = @RetCodeCreditLimit
	or	@RetCode = @RetCodeBalanceDue
	or	@RetCode = @RetCodeCustomerHold
	or  @RetCode = @RetCodeTerms
	or	@RetCode = @RetCodeWaitCheck)
begin
	if (@ZpvStatInternal = 'O04' or @ZpvStatInternal = 'O92') and @TotalInvoiced = @TotalPayment and @ExistsRetCredit = 0
	begin
		update co 
			set co.zpv_stat_internal = 'M03'
		where co.co_num = @CoNum

		update co_mst	
			set stat = 'O',
				ship_hold = 0,
				credit_hold = 0
		where co_num = @CoNum
		
		update co_bln
			set co_bln.stat = 'O'
		where co_bln.co_num = @CoNum

		if @GenCustType <> @CusCustType
		begin
			update coitem 
				set coitem.stat = 'O'
			where coitem.co_num = @CoNum
		end

		if @GenCustType = @CusCustType
		begin
			update coitem 
				set coitem.stat = 'P'
			where coitem.co_num = @CoNum
		end

	end
	if (@ZpvStatInternal = 'O04' or @ZpvStatInternal = 'O92') and @TotalInvoiced <> @TotalPayment and @ExistsRetCredit = 0
	begin
		update co 
			set co.zpv_stat_internal = 'M07'
		where co.co_num = @CoNum

		update coitem 
			set coitem.stat = 'P'
		where coitem.co_num = @CoNum

		update co_bln
			set co_bln.stat = 'P'
		where co_bln.co_num = @CoNum

		update co_mst	
			set stat = 'P',
				ship_hold = 1,
				credit_hold = 1
		where co_num = @CoNum
	end
end

-- Retencion por credito
if @Active = 1 and 
	(	@RetCode = @RetCodeCreditLimit
	or	@RetCode = @RetCodeBalanceDue
	or	@RetCode = @RetCodeCustomerHold
	or  @RetCode = @RetCodeTerms
	or	@RetCode = @RetCodeWaitCheck)
begin
	if (@ZpvStatInternal = 'M03' or @ZpvStatInternal = 'M07')
	begin
		update co 
			set co.zpv_stat_internal = 'O04'
		where co.co_num = @CoNum

		update coitem 
			set coitem.stat = 'P'
		where coitem.co_num = @CoNum

		update co_bln
			set co_bln.stat = 'P'
		where co_bln.co_num = @CoNum

		update co_mst	
			set stat = 'P',
				ship_hold = 1,
				credit_hold = 1
		where co_num = @CoNum
	end
end




GO

