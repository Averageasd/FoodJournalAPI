DELETE FROM [dbo].FoodMeal;
DELETE FROM [dbo].Meal;
DELETE FROM [dbo].Food;

BEGIN TRY
	DECLARE @SampleMealId UNIQUEIDENTIFIER;
	DECLARE @Food1Id UNIQUEIDENTIFIER;
	DECLARE @Food2Id UNIQUEIDENTIFIER;
	DECLARE @Food3Id UNIQUEIDENTIFIER;
	DECLARE @NewMealID UNIQUEIDENTIFIER;
	BEGIN TRANSACTION
		BEGIN
			INSERT INTO [dbo].Food(FoodName, FoodType) VALUES('Chicken', 'Regular')
			INSERT INTO [dbo].Food(FoodName, FoodType) VALUES('Fish', 'Regular')
			INSERT INTO [dbo].Food(FoodName, FoodType) VALUES('Carrot', 'Regular')	
			EXEC [dbo].Insert_Meal_Proc 'Meal 1','Lunch', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 3','Lunch', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 5','Lunch', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 7','Snack', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 12','Snack', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 61','Snack', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Fantastic Meal','BreakFast', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Healthy Meal','BreakFast', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 3','BreakFast', @NewMealID OUTPUT
			EXEC [dbo].Insert_Meal_Proc 'Meal 3','BreakFast', @NewMealID OUTPUT
			SET @SampleMealId = (SELECT MealID FROM [dbo].Meal m WHERE CAST(m.MealName AS VARCHAR(MAX)) = 'Meal 1');
			SET @Food1Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Chicken'); 
			SET @Food2Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Fish'); 
			SET @Food3Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Carrot'); 
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food1Id, 1);
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food2Id, 2);
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food3Id, 3);
			SET @SampleMealId = (SELECT MealID FROM [dbo].Meal m WHERE CAST(m.MealName AS VARCHAR(MAX)) = 'Meal 3');
			SET @Food1Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Chicken'); 
			SET @Food2Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Fish');  
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food1Id, 1);
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food2Id, 2);
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food3Id, 3);
			SET @SampleMealId = (SELECT MealID FROM [dbo].Meal m WHERE CAST(m.MealName AS VARCHAR(MAX)) = 'Meal 5');
			SET @Food1Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Chicken'); 
			SET @Food2Id = (SELECT FoodID FROM [dbo].Food f WHERE f.FoodName = 'Fish');  
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food1Id, 1);
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food2Id, 2);
			INSERT INTO [dbo].FoodMeal (MealID, FoodID, FoodQuantity) VALUES (@SampleMealId, @Food3Id, 3);
		END
	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	BEGIN 
		ROLLBACK TRANSACTION;
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
GO


