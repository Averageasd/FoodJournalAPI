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
		SET @dynamicMealFilterCountSql = N'SELECT @FilterMealCount = COUNT(DISTINCT m.MealID) FROM [dbo].Meal m LEFT JOIN [dbo].FoodMeal fm ON m.MealID = fm.MealID LEFT JOIN [dbo].Food f ON fm.FoodID = f.FoodID WHERE 1=1';
		SET @MealFilterRecordsSql = N'INSERT INTO #tmpResultMeals SELECT m.MealID, CAST(m.MealName AS VARCHAR), m.MealType, COUNT(f.FoodID) as foodCount, FORMAT(CAST(m.MealAddedDate AS DATETIME2), ''yyyy-MM-dd HH:mm'') FROM [dbo].Meal m LEFT JOIN [dbo].FoodMeal fm ON m.MealID = fm.MealID LEFT JOIN [dbo].Food f ON fm.FoodID = f.FoodID WHERE 1=1';
		SET @GetMealFilterRecordsSql = N'SELECT * FROM #tmpResultMeals m ORDER BY';
		IF @FoodName IS NOT NULL OR @FoodType IS NOT NULL
			BEGIN
				SET @filterAppliedPerFood = 1;
				IF @FoodName IS NOT NULL
					BEGIN
						SET @dynamicMealFilterCountSql += ' AND LOWER(f.FoodName) LIKE ''' + LOWER(@FoodName) + '%''';
						SET @MealFilterRecordsSql += ' AND LOWER(f.FoodName) LIKE ''' + LOWER(@FoodName) + '%''';
					END
				IF @FoodType IS NOT NULL
					BEGIN
						SET @dynamicMealFilterCountSql += ' AND LOWER(f.FoodType) = LOWER(@FoodType)';
						SET @MealFilterRecordsSql += ' AND LOWER(f.FoodType) = LOWER(@FoodType)';
					END
			END
		IF @MealName IS NOT NULL OR @MealType IS NOT NULL
		BEGIN
			IF @MealName IS NOT NULL
			BEGIN
				SET @dynamicMealFilterCountSql += ' AND LOWER(CAST(m.MealName AS VARCHAR)) LIKE ''' + LOWER(@MealName) + '%''';
				SET @MealFilterRecordsSql += ' AND LOWER(CAST(m.MealName AS VARCHAR)) LIKE ''' + LOWER(@MealName) + '%''';
			END
			IF @MealType IS NOT NULL
			BEGIN
				SET @dynamicMealFilterCountSql += ' AND LOWER(m.MealType) = LOWER(@MealType)';
				SET @MealFilterRecordsSql += ' AND LOWER(m.MealType) = LOWER(@MealType)';
			END
		END

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
		    SET @MealFilterRecordsSql += ' GROUP BY m.MealID, CAST(m.MealName AS VARCHAR), m.MealType, FORMAT(CAST(m.MealAddedDate AS DATETIME2), ''yyyy-MM-dd HH:mm'')';
			IF @SortColumn IS NULL
			BEGIN
				SET @SortColumn = 'AddDate'
			END
			IF @SortOrder IS NULL
			BEGIN
				SET @SortOrder = 'ASC'
			END

			IF @SortColumn = 'AddDate'
			BEGIN
				SET @GetMealFilterRecordsSql += ' m.MealAddedDate';
			END

			ELSE IF @SortColumn = 'MealName'
			BEGIN
				SET @GetMealFilterRecordsSql += ' CAST(m.MealName AS VARCHAR)';
			END

			ELSE IF @SortColumn = 'MealType'
			BEGIN
				SET @GetMealFilterRecordsSql += ' m.MealType';
			END

			ELSE IF @SortColumn = 'FoodCount'
			BEGIN
				SET @GetMealFilterRecordsSql += ' foodCount';
			END
		END
		BEGIN
			SET @GetMealFilterRecordsSql += ' ' + @SortOrder;
		END

		PRINT @MealFilterRecordsSql
		PRINT @dynamicMealFilterCountSql
		EXEC sp_executesql @dynamicMealFilterCountSql, 
        N'@MealName VARCHAR(MAX), @MealType VARCHAR(30), @FoodName VARCHAR(50), @FoodType VARCHAR(30), @FilterMealCount INT OUTPUT', 
        @MealName=@MealName, @MealType=@MealType, @FoodName= @FoodName, @FoodType=@FoodType, @FilterMealCount=@FilterMealCount OUTPUT;

		DECLARE @Offset INT
		BEGIN
			IF @PageSize IS NULL OR @PageSize <= 0
			BEGIN
				SET @PageSize = 10
			END

			--how many items we will skip (offset)
			DECLARE @ItemsToSkip INT = @CurPage * @PageSize
			SET @Offset = @ItemsToSkip

			--skip more items than total items in table
			--limit to only max items in table
			IF @Offset >= @FilterMealCount
			BEGIN
				SET @Offset = @FilterMealCount
			END

			--how many rows will we fetch
			DECLARE @FetchedRows INT

			--rows we skip + rows will wnat to fetch is larger than total number of rows
			IF @Offset + @PageSize > @FilterMealCount
			BEGIN
			--limit rows we want to fetch to remaining number of rows (page 1, total: 19, skip: 10)
			--so we only want to fetch 9 rows. 19 - offset = 19 - 10 = 9
				SET @FetchedRows = @FilterMealCount - @Offset
			END
			ELSE
			BEGIN
			-- fetch normally if we have enough rows
				SET @FetchedRows = @PageSize
			END

			IF @FetchedRows = 0
			BEGIN
			SET @CurPage = 0
			SET @FetchedRows = @PageSize
			SET @Offset = 0
			END
			SET @MealFilterRecordsSql += ' ORDER BY FORMAT(CAST(m.MealAddedDate AS DATETIME2), ''yyyy-MM-dd HH:mm'') OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY';

		END

		PRINT @CurPage

		EXEC sp_executesql  @MealFilterRecordsSql,
		N'@MealName VARCHAR(MAX), @MealType VARCHAR(30), @FoodName VARCHAR(50), @FoodType VARCHAR(30), @Offset INT, @PageSize INT',
		@MealName=@MealName, @MealType=@MealType, @FoodName=@FoodName, @FoodType=@FoodType, @Offset=@Offset, @PageSize=@FetchedRows;

		EXEC sp_executesql  @GetMealFilterRecordsSql,
		N'@MealName VARCHAR(MAX), @MealType VARCHAR(30), @FoodName VARCHAR(50), @FoodType VARCHAR(30), @SortOrder VARCHAR(5), @Offset INT, @PageSize INT',
		@MealName=@MealName, @MealType=@MealType, @FoodName=@FoodName, @FoodType=@FoodType, @SortOrder=@SortOrder, @Offset=@Offset, @PageSize=@FetchedRows;
	END
GO

DECLARE @FilterCount INT
DECLARE @CurPage INT = 0
EXEC Filter_Meals_Count_Proc NULL, NULL, NULL, NULL, 'MealName', 'ASC', @CurPage OUTPUT, 1 , @FilterCount OUTPUT;
