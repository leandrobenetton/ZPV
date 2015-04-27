/****** Object:  StoredProcedure [dbo].[ZPV_CLM_TermsPaymentsSp]    Script Date: 18/01/2015 03:59:32 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_TermsPaymentsSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_TermsPaymentsSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_TermsPaymentsSp]    Script Date: 18/01/2015 03:59:32 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[ZPV_CLM_TermsPaymentsSp](
  @pTerms		TermsCodeType	= NULL
, @pCustType	CustTypeType	= NULL
, @pDiscCo		AmountType		= NULL
, @pDiscLines	int				= NULL
, @pDiscPromo	int				= NULL
, @Infobar      InfobarType OUTPUT
) AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

select
	ter.posm_pay_type
,	ter.terms_code
,	pay.logifld
,	pay.bank_code
,	pay.trans_type
,	isnull(bank.zla_bank_type,'E')
,	pay.description
,	1
from zpv_terms_ptype ter
inner join posm_pay_type_mst pay on pay.posm_pay_type = ter.posm_pay_type
left join bank_hdr_mst bank on bank.bank_code = pay.bank_code 
where	ter.terms_code		= @pTerms
	and	ter.cust_type		= @pCustType
	--and	(ter.disc_co		= 0 or @pDiscCo = 0 or ter.disc_co is null or @pDiscCo is null)
	--and (ter.disc_lines		= 0 or @pDiscLines = 0 or ter.disc_lines is null or @pDiscLines is null)
	--and (ter.disc_promo		= 0 or @pDiscPromo = 0 or ter.disc_promo is null or @pDiscPromo is null)

go
