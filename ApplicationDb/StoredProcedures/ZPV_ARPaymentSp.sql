/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentSp]    Script Date: 16/01/2015 03:12:20 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ARPaymentSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_ARPaymentSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ARPaymentSp]    Script Date: 16/01/2015 03:12:20 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_ARPaymentSp] (
    @PayId			ZlaArPayIdType
,	@Drawer			varchar(20)
,	@CoPayRowPointer	RowPointerType
,	@Origen			varchar(2) = 'CO'
,	@Infobar		InfobarType OUTPUT
) AS

declare  @CustNum          CustNumType
        ,@BankCode         BankCodeType
        ,@CustCheckNum     ArCheckNumType
        ,@PayType          CustPayTypeType
        ,@Severity         Int
	   ,@PProcessId	  RowPointerType

DECLARE 
	@Site SiteType

SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

SET @Severity = 0

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
   
   EXEC @Severity =  dbo.ZPV_ARPaymentPostingSp 
				    @PProcessId = @PProcessId,
				    @PCustNum	= @CustNum,
				    @PBankCode	= @BankCode,
				    @PType		= @PayType,
				    @PCheckNum  = @CustCheckNum,
					@PDrawer	= @Drawer,
					@PCoPayRowPointer = @CoPayRowPointer,
					@PZlaArPayId	= @PayId,
					@POrigen	= @Origen,
				    @Infobar	= @Infobar OUTPUT
   
   
	FETCH NEXT FROM OrdenPago
	INTO
		@CustNum,
		@BankCode,
		@PayType,
		@CustCheckNum   	
END
CLOSE OrdenPago
DEALLOCATE OrdenPago

if @Severity <> 0
    return @Severity
else
   SET @Severity = 0

RETURN @Severity
GO

