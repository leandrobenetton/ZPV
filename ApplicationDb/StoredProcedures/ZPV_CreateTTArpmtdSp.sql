/****** Object:  StoredProcedure [dbo].[ZPV_CreateTTArpmtdSp]    Script Date: 16/01/2015 03:11:25 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CreateTTArpmtdSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CreateTTArpmtdSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CreateTTArpmtdSp]    Script Date: 16/01/2015 03:11:25 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_CreateTTArpmtdSp] (
	@pSelect		ListYesNoType
,	@pCustNum		CustNumType
,	@pInvNum		InvNumType
,	@pDomAmtApplied	AmountType
,	@pForAmrApplied	AmountType
,	@pExchRate		ExchRateType	
,	@Infobar		InfobarType OUTPUT
)
AS

declare
	@ArtranCoNum	CoNumType

if @pSelect = 1	
BEGIN
	select @ArtranCoNum = ar.co_num from artran ar where ar.cust_num = @pCustNum and ar.inv_num = @pInvNum and ar.type = 'I'
	
	if exists(select * from zpv_tt_arpmtd tt where tt.cust_num = @pCustNum and tt.inv_num = @pInvNum)
	delete from zpv_tt_arpmtd where cust_num = @pCustNum and inv_num = @pInvNum

	if @pCustNum is not null and @pInvNum is not null and (@pDomAmtApplied is not null or @pDomAmtApplied > 0)
	begin
		insert into zpv_tt_arpmtd(
			cust_num,
			inv_num,
			co_num,
			dom_amt_applied,
			for_amt_applied,
			exch_rate)
		values(
			@pCustNum,
			@pInvNum,
			@ArtranCoNum,
			@pDomAmtApplied,
			@pForAmrApplied,
			@pExchRate)
	end
	else
	begin
		set @Infobar = 'Los parametros no son correctos, no se generó el registro'
	end				
END

if @pSelect = 0 or @pSelect is null
begin
	delete from zpv_tt_arpmtd where cust_num = @pCustNum and inv_num = @pInvNum
end
GO

