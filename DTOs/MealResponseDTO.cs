using FoodJournalAPI.Models;

namespace FoodJournalAPI.DTOs;

public class MealResponseDTO
{
    public Guid? MealID { get; set; }

    public string? MealName { get; set; }

    public string? MealType { get; set; }

    public DateTime? MealAddedDate { get; set; }

    public int FoodCount { get; set; } = 0;

    public List<FoodModel> Foods { get; set; } = new List<FoodModel>();
}