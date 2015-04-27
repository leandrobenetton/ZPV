/****** Object:  UserDefinedFunction [dbo].[ZRT_ReplaceCharSp]    Script Date: 10/12/2014 15:20:40 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ReplaceCharSp]') AND type in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ZPV_ReplaceCharSp]
GO

/****** Object:  UserDefinedFunction [dbo].[ZPV_ReplaceCharSp]    Script Date: 10/12/2014 15:20:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/* $Header: /ApplicationDB/Stored Procedures/ZPV_ReplaceCharSp 1      */
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

/* $Archive: /ApplicationDB/Stored Procedures/ZPV_ReplaceCharSp $
 *
 * SL9.00.10 lbenetton Sun Nov 1 13:00:00 2014
 * Final Version 1.0.0
 * 
 * $NoKeywords: $
 */

CREATE FUNCTION [dbo].[ZPV_ReplaceCharSp](
	@Cadena  varchar(255))
	
	RETURNS varchar(255)
AS 

BEGIN
	DECLARE @Caracteres varchar(255)
	SET @Caracteres = '-;,./¥()&\Ò—°!?#:$%[_*@·ÈÌÛ˙{} +=abcdefghijklmnopqrstvwxyzABCDEFGHIJKLMOPQRSTWXYZ'

	while @Cadena like '%[' + @Caracteres + ']%'
	begin
		select @Cadena = REPLACE(@Cadena,SUBSTRING(@Cadena,patindex('%[' + @Caracteres + ']%',@Cadena),1),'')
	end
	
	RETURN @Cadena
END

GO

