/****** Object:  StoredProcedure [dbo].[ZPV_CreateDrawerTransSp]    Script Date: 16/01/2015 03:11:52 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CreateDrawerTransSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CreateDrawerTransSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CreateDrawerTransSp]    Script Date: 16/01/2015 03:11:52 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/ARPaymentPostingSp.sp 73    4/11/14 4:02a Ychen1 $ */
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

CREATE PROCEDURE [dbo].[ZPV_CreateDrawerTransSp] (
	@pDrawer			varchar(20),
	@pGlBankRowPointer	RowPointerType,
	@pCoPayRowPointer	RowPointerType,
	@pAmount			AmountType,
	@pTransDate			DateType,
	@pArPayId			ZlaArPayIdType,
	@pOrigen			varchar(2) = 'CO',
	@Infobar			InfobarType OUTPUT)

AS

DECLARE
  @Severity             INT

SET @Severity = 0
SET @Infobar  = NULL

declare
	@TransNum			MatlTransNumType,
	@CurrCode			CurrCodeType,
	@ExchRate			ExchRateType,
	@CoNum				CoNumType,
	@ZlaBankType		ZlaBankType,
	@BankCode			BankCodeType

BEGIN
	if @pOrigen = 'CO'
	begin
		select
			@CurrCode	= pay.curr_code,
			@ExchRate	= isnull(pay.exch_rate,1),
			@CoNum		= pay.co_num,
			@BankCode	= pay.bank_code
		from zpv_co_payments pay
		where pay.RowPointer = @pCoPayRowPointer

		select 
			@ZlaBankType	= bank.zla_bank_type
		from zpv_co_payments pay
		inner join bank_hdr bank on bank.bank_code = pay.bank_code
		where
			pay.bank_code	= @BankCode
	end

	if @pOrigen = 'AR'
	begin
		select
			@CurrCode	= pay.curr_code,
			@ExchRate	= isnull(pay.exch_rate,1),
			@CoNum		= null,
			@BankCode	= pay.bank_code
		from zpv_ar_payments pay
		where pay.RowPointer = @pCoPayRowPointer

		select 
			@ZlaBankType	= bank.zla_bank_type
		from zpv_ar_payments pay
		inner join bank_hdr bank on bank.bank_code = pay.bank_code
		where
			pay.bank_code	= @BankCode
	end
	
	select top 1 @TransNum = dtr.trans_num + 1 from zpv_drawer_trans dtr order by dtr.trans_num desc
	if @TransNum is null set @TransNum = 1

	INSERT INTO [dbo].[zpv_drawer_trans]
			   ([trans_num]
			   ,[type]
			   ,[relief_num]
			   ,[trans_date]
			   ,[packet]
			   ,[drawer]
			   ,[glbank_rowpointer]
			   ,[copay_rowpointer]
			   ,[amount]
			   ,[curr_code]
			   ,[exch_rate]
			   ,[for_amount]
			   ,[apply_date]
			   ,[ar_type_id]
			   ,[co_num]
			   ,[zla_bank_type]
			   ,[pending]
			   ,[from_drawer]
			   ,[from_relief_num])
		 VALUES
			   (@TransNum
			   ,'T'
			   ,0
			   ,@pTransDate
			   ,null
			   ,@pDrawer
			   ,@pGlBankRowPointer
			   ,@pCoPayRowPointer
			   ,@pAmount
			   ,@CurrCode
			   ,@ExchRate
			   ,round(@pAmount / @ExchRate,2)
			   ,null
			   ,@pArPayId
			   ,@CoNum
			   ,@ZlaBankType
			   ,0
			   ,null
			   ,0)

END



GO

