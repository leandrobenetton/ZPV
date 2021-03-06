/****** Object:  StoredProcedure [dbo].[ZPV_VoidARPaymentClearingSp]    Script Date: 16/01/2015 03:12:20 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_VoidARPaymentClearingSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_VoidARPaymentClearingSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_VoidARPaymentClearingSp]    Script Date: 16/01/2015 03:12:20 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_VoidARPaymentClearingSp] (
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
	if not exists(select 1 from zpv_ar_clearing cl where cl.clearing = @pClearing and cl.stat = 'P')
	begin
		set @Infobar = 'La Liquidacion se encuentra Sin Registrar'
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
		and	ar.stat			= 'P'
	open ClearingPay
	fetch next from ClearingPay
	into @PayId
	while @@FETCH_STATUS = 0
	begin
		EXEC @Severity =  dbo.ZPV_VoidARPaymentSp 
			@PayId	= @PayId
		,	@Infobar	= @Infobar OUTPUT
		
		if @Severity <> 0
		begin
			rollback transaction
			return @Severity
		end			

		update zla_ar_hdr set stat = 'V' where ar_pay_id = @PayId

		fetch next from ClearingPay
		into @PayId
	end
	close ClearingPay
	deallocate ClearingPay

	-- Registro de gastos
	EXEC	@Severity = [dbo].[ZPV_VoidClearingExpensesPostSp]
		@pClearing = @pClearing,
		@Infobar = @Infobar OUTPUT

	if @Severity <> 0
	begin
		rollback transaction
		return @Severity
	end
	
	update zpv_ar_clearing
		set stat = 'A'
	where clearing = @pClearing

	set @Infobar = 'Liquidacion Anulada'
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




