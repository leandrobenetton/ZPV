/****** Object:  StoredProcedure [dbo].[ZPV_CreateDeleteTTCoBillSp]    Script Date: 16/01/2015 03:12:36 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CreateDeleteTTCoBillSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CreateDeleteTTCoBillSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CreateDeleteTTCoBillSp]    Script Date: 16/01/2015 03:12:36 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_CreateDeleteTTCoBillSp] (
	@pCustNum		CustNumType
,	@pCoNum			CoNumType	
,	@pType			int
,	@Infobar		InfobarType OUTPUT
)
AS

if @pType = 0
begin
	delete from zpv_tt_cobill where cust_num = @pCustNum and co_num = @pCoNum
end

if @pType = 1
begin
	if not exists(select 1 from zpv_tt_cobill where cust_num = @pCustNum and co_num = @pCoNum)
	begin
		insert into zpv_tt_cobill(
			cust_num
		,	co_num)
		values(
			@pCustNum
		,	@pCoNum)
	end
end

GO

