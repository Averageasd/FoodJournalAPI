using FoodJournalAPI.DTOs;
using FoodJournalAPI.Models;
using FoodJournalAPI.Utilities;
using Microsoft.AspNetCore.Mvc;

namespace FoodJournalAPI.Contracts
{
    public interface IMealRepository
    {
        public Task<PaginatedList<MealResponseDTO>> GetMeals(MealFilterOptions mealFilterOptions);
        public Task<MealResponseDTO> GetMeal(Guid mealId);
        public Task DeleteMeal(Guid mealId);
        public Task AddMeal(AddNewMealRequestDTO addMealRequestDto);
        public Task UpdateMeal(UpdateMealRequestDTO updateMealRequestDto);
    }       
}
