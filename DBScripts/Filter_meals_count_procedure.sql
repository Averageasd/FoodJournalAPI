DROP PROCEDURE IF EXISTS Filter_Meals_Count_Proc;
GO

CREATE OR ALTER PROCEDURE Filter_Meals_Count_Proc
@MealName VARCHAR(MAX) = NULL ,
@MealType VARCHAR(20) = NULL ,
@FoodName VARCHAR(50) = NULL ,
@FoodType VARCHAR(30) = NULL ,
@SortColumn VARCHAR(50) = 'AddDate',
@SortOrder VARCHAR(5) = 'ASC',
@CurPage INT OUTPUT,
@PageSize INT,
@FilterMealCount INT OUTPUT
AS 
	BEGIN
		DECLARE @dynamicMealFilterCountSql NVARCHAR(MAX);
		DECLARE @MealFilterRecordsSql NVARCHAR(MAX);
		DECLARE @GetMealFilterRecordsSql NVARCHAR(MAX);
		DECLARE @filterAppliedPerFood BIT = 0;
		DECLARE @SortColumnName NVARCHAR(MAX);
		
		SET @FilterMealCount = (
			SELECT COUNT(DISTINCT m.MealID) 
			FROM [dbo].Meal m LEFT JOIN [dbo].FoodMeal fm 
			ON m.MealID = fm.MealID LEFT JOIN [dbo].Food f 
			ON fm.FoodID = f.FoodID WHERE 1=1
			AND (
				CASE
					WHEN @FoodName IS NOT NULL THEN 
						CASE 
							WHEN LOWER(CAST(f.FoodName AS VARCHAR)) 
							LIKE LOWER(CAST(@FoodName AS VARCHAR)) + '%' THEN 1 
							ELSE 0
						END
					ELSE 1
			END) = 1
			AND (
				CASE
					WHEN @FoodType IS NOT NULL THEN 
						CASE 
							WHEN LOWER(CAST(f.FoodType AS VARCHAR)) 
							= LOWER(CAST(@FoodType AS VARCHAR)) THEN 1 
							ELSE 0
						END
					ELSE 1
			END) = 1
			AND (
				CASE
					WHEN @MealName IS NOT NULL THEN 
						CASE 
							WHEN LOWER(CAST(m.MealName AS VARCHAR)) 
							LIKE LOWER(CAST(@MealName AS VARCHAR)) + '%' THEN 1 
							ELSE 0
						END
					ELSE 1
			END) = 1
			AND (
				CASE
					WHEN @MealType IS NOT NULL THEN 
						CASE 
							WHEN LOWER(CAST(m.MealType AS VARCHAR)) 
							= LOWER(CAST(@MealType AS VARCHAR)) THEN 1 
							ELSE 0
						END
					ELSE 1
			END) = 1
		)

		BEGIN
			DROP TABLE IF EXISTS #tmpResultMeals;
			CREATE TABLE #tmpResultMeals (
				MealID UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY,
				MealName TEXT NOT NULL,
				MealType VARCHAR(20) NOT NULL,
				FoodCount INT,
				MealAddedDate NVARCHAR(50),	
			)
		END

		BEGIN
			DECLARE @SkippedItems INT = (@PageSize * @CurPage)
			DECLARE @FetchedRows INT
			IF @SkippedItems >= @FilterMealCount
			BEGIN
				SET @SkippedItems = @FilterMealCount
			END

			BEGIN 
				IF @SkippedItems + @PageSize > @FilterMealCount	
				BEGIN
					SET @FetchedRows = @FilterMealCount - @SkippedItems
					IF @FetchedRows = 0
					BEGIN
						SET @CurPage = 0
						SET @FetchedRows = @PageSize
						SET @SkippedItems = 0
					END
				END
				ELSE
				BEGIN
					SET @FetchedRows = @PageSize
				END
			END
		END


		INSERT INTO #tmpResultMeals 
		SELECT m.MealID, 
		CAST(m.MealName AS VARCHAR), 
		m.MealType, 
		(
			SELECT COUNT(sf.FoodID) 
			AS foodCount 
			FROM [dbo].Meal sm 
			LEFT JOIN [dbo].FoodMeal sfm ON sm.MealID = sfm.MealID
			LEFT JOIN [dbo].Food sf ON sfm.FoodID = sf.FoodID
			WHERE sm.MealID = m.MealID
			GROUP BY sm.MealID
		) AS foodCount, 
		FORMAT(CAST(m.MealAddedDate AS DATETIME2), 'yyyy-MM-dd HH:mm') 
		FROM [dbo].Meal m 
		LEFT JOIN [dbo].FoodMeal fm ON m.MealID = fm.MealID 
		LEFT JOIN [dbo].Food f ON fm.FoodID = f.FoodID WHERE 1=1
		AND (
		CASE
		WHEN @FoodName IS NOT NULL THEN 
			CASE 
				WHEN LOWER(CAST(f.FoodName AS VARCHAR)) 
				LIKE LOWER(CAST(@FoodName AS VARCHAR)) + '%' THEN 1 
				ELSE 0
			END
		ELSE 1
		END) = 1
		AND (
			CASE
				WHEN @FoodType IS NOT NULL THEN 
					CASE 
						WHEN LOWER(CAST(f.FoodType AS VARCHAR)) 
						= LOWER(CAST(@FoodType AS VARCHAR)) THEN 1 
						ELSE 0
					END
				ELSE 1
		END) = 1
		AND (
			CASE
				WHEN @MealName IS NOT NULL THEN 
					CASE 
						WHEN LOWER(CAST(m.MealName AS VARCHAR)) 
						LIKE LOWER(CAST(@MealName AS VARCHAR)) + '%' THEN 1 
						ELSE 0
					END
				ELSE 1
		END) = 1
		AND (
			CASE
				WHEN @MealType IS NOT NULL THEN 
					CASE 
						WHEN LOWER(CAST(m.MealType AS VARCHAR)) 
						= LOWER(CAST(@MealType AS VARCHAR)) THEN 1 
						ELSE 0
					END
				ELSE 1
		END) = 1
		GROUP BY m.MealID, 
		CAST(m.MealName AS VARCHAR), 
		m.MealType, 
		FORMAT(CAST(m.MealAddedDate AS DATETIME2), 'yyyy-MM-dd HH:mm') 

		ORDER BY FORMAT(CAST(m.MealAddedDate AS DATETIME2), 'yyyy-MM-dd HH:mm')  ASC OFFSET @SkippedItems ROWS FETCH NEXT @FetchedRows ROWS ONLY;

		SELECT * FROM #tmpResultMeals t
		ORDER BY 
			CASE WHEN @SortColumn = 'MealName' AND @SortOrder = 'DESC' THEN CAST(MealName AS VARCHAR) END DESC,
			CASE WHEN @SortColumn = 'MealName' AND @SortOrder = 'ASC' THEN CAST(MealName AS VARCHAR) END ASC,
			CASE WHEN @SortColumn = 'MealType' AND @SortOrder = 'DESC' THEN MealType END DESC,
			CASE WHEN @SortColumn = 'MealType' AND @SortOrder = 'ASC' THEN MealType END ASC,
			CASE WHEN @SortColumn = 'FoodCount' AND @SortOrder = 'DESC' THEN FoodCount END DESC,
			CASE WHEN @SortColumn = 'FoodCount' AND @SortOrder = 'ASC' THEN FoodCount END ASC,
			CASE WHEN @SortColumn = 'AddDate' AND @SortOrder = 'DESC' THEN  MealAddedDate END DESC,
			CASE WHEN @SortColumn = 'AddDate' AND @SortOrder = 'ASC' THEN MealAddedDate END ASC

	END
GO

DECLARE @FilterCount INT
DECLARE @CurPage INT = 2
EXEC Filter_Meals_Count_Proc NULL , NULL, NULL, NULL ,'MealName', 'DESC', @CurPage OUTPUT, 5 , @FilterCount OUTPUT;
