
/****** Object:  StoredProcedure [dbo].[ZRT_GenerateShipToSp]    Script Date: 05/02/2015 12:54:36 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GenerateShipToSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GenerateShipToSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GenerateShipToSp]    Script Date: 05/02/2015 12:54:36 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[ZPV_GenerateShipToSp] (
	@pCoNum		CoNumType = null
,	@Infobar    Infobar        OUTPUT
)
AS

DECLARE
	@Severity             INT
,	@CustSeq			CustSeqType

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

DECLARE
	@pCustNum		CustNumType = null
,	@pZpvBillCuit	varchar(25)	= null
,	@pCurrCode		CurrCodeType = null
,	@pName			NameType	= null
,	@pAddr1			AddressType = null
,	@pAddr2			AddressType = null
,	@pAddr3			AddressType = null
,	@pAddr4			AddressType = null
,	@pCity			CityType = null
,	@pCounty		CountyType = null
,	@pZip			PostalCodeType = null
,	@pState			StateType	= null
,	@pCountry		CountryType = null
,	@pCustType		CustTypeType = null
,	@pShipCode		ShipCodeType = null
,	@pWhse			WhseType = null

SET @Severity = 0
SET @Infobar  = NULL


select
	@pCustNum		= co.cust_num
,	@pZpvBillCuit	= co.zpv_bill_cuit
,	@pCurrCode		= cad.curr_code
,	@pName			= co.zpv_bill_fiscal_name
,	@pAddr1			= co.zpv_bill_addr1
,	@pAddr2			= co.zpv_bill_addr2
,	@pAddr3			= co.zpv_bill_addr3
,	@pAddr4			= co.zpv_bill_addr4
,	@pCity			= co.zpv_bill_city
,	@pCounty		= co.zpv_bill_county
,	@pZip			= co.zpv_bill_zip
,	@pState			= co.zpv_bill_state
,	@pCountry		= co.zpv_bill_country
,	@pCustType		= cus.cust_type	
,	@pShipCode		= co.ship_code
,	@pWhse			= co.whse
from co
inner join custaddr cad on cad.cust_num = co.cust_num and cad.cust_seq = 0
inner join customer cus on cus.cust_num = co.cust_num and cus.cust_seq = 0
where	co.co_num = @pCoNum


if @pCustNum is null
begin
	select	@Infobar = 'El Cliente No existe'
		,	@Severity = 16
	return @Severity
end

begin
	select top 1 @CustSeq = cus.cust_seq + 1 from customer cus where cus.cust_num = @pCustNum order by cus.cust_seq desc
	if @CustSeq is null
	begin 
		select	@Infobar = 'Error al agregar una nueva secuencia de cliente'
			,	@Severity = 16
		return @Severity
	end
end

select
	@pCustNum		
,	@pZpvBillCuit	
,	@pCurrCode		
,	@pName			
,	@pAddr1			
,	@pAddr2			
,	@pAddr3			
,	@pAddr4			
,	@pCity			
,	@pCounty		
,	@pZip			
,	@pState			
,	@pCountry		
,	@pCustType		
,	@pShipCode		
,	@pWhse		
		
if not exists(select 1 from customer cus where cus.cust_num = @pCustNum and cus.tax_reg_num1 = @pZpvBillCuit)
begin
	insert into customer(
		cust_num
	,	cust_seq
	,	cust_type
	,	terms_code
	,	whse
	,	bank_code
	,	pay_type
	,	tax_code1
	,	tax_code2
	,	pricecode
	,	end_user_type
	,	inv_category
	,	tax_reg_num1)
	select
		@pCustNum
	,	@CustSeq
	,	@pCustType
	,	cus.terms_code
	,	@pWhse
	,	cus.bank_code
	,	cus.pay_type
	,	cus.tax_code1
	,	cus.tax_code2
	,	cus.pricecode
	,	cus.end_user_type
	,	cus.inv_category
	,	@pZpvBillCuit
	from customer cus
	where	cus.cust_num = @pCustNum
		and	cus.cust_seq = 0
	
	update custaddr
	set	name		= @pName
	,	city		= @pCity
	,	state		= @pState
	,	zip			= @pZip
	,	county		= @pCounty
	,	country		= @pCountry
	--,	bal_method	= cad.bal_method
	,	addr##1		= @pAddr1
	,	addr##2		= @pAddr2
	,	addr##3		= @pAddr3
	,	addr##4		= @pAddr4
	,	curr_code	= @pCurrCode
	from custaddr cad
	where	cad.cust_num = @pCustNum
		and cad.cust_seq = @CustSeq	

end
else
begin
	select top 1 
		@CustSeq = cus.cust_seq
	from customer cus 
	where	cus.cust_num = @pCustNum 
	and cus.tax_reg_num1 = @pZpvBillCuit
end

--update co
--	set co.cust_seq = isnull(@CustSeq,0)
--where co.co_num = @pCoNum


go