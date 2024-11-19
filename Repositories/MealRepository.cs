using System.Data;
using Dapper;
using FoodJournalAPI.Contracts;
using FoodJournalAPI.DapperContext;
using FoodJournalAPI.DTOs;
using FoodJournalAPI.Utilities;
using System.Data.Common;

namespace FoodJournalAPI.Repositories
{
    public class MealRepository : IMealRepository
    {

        private readonly Context _context;

        public MealRepository(Context dapperContext)
        {
            _context = dapperContext;
        }
        
        public async Task<PaginatedList<MealResponseDTO>> GetMeals(MealFilterOptions mealFilterOptions)
        {
            try
            {
                int allMealCount;
                int calculatedCurPage;
                
                var dynamicParameters = new DynamicParameters();
                dynamicParameters.Add("@MealName", mealFilterOptions.MealName, DbType.String);
                dynamicParameters.Add("@MealType", mealFilterOptions.MealType, DbType.String);
                dynamicParameters.Add("@FoodName", mealFilterOptions.FoodName, DbType.String);
                dynamicParameters.Add("@FoodType", mealFilterOptions.FoodType, DbType.String);
                dynamicParameters.Add("@SortColumn", mealFilterOptions.SortColumn, DbType.String);
                dynamicParameters.Add("@SortOrder", mealFilterOptions.SortOrder, DbType.String);
                dynamicParameters.Add("@CurPage", mealFilterOptions.Page, DbType.Int32, direction: ParameterDirection.InputOutput);
                dynamicParameters.Add("@PageSize", mealFilterOptions.PageSize, DbType.Int32);
                dynamicParameters.Add("@FilterMealCount", DbType.Int32, direction: ParameterDirection.Output);
                IEnumerable<MealResponseDTO> paginatedMeals;
                using (var connection = _context.GetDbConnection())
                {
                    paginatedMeals = await connection.QueryAsync<MealResponseDTO>("Filter_Meals_Count_Proc", dynamicParameters, commandType: CommandType.StoredProcedure);
                    allMealCount = dynamicParameters.Get<int>("@FilterMealCount");
                    calculatedCurPage = dynamicParameters.Get<int>("@CurPage");
                }

                return await PaginatedList<MealResponseDTO>.CreatePaginatedList(paginatedMeals.ToList(), calculatedCurPage,
                    allMealCount, mealFilterOptions.PageSize);
            }
            catch (DbException exception) 
            {
                throw new Exception(exception.Message);
            }
        }

        public async Task<MealResponseDTO> GetMeal(Guid mealId)
        {
            try
            {
                var singleMealQuery = 
                    @"SELECT 
                       m.MealID, 
                       CAST(m.MealName AS VARCHAR), 
                       m.MealType, 
                       m.MealAddedDate,
                       COUNT(f.FoodID) AS foodCount
                       FROM MEAL m LEFT JOIN FoodMeal fm ON m.MealID = fm.MealID LEFT JOIN Food f ON fm.FoodID = f.FoodID WHERE m.MealID = @MealId
                       GROUP BY m.MealID, CAST(m.MealName AS VARCHAR), m.MealType, m.MealAddedDate" ;

                using (var connection = _context.GetDbConnection())
                {
                    MealResponseDTO? meal = await connection
                        .QueryFirstOrDefaultAsync<MealResponseDTO>(
                        singleMealQuery, 
                        new { mealId });
                    return meal!;
                }
            }
            catch (DbException e)
            {
                throw new Exception(e.Message);
            }
        }
        
        public async Task DeleteMeal(Guid mealId)
        {
            try
            {
                var singleMealQuery = "DELETE FROM Meal WHERE MealID = @MealId";
                using (var connection = _context.GetDbConnection())
                {
                    connection.Open();
                    using (var transaction = connection.BeginTransaction())
                    {
                        try
                        {
                            await connection
                                .ExecuteAsync(
                                    singleMealQuery,
                                    new { MealId = mealId },
                                    transaction
                                );
                            transaction.Commit();
                        }
                        catch (DbException exception)
                        {
                            transaction.Rollback();
                            throw new Exception(exception.Message);
                           
                        }
                    }
                }
            }
            catch (DbException exception)
            {
                throw new Exception(exception.Message);
            }
        }
        
        public async Task<Guid> AddMeal(AddNewMealRequestDTO mealRequest)
        {
            try
            {
                var parameters = new DynamicParameters();
                parameters.Add("@MealName", mealRequest.MealName, DbType.String);
                parameters.Add("@MealType", mealRequest.MealType, DbType.String);
                parameters.Add("@NewMealID", dbType: DbType.Guid, direction: ParameterDirection.Output);
                using (var connection = _context.GetDbConnection())
                {
                    await connection.ExecuteAsync("Insert_Meal_Proc", parameters,
                        commandType: CommandType.StoredProcedure);
                    var newMealId = parameters.Get<Guid>("@NewMealID");
                    return newMealId;
                }
            }
            catch (DbException exception)
            {
                throw new Exception(exception.Message);
            }
        }

        public Task<Guid> UpdateMeal(UpdateMealRequestDTO updateMealRequestDto)
        {
            throw new NotImplementedException();
        }
    }
}
