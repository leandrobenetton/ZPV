/****** Object:  StoredProcedure [dbo].[ZPV_CoGetCustomerInfoSp]    Script Date: 16/01/2015 03:14:09 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CoGetCustomerInfoSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_CoGetCustomerInfoSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CoGetCustomerInfoSp]    Script Date: 16/01/2015 03:14:09 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/CoProductGetRefInfoSp.sp 10    3/04/10 10:27a Dahn $ */
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

CREATE PROCEDURE [dbo].[ZPV_CoGetCustomerInfoSp] (
	@ZpvBillCuit			varchar(30) = null
,   @ZpvGeneric			CustTypeType OUTPUT
,   @ZpvBillFiscalName	varchar(100) OUTPUT
,   @ZpvBillAddr1	    varchar(100) OUTPUT
,   @ZpvBillAddr2	    varchar(100) OUTPUT
,   @ZpvBillAddr3	    varchar(100) OUTPUT
,   @ZpvBillAddr4	    varchar(100) OUTPUT
,   @ZpvBillCity		    varchar(50) OUTPUT
,   @ZpvBillZip		    varchar(50) OUTPUT
,   @ZpvBillCounty	    varchar(50) OUTPUT
,   @ZpvBillState	    varchar(50) OUTPUT
,   @ZpvBillCountry	    varchar(50) OUTPUT
,   @ZpvCustNum			CustNumType OUTPUT
,   @ZpvCustType			CustTypeType OUTPUT
,	@ZpvBillTypeDoc		varchar(10) OUTPUT
,	@ZpvBillPhone		varchar(30) OUTPUT
)
AS

DECLARE
   @Severity        Int

DECLARE 
	@Site SiteType,
	@Infobar InfobarType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

set   @ZpvBillFiscalName	= null
set   @ZpvBillAddr1			= null
set   @ZpvBillAddr2			= null
set   @ZpvBillAddr3			= null
set   @ZpvBillAddr4			= null
set   @ZpvBillCity		    = null
set   @ZpvBillZip		    = null
set   @ZpvBillCounty	    = null
set   @ZpvBillState			= null
set   @ZpvBillCountry	    = null
set	  @ZpvCustNum			= null
set	  @ZpvCustType			= null
set   @ZpvGeneric			= null
set	  @ZpvBillTypeDoc		= null	
set	  @ZpvBillPhone			= null

select @ZpvGeneric = generic_cust_type from zpv_parms where parms_key = 0

-- Find Customer by CUIT
BEGIN
	if exists(select 1 from customer where tax_reg_num1 = @ZpvBillCuit and cust_seq = 0)
	begin
		select 
			@ZpvCustNum			= a.cust_num
		,	@ZpvBillFiscalName	= b.name
		,	@ZpvBillAddr1		= b.addr##1
		,	@ZpvBillAddr2		= b.addr##2
		,	@ZpvBillAddr3		= b.addr##3
		,	@ZpvBillAddr4		= b.addr##4
		,	@ZpvBillCity		= b.city
		,	@ZpvBillZip			= b.zip
		,	@ZpvBillCountry		= b.county
		,	@ZpvBillState		= b.[state]
		,	@ZpvBillCountry		= b.country
		,	@ZpvCustType		= a.cust_type
		,	@ZpvBillPhone		= a.phone##1
		from customer a 
		join custaddr b on b.cust_num = a.cust_num and b.cust_seq = 0
		where a.tax_reg_num1 = @ZpvBillCuit
		return
	end
	else
	begin
		select top(1)
			@ZpvBillFiscalName	= co.zpv_bill_fiscal_name
		,	@ZpvBillAddr1	    = co.zpv_bill_addr1
		,	@ZpvBillAddr2	    = co.zpv_bill_addr2
		,	@ZpvBillAddr3	    = co.zpv_bill_addr3
		,	@ZpvBillAddr4	    = co.zpv_bill_addr4
		,	@ZpvBillCity		= co.zpv_bill_city
		,	@ZpvBillZip			= co.zpv_bill_zip
		,	@ZpvBillCounty	    = co.zpv_bill_county
		,	@ZpvBillState	    = co.zpv_bill_state
		,	@ZpvBillCountry		= co.zpv_bill_country
		,	@ZpvCustNum			= co.cust_num
		,	@ZpvCustType		= ISNULL(cus.cust_type,@ZpvGeneric)
		,	@ZpvBillTypeDoc		= co.zpv_bill_type_doc
		,	@ZpvBillPhone		= co.zpv_phone
		from co
		left join customer cus on cus.cust_num = co.cust_num and cus.cust_seq = 0
		where
			co.zpv_bill_cuit	= @ZpvBillCuit
		order by co.co_num desc
	end
END


GO

