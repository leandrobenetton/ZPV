IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zwm_zip]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zwm_zip](
		[CreatedBy] [dbo].[UsernameType] NOT NULL,
		[UpdatedBy] [dbo].[UsernameType] NOT NULL,
		[CreateDate] [dbo].[CurrentDateType] NOT NULL,
		[RecordDate] [dbo].[CurrentDateType] NOT NULL,
		[RowPointer] [dbo].[RowPointerType] NOT NULL,
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL,
		[InWorkflow] [dbo].[FlagNyType] NOT NULL,
		[zip] [dbo].[PostalCodeType] NOT NULL,
		[route] [varchar](15) NULL,
		[distance] [dbo].[QtyUnitType] NULL,
	 CONSTRAINT [PK_zwm_zip] PRIMARY KEY NONCLUSTERED 
	(
		[zip] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
	 CONSTRAINT [IX_zwm_zip_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]


	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_UpdatedBy]  DEFAULT (suser_sname()) FOR [UpdatedBy]
	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_RowPointer]  DEFAULT (newid()) FOR [RowPointer]
	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_NoteExistsFlag]  DEFAULT ((0)) FOR [NoteExistsFlag]
	ALTER TABLE [dbo].[zwm_zip] ADD  CONSTRAINT [DF_zwm_zip_InWorkflow]  DEFAULT ((0)) FOR [InWorkflow]
END


IF NOT (EXISTS(SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[zwm_zip_addr]') AND type in (N'U')))
BEGIN
	CREATE TABLE [dbo].[zwm_zip_addr](
		[CreatedBy] [dbo].[UsernameType] NOT NULL,
		[UpdatedBy] [dbo].[UsernameType] NOT NULL,
		[CreateDate] [dbo].[CurrentDateType] NOT NULL,
		[RecordDate] [dbo].[CurrentDateType] NOT NULL,
		[RowPointer] [dbo].[RowPointerType] NOT NULL,
		[NoteExistsFlag] [dbo].[FlagNyType] NOT NULL,
		[InWorkflow] [dbo].[FlagNyType] NOT NULL,
		[zip] [dbo].[PostalCodeType] NOT NULL,
		[address] [dbo].[AddressType] NULL,
		[start_num] [numeric](8, 0) NULL,
		[end_num] [numeric](8, 0) NULL,
		[city] [dbo].[CityType] NULL,
		[state] [dbo].[StateType] NULL,
		[state_description] [dbo].[DescriptionType] NULL,
		[country] [dbo].[CountryType] NULL,
	 CONSTRAINT [IX_zwm_zip_addr_RowPointer] UNIQUE NONCLUSTERED 
	(
		[RowPointer] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 90) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_CreatedBy]  DEFAULT (suser_sname()) FOR [CreatedBy]
	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_UpdatedBy]  DEFAULT (suser_sname()) FOR [UpdatedBy]
	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_RecordDate]  DEFAULT (getdate()) FOR [RecordDate]
	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_RowPointer]  DEFAULT (newid()) FOR [RowPointer]
	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_NoteExistsFlag]  DEFAULT ((0)) FOR [NoteExistsFlag]
	ALTER TABLE [dbo].[zwm_zip_addr] ADD  CONSTRAINT [DF_zwm_zip_addr_InWorkflow]  DEFAULT ((0)) FOR [InWorkflow]
END
