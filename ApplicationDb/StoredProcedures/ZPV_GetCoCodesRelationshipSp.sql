/****** Object:  StoredProcedure [dbo].[ZPV_GetCoCodesRelationshipSp]    Script Date: 10/29/2014 12:27:18 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_GetCoCodesRelationshipSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_GetCoCodesRelationshipSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_GetCoCodesRelationshipSp]    Script Date: 10/29/2014 12:27:18 ******/
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
CREATE PROCEDURE [dbo].[ZPV_GetCoCodesRelationshipSp] (
	@EndUserType	EndUserTypeType
,	@CustType		CustTypeType
,	@DocId0			varchar(10)	
,	@RetCode0		varchar(10)	
,	@CreditLimit0	ListYesNoType
,	@DocId			varchar(10)		output
,	@RetCode		varchar(10)		output
,	@CreditLimit	ListYesNoType	output
,	@Infobar		InfobarType		output
)
AS

DECLARE
  @Severity     INT
, @InfobarText  InfobarType

SELECT
  @Severity = 0

set @DocId = null
set @CreditLimit = null
set @RetCode = null

BEGIN
	select
		@DocId			= a.doc_id,
		@RetCode		= a.ret_code,
		@CreditLimit	= a.credit_limit
	from zpv_co_codes a
	where
		a.end_user_type = @EndUserType and 
		a.cust_type		= @CustType
		
	if @DocId is null --or @RetCode is null or @CreditLimit is null
	begin
		set @Infobar = 'No existe relación entre Tipo de Usuario Final ' + @EndUserType + ' y Tipo de Cliente ' + @CustType
		
		set @DocId			= @DocId0
		set @CreditLimit	= @CreditLimit0
		set @RetCode		= @RetCode0
	end		
END
	
RETURN 0	 




GO

