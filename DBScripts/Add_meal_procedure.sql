DROP PROCEDURE IF EXISTS Insert_Meal_Proc
GO

CREATE PROCEDURE Insert_Meal_Proc
     @MealName VARCHAR(50) ,
     @MealType VARCHAR(20) ,
	 @NewMealID UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
	DECLARE @MealWithNameCount INT;
	DECLARE @NewMealName VARCHAR(50) = @MealName;
	BEGIN TRY
		BEGIN TRANSACTION
			BEGIN
				SET @MealWithNameCount = (SELECT COUNT(m.MealID) FROM [dbo].Meal m WHERE m.MealName LIKE @MealName + '%');
				IF @MealWithNameCount >= 1
					BEGIN
						SET @NewMealName = @NewMealName + '(' + CAST(@MealWithNameCount AS VARCHAR) + ')'
					END
			END
			
			DECLARE @MealIDOutput table ( MealID UNIQUEIDENTIFIER )
			INSERT INTO [dbo].Meal(MealID, MealName, MealType, MealAddedDate)
			OUTPUT INSERTED.MealID INTO @MealIDOutput
			VALUES (NEWID(), @NewMealName, @MealType, CAST(GETDATE() AS datetime2(0))) 

			SET @NewMealID = (SELECT MealID FROM @MealIDOutput)
			
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		BEGIN 
			ROLLBACK TRANSACTION
		END
		DECLARE @ErrorMessage NVARCHAR(30);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SET @ErrorMessage = ERROR_MESSAGE();
		SET @ErrorSeverity = ERROR_SEVERITY();
		SET @ErrorState = ERROR_STATE();

		PRINT 'Error Occurred: ' + @ErrorMessage;
		PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS NVARCHAR);
		PRINT 'Error State: ' + CAST(@ErrorState AS NVARCHAR);
	END CATCH
END
GO
	
DECLARE @NewMealID UNIQUEIDENTIFIER;

EXEC Insert_Meal_Proc 
'Cheat meal after workout', 
'Snack',
@NewMealID OUTPUT

EXEC Insert_Meal_Proc 
'Cheat meal after workout', 
'Snack',
@NewMealID OUTPUT

