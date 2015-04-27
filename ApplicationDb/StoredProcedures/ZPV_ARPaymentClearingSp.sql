/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentClearingSp]    Script Date: 16/01/2015 03:12:20 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ARPaymentClearingSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_ARPaymentClearingSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentClearingSp]    Script Date: 16/01/2015 03:12:20 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_ARPaymentClearingSp] (
    @pClearing		ZpvClearingType
,	@Infobar		InfobarType OUTPUT
) AS

declare  
	@CustNum        CustNumType
,	@BankCode       BankCodeType
,	@CustCheckNum   ArCheckNumType
,	@PayType        CustPayTypeType
,	@Severity       Int
,	@PProcessId		RowPointerType
,	@PayId			ZlaArPayIdType

DECLARE 
	@Site SiteType

SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

SET @Severity = 0

BEGIN TRANSACTION;
BEGIN TRY
	if not exists(select 1 from zpv_ar_clearing cl where cl.clearing = @pClearing and cl.stat = 'O')
	begin
		set @Infobar = 'La Liquidacion se encuentra Registrada'
		set @Severity = 17
		rollback transaction
		return @Severity
	end

	-- Registro de Recibos
	declare ClearingPay cursor for
	select
		ar.ar_pay_id
	from zla_ar_hdr ar
	where	ar.zpv_clearing = @pClearing
		and	ar.stat			= 'O'
	open ClearingPay
	fetch next from ClearingPay
	into @PayId
	while @@FETCH_STATUS = 0
	begin
		DECLARE OrdenPago CURSOR FOR
		select 
			cust_num,
			bank_code,
			type,
			check_num
		from arpmt
		where zla_ar_pay_id = @PayId
		OPEN OrdenPago
		FETCH NEXT FROM OrdenPago
		INTO
			@CustNum,
			@BankCode,
			@PayType,
			@CustCheckNum
		WHILE @@FETCH_STATUS = 0
		BEGIN
		   SET @PProcessId = NEWID()
   
		   EXEC @Severity =  dbo.ZPV_ARPaymentPostingClearingSp 
				@PProcessId = @PProcessId
			,	@PCustNum	= @CustNum
			,	@PBankCode	= @BankCode
			,	@PType		= @PayType
			,	@PCheckNum  = @CustCheckNum
			,	@PZlaArPayId	= @PayId
			,	@Infobar	= @Infobar OUTPUT
			
			if @Severity <> 0
			begin
				rollback transaction
				return @Severity
			end	

			FETCH NEXT FROM OrdenPago
			INTO
				@CustNum,
				@BankCode,
				@PayType,
				@CustCheckNum   	
		END
		CLOSE OrdenPago
		DEALLOCATE OrdenPago

		update zla_ar_hdr
			set stat = 'P'
		where ar_pay_id = @PayId

		fetch next from ClearingPay
		into @PayId
	end
	close ClearingPay
	deallocate ClearingPay

	-- Registro de gastos
	EXEC	@Severity = [dbo].[ZPV_ClearingExpensesPostSp]
		@pClearing = @pClearing,
		@Infobar = @Infobar OUTPUT

	if @Severity <> 0
	begin
		rollback transaction
		return @Severity
	end
	
	update zpv_ar_clearing
		set stat = 'P'
	where clearing = @pClearing

	set @Infobar = 'Liquidacion Registrada'
END TRY
BEGIN CATCH
	SELECT 
         ERROR_NUMBER() AS ErrorNumber
        ,ERROR_SEVERITY() AS ErrorSeverity
        ,ERROR_STATE() AS ErrorState
        ,ERROR_PROCEDURE() AS ErrorProcedure
        ,ERROR_LINE() AS ErrorLine
        ,ERROR_MESSAGE() AS ErrorMessage;

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
	COMMIT TRANSACTION;
GO




