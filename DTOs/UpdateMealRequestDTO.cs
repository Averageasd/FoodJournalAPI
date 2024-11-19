using System.ComponentModel.DataAnnotations;

namespace FoodJournalAPI.DTOs;

public class UpdateMealRequestDTO
{
    [Required(ErrorMessage = "Meal Name is required")]
    [MinLength(3, ErrorMessage = "Meal name has to be at least 3 characters")]
    [MaxLength(50, ErrorMessage = "Meal name cannot be longer than 50 characters")]
    public string? MealName { get; set; }

    [Required(ErrorMessage = "Meal Type is required")]
    [MinLength(5, ErrorMessage = "Meal name has to be at least 5 characters")]
    [MaxLength(20, ErrorMessage = "Meal name cannot be longer than 20 characters")]
    public string? MealType { get; set; }
    
    public int FoodCount { get; set; }
    
}