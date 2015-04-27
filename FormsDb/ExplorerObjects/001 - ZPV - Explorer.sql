-- Create ZRT Explorer Menu
Declare
 @xModuleId			int
,@xMainFolderId		int
,@xSubFolderId		int
,@ExplorerObjectsObjectName		nvarchar(255)		-- StringName
,@ExplorerObjectsObjectType		nchar(1)
,@ExplorerObjectsObjectTextData	nvarchar(255)		-- ZRT Form Name		
,@ExplorerObjectsParentFolderId	int

-- Get ZRT Folder
SET @ExplorerObjectsParentFolderId = NULL

SELECT @ExplorerObjectsParentFolderId = ObjectId
		FROM ExplorerObjects
			WHERE ObjectName = 'xZPV'
				AND ObjectType = 'F'
				AND ParentFolderId = -1

IF @ExplorerObjectsParentFolderId IS NULL
	BEGIN
		INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
									VALUES('xZPV', 'F', NULL, -1 )
		-- Get Main ZRT Folder Id
		SET @ExplorerObjectsParentFolderId	= @@IDENTITY
	END


	-- Create xCustomer Folder Structure 
	SET @xModuleId = NULL

	INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
								VALUES('xPointOfSale', 'F', NULL, @ExplorerObjectsParentFolderId )
		-- Get Module Folder Id
	SET @xModuleId	= @@IDENTITY


		-- xOrder Entry  
		INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
									VALUES('xOrderEntry', 'F', NULL, @xModuleId )

			-- Get Main Folder Id
		SET @xMainFolderId	= @@IDENTITY

			-- xOrder Entry / Reports
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xReports', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
				
			-- xOrder Entry / Activities
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xActivities', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
				
				
			-- xOrder Entry / Files 
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xFiles', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
				

				-- xOrder Entry / Files /
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_CoStat', 'R', 'ZPV_CoStat', @xSubFolderId )

				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fBillingTerms', 'R', 'BillingTerms', @xSubFolderId )
				
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fPricePromotionsandRebates', 'R', 'PricePromotionsandRebates', @xSubFolderId )
											
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_BankPayType', 'R', 'ZPV_BankPayType', @xSubFolderId )											
				
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_CoCodes', 'R', 'ZPV_CoCodes', @xSubFolderId )

				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_CoPos', 'R', 'ZPV_CoPos', @xSubFolderId )

				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_Parms', 'R', 'ZPV_Parms', @xSubFolderId )
											
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_PosEndUserType', 'R', 'ZPV_PosEndUserType', @xSubFolderId )
															
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_UserPos', 'R', 'ZPV_UserPos', @xSubFolderId )
											
						
			-- xGeneral / Queries 
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xQueries', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
			
			-- xOrder Entry /  
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fCustomerOrders', 'R', 'ZPV_CustomerOrdersPOS', @xMainFolderId )
			
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_ARPaymentOrderPOS', 'R', 'ZPV_ARPaymentOrderPOS', @xMainFolderId )
			
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_ARPaymentPOS', 'R', 'ZPV_ARPaymentPOS', @xMainFolderId )
			
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fCustomers', 'R', 'Customers', @xMainFolderId )

			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_CustomerCreditReview', 'R', 'ZPV_CustomerCreditReview', @xMainFolderId )
			
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_RetailHome', 'R', 'ZPV_RetailHome', @xMainFolderId )
			
			SET @xSubFolderId	= @@IDENTITY
			
-----------------------------------------------------------------------------------------------------------------------------------
		-- xDrawer Control
		INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
									VALUES('xDrawerControl', 'F', NULL, @xModuleId )
		
			-- Get Main Folder Id
		SET @xMainFolderId	= @@IDENTITY

			-- xOrder Entry / Reports
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xReports', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
				
			-- xOrder Entry / Activities
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xActivities', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
				
				-- xOrder Entry / Activities /
				--INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
				--							VALUES('fZRT_CoReleasesGeneration', 'R', 'ZRT_CoReleasesGeneration', @xSubFolderId )

			-- xOrder Entry / Files 
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xFiles', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
				

				-- xOrder Entry / Files /
				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_DrawerPtype', 'R', 'ZPV_DrawePtype', @xSubFolderId )

				INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
											VALUES('fZPV_DrawerPOS', 'R', 'ZPV_DrawerPOS', @xSubFolderId )
																						
			-- xGeneral / Queries 
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('xQueries', 'F', NULL, @xMainFolderId )
			SET @xSubFolderId	= @@IDENTITY
			
			-- xDrawer Control /  
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_DrawerControl', 'R', 'ZPV_DrawerControl', @xMainFolderId )
			
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_DrawerTranfer', 'R', 'ZPV_DrawerTranfer', @xMainFolderId )
			
			INSERT INTO ExplorerObjects(ObjectName, ObjectType, ObjectTextData, ParentFolderId)
										VALUES('fZPV_DrawerTrans', 'R', 'ZPV_DrawerTrans', @xMainFolderId )
			
			SET @xSubFolderId	= @@IDENTITY
			
				








