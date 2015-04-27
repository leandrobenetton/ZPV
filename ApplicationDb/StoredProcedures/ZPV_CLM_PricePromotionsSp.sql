/****** Object:  StoredProcedure [dbo].[ZPV_CLM_PricePromotionsSp]    Script Date: 18/01/2015 03:59:32 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_PricePromotionsSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_PricePromotionsSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_PricePromotionsSp]    Script Date: 18/01/2015 03:59:32 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ZPV_CLM_PricePromotionsSp.sp 7     5/31/13 1:25a exia $ */
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

CREATE PROCEDURE [dbo].[ZPV_CLM_PricePromotionsSp](
  @PCoNum      CoNumType = NULL
, @PItem       ItemType  = NULL
, @PromotionCode PromotionCodeType = NULL
, @Infobar      InfobarType OUTPUT
) AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

declare @ttProm table(
	promotion_code		PromotionCodeType
,	description			DescriptionType)

DECLARE	
	@Severity		INT
,	@CustType		CustTypeType
,	@CorpCust		CustNumType
,	@Slsman			SlsmanType
,	@EndUserType	EndUserTypeType
,	@CustNum		CustNumType
,	@CustSeq		CustSeqType
,	@ProductCode	ProductCodeType
,	@CampaignID		CampaignIDType
,	@ZrtTermsCode	TermsCodeType
,	@ZrtPos			varchar(20)
,	@ZrtPricecode	PricecodeType
,	@OrderDate		DateType
,	@Whse			WhseType
,	@Campaign		varchar(20)


SET @Severity = 0
SET @Infobar = NULL

SELECT
	@CustType		= cc.cust_type 
,	@CorpCust		= adr.corp_cust
,	@Slsman			= co.slsman
,	@EndUserType	= co.end_user_type 
,	@CustNum		= co.cust_num 
,	@CustSeq		= co.cust_seq
,	@CampaignID		= opp.campaign_id
,	@ZrtPos			= co.zpv_pos
,	@ZrtTermsCode	= co.terms_code
,	@ZrtPricecode	= co.pricecode
,	@OrderDate		= co.order_date
,	@Whse			= co.whse
FROM co
INNER JOIN customer AS cc ON cc.cust_num = co.cust_num
LEFT JOIN custaddr AS adr ON cc.cust_num = adr.corp_cust and cc.cust_seq = 0
LEFT JOIN opportunity AS opp on opp.opp_id = co.opp_id
WHERE co.co_num = @PCoNum

SELECT @ProductCode = item.product_code
FROM item
WHERE item.item = @PItem

insert into @ttProm(
	promotion_code
,	description)
select ppr.promotion_code, ppr.[description]
from price_promotion_mst ppr
where	(ppr.item = @PItem or ppr.item is null or @PItem is null)
	and	(ppr.cust_type = @CustType or ppr.cust_type is null or @CustType is null)
	and	(ppr.end_user_type = @EndUserType or ppr.end_user_type is null or @EndUserType is null)
	and	(ppr.slsman = @Slsman or ppr.slsman is null or @Slsman is null)
	and	(ppr.cust_num = @CustNum or ppr.cust_num is null or @CustNum is null)
	and	(ppr.whse = @Whse or ppr.whse is null or @Whse is null)
	and	(ppr.product_code = @ProductCode or ppr.product_code is null or @ProductCode is null)
	and (@OrderDate between isnull(ppr.effect_date,dbo.LowDate()) and isnull(ppr.exp_date,dbo.HighDate()))
	and ppr.campaign_id is null

declare CurCam cursor for
select
	cam.campaign_id
from campaign_item_mst cam
where	cam.item = @PItem
open CurCam
fetch next from CurCam 
into
	@Campaign
while @@FETCH_STATUS = 0
begin
	insert into @ttProm(
		promotion_code
	,	description)
	select
		ppr.promotion_code, ppr.description
	from price_promotion_mst ppr
	where ppr.campaign_id = @Campaign
	fetch next from CurCam 
	into
		@Campaign
end
close CurCam
deallocate CurCam

select 
	promotion_code
,	description
from @ttProm
where promotion_code <> '' or promotion_code is not null

RETURN @Severity

go
