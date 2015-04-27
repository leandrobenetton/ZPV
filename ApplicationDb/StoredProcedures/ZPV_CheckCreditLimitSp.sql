/****** Object:  StoredProcedure [dbo].[ZPV_CheckCreditLimitSp]    Script Date: 16/01/2015 03:14:41 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CheckCreditLimitSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CheckCreditLimitSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CheckCreditLimitSp]    Script Date: 16/01/2015 03:14:41 p.m. ******/
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
CREATE PROCEDURE [dbo].[ZPV_CheckCreditLimitSp] (
	@CoNum			CoNumType = null,
	@RetCode		varchar(10) = null,
	@Infobar         InfobarType     OUTPUT
) AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare
	@CoCustNum				CustNumType,
	@CoAmount				AmountType,
	@CoTermsCode			TermsCodeType,
	@CoZpvStatInternal		varchar(3),
	@CoCreditHold			ListYesNoType

declare
	@TotalPayment	AmountType,
	@TotalInvoiced	AmountType

declare
	@RetCodeCustomerHold	varchar(5),
	@RetCodeCreditLimit		varchar(5),
	@RetCodeTerms			varchar(5),
	@RetCodeBalanceDue		varchar(5),
	@RetCodeWaitCheck		varchar(5),
	@CreditLimitReason		ReasonCodeType
				
declare
	@CusCreditHold			int,
	@CusOrderCreditLimit	AmountType,
	@CusCreditLimit			AmountType,
	@CusOrderBal			AmountType,
	@CusPostedBal			AmountType,
	@CusDaysOverInvDueDate	DaysOverType,
	@CusTermsCode			TermsCodeType
declare
	@ArCheckNotApplied		AmountType,
	@ArMaxDueDays			DaysOverType
declare
	@RetSeq					int

select 
	@RetCodeBalanceDue		= par.ret_code_balance_due,
	@RetCodeCreditLimit		= par.ret_code_credit_limit,
	@RetCodeCustomerHold	= par.ret_code_customer_hold,
	@RetCodeTerms			= par.ret_code_terms,
	@RetCodeWaitCheck		= par.ret_code_wait_check,
	@CreditLimitReason		= par.credit_hold_reason
from zpv_parms par
where 	par.parms_key = 0
	
select
	@CoCustNum		= co.cust_num,
	@CoAmount		= (co.price + co.sales_tax + co.sales_tax_2 + co.freight + co.misc_charges),
	@CoTermsCode	= co.terms_code,
	@CoZpvStatInternal = co.zpv_stat_internal,
	@CoCreditHold	= co.credit_hold
from co
where co.co_num = @CoNum	

select
	@CusCreditHold			= cad.credit_hold,
	@CusOrderCreditLimit	= cad.order_credit_limit,
	@CusCreditLimit			= cad.credit_limit,
	@CusDaysOverInvDueDate	= cad.days_over_inv_due_date,
	@CusTermsCode			= cus.terms_code
from custaddr cad
inner join customer cus on cus.cust_num = cad.cust_num and cus.cust_seq = cad.cust_seq
where
	cad.cust_num = @CoCustNum and cad.cust_seq = 0

select
	@CusOrderBal	= cus.order_bal,
	@CusPostedBal	= cus.posted_bal
from customer_all cus
where
	cus.cust_num = @CoCustNum and cus.cust_seq = 0

select @ArCheckNotApplied = isnull(sum(ar.amount),0) from artran_mst ar
inner join glbank_mst gl on		ar.bank_code = gl.bank_code
						and ar.inv_seq = gl.cust_check_num
inner join bank_hdr_mst bh on bh.bank_code = gl.bank_code
		where	ar.type = 'P'
				and bh.zla_bank_type = 'T'
				and gl.type = 'D'
				and gl.voided = 0
				and gl.zla_deposit_applied = 0
				and ar.cust_num = @CoCustNum

select top(1) @ArMaxDueDays = isnull(cast(due_date - getdate() as int) * -1,0) from artran_mst 
where cust_num = @CoCustNum	
order by cast(due_date - getdate() as int) * -1 desc

select
	@TotalPayment = sum(a.amount)
from zpv_co_payments a 
where a.co_num = @CoNum
		
select
	@TotalInvoiced = (b.price + b.sales_tax + b.sales_tax_2 + b.freight + b.misc_charges)
from co_mst b 
where b.co_num = @CoNum

if @CoZpvStatInternal <> 'O04' or @CoCreditHold = 1 
begin
	if @RetCode = @RetCodeCustomerHold
	begin
		delete from zpv_co_retentions
			where 
				co_num = @CoNum and
				(ret_code = @RetCodeCustomerHold or ret_code = @RetCodeBalanceDue or ret_code = @RetCodeCreditLimit or ret_code = @RetCodeTerms)

		if @CusCreditHold = 1
		begin
			set @Infobar = 'Credito Retenido'
			
			select top(1) @RetSeq = ret.ret_seq + 1 from zpv_co_retentions ret where ret.co_num = @CoNum order by ret_seq desc
			if @RetSeq is null set @RetSeq = 1
		
			INSERT INTO [zpv_co_retentions]
					   ([co_num]
					   ,[ret_seq]
					   ,[ret_code]
					   ,[ret_type]
					   ,[ret_date]
					   ,[site_ref])
				 VALUES(
						@CoNum,
						@RetSeq,
						@RetCodeCustomerHold,
						'Credit',
						getdate(),
						@Site)
			update co set credit_hold = 1, credit_hold_date = GETDATE(), credit_hold_reason = @CreditLimitReason where co_num = @CoNum
		end

		if @CusOrderBal + @CusPostedBal + @CoAmount + @ArCheckNotApplied > @CusCreditLimit
		begin
			set @Infobar = 'Credito Excedido'
			
			select top(1) @RetSeq = ret.ret_seq + 1 from zpv_co_retentions ret where ret.co_num = @CoNum order by ret_seq desc
		
			if @RetSeq is null set @RetSeq = 1
			INSERT INTO [zpv_co_retentions]
					   ([co_num]
					   ,[ret_seq]
					   ,[ret_code]
					   ,[ret_type]
					   ,[ret_date]
					   ,[site_ref])
				 VALUES(
						@CoNum,
						@RetSeq,
						@RetCodeCreditLimit,
						'Credit',
						getdate(),
						@Site)
			update co set credit_hold = 1, credit_hold_date = GETDATE(), credit_hold_reason = @CreditLimitReason where co_num = @CoNum	
		end

		if @ArMaxDueDays > @CusDaysOverInvDueDate
		begin
			set @Infobar = 'Deuda Vencida'
			
			select top(1) @RetSeq = ret.ret_seq + 1 from zpv_co_retentions ret where ret.co_num = @CoNum order by ret_seq desc
			if @RetSeq is null set @RetSeq = 1
		
			INSERT INTO [zpv_co_retentions]
					   ([co_num]
					   ,[ret_seq]
					   ,[ret_code]
					   ,[ret_type]
					   ,[ret_date]
					   ,[site_ref])
				 VALUES(
						@CoNum,
						@RetSeq,
						@RetCodeBalanceDue,
						'Credit',
						getdate(),
						@Site)
			update co set credit_hold = 1, credit_hold_date = GETDATE(), credit_hold_reason = @CreditLimitReason where co_num = @CoNum				
		end

		if @CoTermsCode <> @CusTermsCode
		begin
			set @Infobar = 'Condicion Venta Diferente'
			
			select top(1) @RetSeq = ret.ret_seq + 1 from zpv_co_retentions ret where ret.co_num = @CoNum order by ret_seq desc
			select @RetSeq
			if @RetCode is null set @RetCode = 1
			INSERT INTO [zpv_co_retentions]
					   ([co_num]
					   ,[ret_seq]
					   ,[ret_code]
					   ,[ret_type]
					   ,[ret_date]
					   ,[site_ref])
				 VALUES(
						@CoNum,
						@RetSeq,
						@RetCodeTerms,
						'Credit',
						getdate(),
						@Site)
			update co set credit_hold = 1, credit_hold_date = GETDATE(), credit_hold_reason = @CreditLimitReason where co_num = @CoNum
		end

		update co_mst	
			set zpv_stat_internal = 'O04',
				ship_hold = 1
		where co_num = @CoNum
			
		update coitem 
			set coitem.stat = 'P'
		where coitem.co_num = @CoNum

		update co_bln
			set co_bln.stat = 'P'
		where co_bln.co_num = @CoNum

	end	

	if @RetCode = @RetCodeWaitCheck
	begin
		select top(1) @RetSeq = ret.ret_seq + 1 from zpv_co_retentions ret where ret.co_num = @CoNum order by ret_seq desc
		if @RetSeq is null set @RetSeq = 1
		
		INSERT INTO [zpv_co_retentions]
					([co_num]
					,[ret_seq]
					,[ret_code]
					,[ret_type]
					,[ret_date]
					,[site_ref])
				VALUES(
					@CoNum,
					@RetSeq,
					@RetCodeWaitCheck,
					'Credit',
					getdate(),
					@Site)
		update co set credit_hold = 1, credit_hold_date = GETDATE(), credit_hold_reason = @CreditLimitReason where co_num = @CoNum						

		if @TotalInvoiced = @TotalPayment
		begin
			update co_mst	
				set zpv_stat_internal = 'M03',
					ship_hold = 0
			where co_num = @CoNum
				
			update co_bln
				set co_bln.stat = 'O'
			where co_bln.co_num = @CoNum
			/*
			update coitem 
				set coitem.stat = 'O'
			where coitem.co_num = @CoNum
			*/
		end
		if @TotalInvoiced <> @TotalPayment
		begin
			update co_mst	
				set zpv_stat_internal = 'M07',
					ship_hold = 1
			where co_num = @CoNum
			/*	
			update coitem 
				set coitem.stat = 'P'
			where coitem.co_num = @CoNum
			*/
			update co_bln
				set co_bln.stat = 'P'
			where co_bln.co_num = @CoNum
		end
	end

	if @RetCode is null
	begin
		set @Infobar = 'Credito Autorizado'
		
		update co set credit_hold = 0, credit_hold_date = null, credit_hold_reason = null where co_num = @CoNum

		if @TotalInvoiced = @TotalPayment
		begin
			update co_mst	
				set zpv_stat_internal = 'M03',
					ship_hold = 0
			where co_num = @CoNum
				
			update co_bln
				set co_bln.stat = 'O'
			where co_bln.co_num = @CoNum

			update coitem 
				set coitem.stat = 'O'
			where coitem.co_num = @CoNum
		end
		if @TotalInvoiced <> @TotalPayment
		begin
			update co_mst	
				set zpv_stat_internal = 'M07',
					ship_hold = 1
			where co_num = @CoNum
				
			update coitem 
				set coitem.stat = 'P'
			where coitem.co_num = @CoNum

			update co_bln
				set co_bln.stat = 'P'
			where co_bln.co_num = @CoNum
		end
	end
end
else
begin
	set @Infobar = 'Credito Autorizado'
	
	delete from zpv_co_retentions
		where 
			co_num = @CoNum and
			(ret_code = @RetCodeCustomerHold or ret_code = @RetCodeBalanceDue or ret_code = @RetCodeCreditLimit or ret_code = @RetCodeTerms)
	update co set credit_hold = 0, credit_hold_date = null, credit_hold_reason = null where co_num = @CoNum	
	
	if @TotalInvoiced = @TotalPayment
	begin
		update co_mst	
			set zpv_stat_internal = 'M03',
				ship_hold = 0
		where co_num = @CoNum
		
		update co_bln
			set co_bln.stat = 'O'
		where co_bln.co_num = @CoNum

		update coitem 
			set coitem.stat = 'O'
		where coitem.co_num = @CoNum
	end
	if @TotalInvoiced <> @TotalPayment
	begin
		update co_mst	
			set zpv_stat_internal = 'M07',
				ship_hold = 1
		where co_num = @CoNum
		
		update coitem 
			set coitem.stat = 'P'
		where coitem.co_num = @CoNum

		update co_bln
			set co_bln.stat = 'P'
		where co_bln.co_num = @CoNum

		
	end
	
end
return



GO

