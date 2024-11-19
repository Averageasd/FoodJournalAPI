using FoodJournalAPI.Contracts;
using FoodJournalAPI.DTOs;
using FoodJournalAPI.Utilities;
using FoodJournalAPI.Validations;
using Microsoft.AspNetCore.Mvc;

namespace FoodJournalAPI.Controllers
{
    [Route("api/meal")]
    public class MealController : Controller
    {
        private readonly IMealRepository _mealRepository;
        private readonly MealValidation _mealValidation;
        public MealController(IMealRepository mealRepository) {
            _mealRepository = mealRepository;
            _mealValidation = new MealValidation();
        }

        [HttpGet]
        [Route("meals")]
        public async Task<IActionResult> GetMeals(MealFilterOptions mealFilterOptions)
        {
            try
            {
                var meals = await _mealRepository.GetMeals(mealFilterOptions);
                return Ok(meals);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }
        
        [HttpGet]
        [Route("{mealId}")]
        public async Task<IActionResult> GetMeal(Guid mealId)
        {
            try
            {
                var meal = await _mealRepository.GetMeal(mealId);
                return Ok(meal);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }
        
        [HttpDelete]
        [Route("{mealId}")]
        public async Task<IActionResult> DeleteMeal(Guid mealId)
        {
            try
            {
                var existingMeal = await _mealRepository.GetMeal(mealId);
                if (existingMeal == null)
                {
                    return NotFound();
                }
                await _mealRepository.DeleteMeal(mealId);
                return NoContent();
            }
            catch (Exception e)
            {
                throw new Exception(e.Message);
            }
        }
        
        [HttpPost]
        [Route("addMeal")]
        public async Task<IActionResult> AddMeal([FromBody] AddNewMealRequestDTO addNewMealRequestDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelStateErrorMessageGenerator.ModelStateErrorMessage(ModelState));
            }

            if (!_mealValidation.IsMealTypeValid(addNewMealRequestDto.MealType!))
            {
                return BadRequest("Meal type must be Breakfast, Dinner, Lunch Or Snack!");
            }
            try
            {
                var newMealId = await _mealRepository.AddMeal(addNewMealRequestDto);
                var latestMeal = await _mealRepository.GetMeal(newMealId);
                return Ok(latestMeal);
            }
            catch (Exception e)
            {
                throw new Exception(e.Message); 
            }
        }
    }
}
