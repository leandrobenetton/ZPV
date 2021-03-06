--SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name like 'Zpv%'

IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZpvFiscalNameType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZpvFiscalNameType]
	FROM [varchar](100)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZpvStatType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZpvStatType]
	FROM [varchar](30)
	NULL
GO
IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZpvCuitType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZpvCuitType]
	FROM [varchar](13)
	NULL
GO

IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZpvLogStatType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZpvLogStatType]
	FROM [varchar](10)
	NULL
GO

IF NOT (EXISTS(SELECT * FROM sys.types st JOIN sys.schemas ss ON st.schema_id = ss.schema_id WHERE st.name = N'ZpvClearingType' AND ss.name = N'dbo'))
CREATE TYPE [dbo].[ZpvClearingType]
	FROM [varchar](10)
	NULL
GO


