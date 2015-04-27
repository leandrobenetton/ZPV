/****** Object:  StoredProcedure [dbo].[ZPV_CLM_DrawersSp]    Script Date: 18/01/2015 03:59:32 p.m. ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_CLM_DrawersSp]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[ZPV_CLM_DrawersSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_CLM_DrawersSp]    Script Date: 18/01/2015 03:59:32 p.m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/* $Header: /ApplicationDB/Stored Procedures/ZPV_CLM_DrawersSp.sp 7     5/31/13 1:25a exia $ */
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

CREATE PROCEDURE [dbo].[ZPV_CLM_DrawersSp](
  @pUsername      UserNameType = NULL
, @pPOS		      varchar(20)  = NULL
, @Infobar      InfobarType OUTPUT
) AS

DECLARE 
	@Site SiteType
	
SELECT @Site = site FROM site
EXEC [dbo].[SetSiteSp] @Site, @Infobar OUTPUT

DECLARE	
	@Severity		INT

SET @Severity = 0
SET @Infobar = NULL

select
	drwp.drawer
,	drwp.pos
,	pos.description
from zpv_drawer_pos drwp
inner join zpv_co_pos pos on pos.pos_code = drwp.pos
inner join zpv_drawer drw on drw.drawer = drwp.drawer and drw.closed = 1
where	drwp.pos = @pPOS

RETURN @Severity

go
