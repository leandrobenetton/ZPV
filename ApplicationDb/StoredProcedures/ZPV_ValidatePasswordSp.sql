/****** Object:  StoredProcedure [dbo].[ZPV_ValidatePasswordSp]    Script Date: 13/04/2015 15:33:19 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[ZPV_ValidatePasswordSp]') AND type in (N'P', N'PC'))	
DROP PROCEDURE [dbo].[ZPV_ValidatePasswordSp]
GO

/****** Object:  StoredProcedure [dbo].[ZPV_ValidatePasswordSp]    Script Date: 13/04/2015 15:33:19 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ZPV_ValidatePasswordSp] (
	@UserName	UserNameType,
	@UserPassword	EncryptedClientPasswordType,
	@Infobar	InfobarType   OUTPUT
)
AS

   -- Check for existence of Generic External Touch Point routine (this section was generated by SpETPCodeSp and inserted by CallETPs.exe):
   IF OBJECT_ID(N'dbo.EXTGEN_ZPV_ValidatePasswordSp') IS NOT NULL
   BEGIN
      DECLARE @EXTGEN_SpName sysname
      SET @EXTGEN_SpName = N'dbo.EXTGEN_ZPV_ValidatePasswordSp'
      -- Invoke the ETP routine, passing in (and out) this routine's parameters:
      DECLARE @EXTGEN_Severity int
      EXEC @EXTGEN_Severity = @EXTGEN_SpName
         @UserName
	  ,	 @UserPassword
	  ,	 @Infobar OUTPUT
 
      -- ETP routine can RETURN 1 to signal that the remainder of this standard routine should now proceed:
      IF @EXTGEN_Severity <> 1
         RETURN @EXTGEN_Severity
   END
   -- End of Generic External Touch Point code.

DECLARE
	@Severity		INT
,	@Password		EncryptedClientPasswordType		

SET @Severity = 0
SET @Infobar  = NULL

BEGIN
	EXEC	@Severity = [dbo].[GetUserPasswordSp]
			@Username = sa,
			@Password = @Password OUTPUT

	IF @Password <> @UserPassword 
	BEGIN
		SET @Severity = 16
		SET @Infobar = 'Clave de Usuario Incorrecta'
		return @Severity
	END
END

return @severity

GO
