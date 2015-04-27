/****** Object:  UserDefinedFunction [dbo].[ZRT_CoTotalTaxMisc]    Script Date: 07/19/2014 15:43:47 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CoTotalTaxMisc]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ZPV_CoTotalTaxMisc]
GO

/****** Object:  UserDefinedFunction [dbo].[ZPV_CoTotalTaxMisc]    Script Date: 07/19/2014 15:43:47 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ZPV_CoTotalTaxMisc 1      */
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

/* $Archive: /ApplicationDB/Stored Procedures/ZPV_CoTotalTaxMisc $
 *
 * SL9.00.10 lbenetton Sun Nov 1 13:00:00 2014
 * Final Version 1.0.0
 * 
 * $NoKeywords: $
 */
 
CREATE FUNCTION [dbo].[ZPV_CoTotalTaxMisc] (
@CoNum CoNumType
)  
RETURNS TaxRateType AS  
BEGIN 
	declare
		@CoTaxCode1		TaxCodeType,
		@CoTaxCode2		TaxCodeType

	declare
		@TaxRate1			TaxRateType,
		@TaxRate2			TaxRateType,
		@TaxTotal			TaxRateType
			
	select 
		@CoTaxCode1		= co.msc_tax_code1,
		@CoTaxCode2		= co.msc_tax_code2
	from co_mst co where co.co_num = @CoNum

	if @CoTaxCode1 is not null
	begin
		select 
			@TaxRate1	= tax.tax_rate
		from taxcode_mst tax
		where
			tax.tax_code	= @CoTaxCode1
	end

	if @CoTaxCode2 is not null
	begin
		select 
			@TaxRate2	= tax.tax_rate
		from taxcode_mst tax
		where
			tax.tax_code	= @CoTaxCode2
	end
		
	set @TaxTotal	= @TaxRate1 + @TaxRate2
   
    return (@TaxTotal)
END
GO

