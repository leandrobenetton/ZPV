/****** Object:  StoredProcedure [dbo].[ZPV_GetCustomerOrderInfoSp]    Script Date: 11/06/2014 16:24:57 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GetCustomerOrderInfoSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GetCustomerOrderInfoSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GetCustomerOrderInfoSp]    Script Date: 11/06/2014 16:24:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Header: /ApplicationDB/Stored Procedures/CoUpdateCommSlsmanSp.sp 11    3/04/10 10:28a Dahn $ */
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
/* $Archive: /ApplicationDB/Stored Procedures/CoUpdateCommSlsmanSp.sp $
 *
 * SL8.02 11 rs4588 Dahn Thu Mar 04 10:28:55 2010
 * RS4588 Copyright header changes
 *
 * $NoKeywords: $
 */
CREATE PROCEDURE [dbo].[ZPV_GetCustomerOrderInfoSp] (
	@CustNum   CustNumType
,	@CustSeq   CoLineType
,	@GenericCustType CustTypeType
,	@BillAddr1	varchar(100)	output
,	@BillAddr2	varchar(100)	output
,	@BillAddr3	varchar(100)	output
,	@BillAddr4	varchar(100)	output
,	@BillCity	CityType		output
,	@BillZip	varchar(20)		output
,	@BillCounty	CountyType		output
,	@BillState	StateType		output
,	@BillCountry	CountryType	output
,	@BillMail	varchar(100)	output
,	@ShipAddr1	varchar(100)	output
,	@ShipAddr2	varchar(100)	output
,	@ShipAddr3	varchar(100)	output
,	@ShipAddr4	varchar(100)	output
,	@ShipCity	CityType		output
,	@ShipZip	varchar(20)		output
,	@ShipCounty	CountyType		output
,	@ShipState	StateType		output
,	@ShipCountry	CountryType	output
,	@TaxDocType	varchar(10)		output
,	@CustType	CustTypeType	output
,	@CustGenericCode CustTypeType output
,	@ArTypeId	ZlaArTypeIdType	output
,	@DocId		varchar(10)	output
,	@RetCode	varchar(10) output
,	@CreditLimit ListYesNoType output
,	@BillName	varchar(60) output
,	@TaxCode1	TaxCodeType output
,	@TaxCode2	TaxCodeType output
,	@TaxRegNum	TaxRegNumType output
,   @EndUserType EndUserTypeType Output
,	@Infobar InfobarType OUTPUT
)
AS


DECLARE
  @Severity     INT
, @InfobarText  InfobarType

DECLARE @CharAttribute varchar(20), @SQL nvarchar(500), @ParmDefinition nvarchar(500)

SELECT
  @Severity = 0

IF @CustNum IS NULL
	RETURN 0
IF @CustSeq IS NULL
	RETURN 0  

IF @GenericCustType IS NULL
BEGIN
	SELECT @GenericCustType = par.generic_cust_type FROM zrt_parms par WHERE par.parms_key = 0
END

SELECT @CustType = isnull(cus.cust_type,'') FROM customer cus WHERE cus.cust_num = @CustNum and cus.cust_seq = @CustSeq

IF @CustType = @GenericCustType
BEGIN
	select 
		@BillAddr1		= '', --cad.addr##1,
		@BillAddr2		= '', --cad.addr##2,
		@BillAddr3		= '', --cad.addr##3,
		@BillAddr4		= '', --cad.addr##4,
		@BillCity		= '', --cad.city,
		@BillCountry	= '', --cad.country,
		@BillCounty		= '', --cad.county,
		@BillMail		= '', --cad.external_email_addr,
		@BillState		= '', --cad.[state],
		@BillZip		= '', --cad.zip,
		@BillName		= '' --cad.name
	from custaddr_mst cad
	where
		cad.cust_num	= @CustNum and
		cad.cust_seq	= 0

	select 
		@ShipAddr1		= '', --cad.addr##1,
		@ShipAddr2		= '', --cad.addr##2,
		@ShipAddr3		= '', --cad.addr##3,
		@ShipAddr4		= '', --cad.addr##4,
		@ShipCity		= '', --cad.city,
		@ShipCountry	= '', --cad.country,
		@ShipCounty		= '', --cad.county,
		--@BillMail		= cad.external_email_addr,
		@ShipState		= '', --cad.[state],
		@ShipZip		= '' --cad.zip
	from custaddr_mst cad
	where
		cad.cust_num	= @CustNum and
		cad.cust_seq	= 0

	select 
		--@TaxDocType = att.char_attribute4,
		@CustType	= cus.cust_type,
		@EndUserType = cus.end_user_type,
		@TaxCode1	= '',
		@TaxCode2	= '',
		@TaxRegNum	= ''
	from customer_mst cus
	left join attribute_value_mst att on att.RefRowPointer = cus.RowPointer
	where cus.cust_num = @CustNum and cus.cust_seq = 0 
	
	select
		--@ArTypeId	= b.ar_type_id,
		@DocId		= a.doc_id,
		@RetCode	= a.ret_code,
		@CreditLimit	= a.credit_limit
	from zpv_co_codes a
	--left join zla_ar_type_mst b on b.doc_id = a.doc_id
	where
		a.end_user_type = @EndUserType and 
		a.cust_type		= @CustType

	set @ParmDefinition = N'@CustomerID CustNumType, @TaxDocTypeOUT varchar(10) OUTPUT'

	select @CharAttribute = a.attr_user_field from zla_tax_rpt_group_mst a where rpt_group = 17

	set @SQL = 'select top(1) @TaxDocTypeOUT = att.' + @CharAttribute + '
				from customer_mst cus
				left join attribute_value_mst att on att.RefRowPointer = cus.RowPointer
				where cus.cust_num = @CustomerID and cus.cust_seq = 0'

	execute sp_executesql @SQL, @ParmDefinition, @CustomerID = @CustNum, @TaxDocTypeOUT = @TaxDocType OUTPUT
END
ELSE
BEGIN
	select 
		@BillAddr1		= cad.addr##1,
		@BillAddr2		= cad.addr##2,
		@BillAddr3		= cad.addr##3,
		@BillAddr4		= cad.addr##4,
		@BillCity		= cad.city,
		@BillCountry	= cad.country,
		@BillCounty		= cad.county,
		@BillMail		= cad.external_email_addr,
		@BillState		= cad.[state],
		@BillZip		= cad.zip,
		@BillName		= cad.name
	from custaddr_mst cad
	where
		cad.cust_num	= @CustNum and
		cad.cust_seq	= 0

	select 
		@ShipAddr1		= cad.addr##1,
		@ShipAddr2		= cad.addr##2,
		@ShipAddr3		= cad.addr##3,
		@ShipAddr4		= cad.addr##4,
		@ShipCity		= cad.city,
		@ShipCountry	= cad.country,
		@ShipCounty		= cad.county,
		--@BillMail		= cad.external_email_addr,
		@ShipState		= cad.[state],
		@ShipZip		= cad.zip
	from custaddr_mst cad
	where
		cad.cust_num	= @CustNum and
		cad.cust_seq	= 0

	select 
		--@TaxDocType = att.char_attribute4,
		@CustType	= cus.cust_type,
		@EndUserType = cus.end_user_type,
		@TaxCode1	= cus.tax_code1,
		@TaxCode2	= cus.tax_code2,
		@TaxRegNum	= cus.tax_reg_num1
	from customer_mst cus
	left join attribute_value_mst att on att.RefRowPointer = cus.RowPointer
	where cus.cust_num = @CustNum and cus.cust_seq = 0 
	
	select
		--@ArTypeId	= b.ar_type_id,
		@DocId		= a.doc_id,
		@RetCode	= a.ret_code,
		@CreditLimit	= a.credit_limit
	from zpv_co_codes a
	--left join zla_ar_type_mst b on b.doc_id = a.doc_id
	where
		a.end_user_type = @EndUserType and 
		a.cust_type		= @CustType
		
	set @ParmDefinition = N'@CustomerID CustNumType, @TaxDocTypeOUT varchar(10) OUTPUT'

	select @CharAttribute = a.attr_user_field from zla_tax_rpt_group_mst a where rpt_group = 17

	set @SQL = 'select top(1) @TaxDocTypeOUT = att.' + @CharAttribute + '
				from customer_mst cus
				left join attribute_value_mst att on att.RefRowPointer = cus.RowPointer
				where cus.cust_num = @CustomerID and cus.cust_seq = 0 '

	execute sp_executesql @SQL, @ParmDefinition, @CustomerID = @CustNum, @TaxDocTypeOUT = @TaxDocType OUTPUT
	
	
END
	
RETURN 0
GO

