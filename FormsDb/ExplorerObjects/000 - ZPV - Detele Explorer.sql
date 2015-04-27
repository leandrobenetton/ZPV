DEclare
@TopObjectId	int


DECLARE @TmpExplorer TABLE
(
 ObjectId	int
,ObjectName	nvarchar(255)
)

Declare
@CurrentCount int
,@TotalCount	int

SET @CurrentCount = 0
SET @TotalCount = 0

SELECT @TopObjectId = objectid 
	FROM ExplorerObjects
		WHERE ObjectName = 'xZPV'
		And ObjectType = 'F'


INSERT INTO @TmpExplorer( ObjectId, ObjectName	)
		SELECT objectid, objectname from ExplorerObjects 
			Where ObjectId = @TopObjectId

SELECT  @TotalCount = COUNT(*) FROM @TmpExplorer

WHILE @CurrentCount <> @TotalCount
BEGIN
	SET @CurrentCount = @TotalCount

	INSERT INTO @TmpExplorer( ObjectId, ObjectName	)
			SELECT explorer.objectid, explorer.objectname from ExplorerObjects explorer
				INNER JOIN  @TmpExplorer tmp ON tmp.ObjectId = explorer.ParentFolderId 
					Where NOT EXISTS(SELECT 1 from @TmpExplorer tmp2 where tmp2.ObjectId = explorer.ObjectId  )

	SELECT  @TotalCount = COUNT(*) FROM @TmpExplorer
END

DELETE ExplorerObjects
FROM @TmpExplorer tmp
INNER JOIN ExplorerObjects  ON tmp.ObjectId = ExplorerObjects.ObjectId 