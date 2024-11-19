using FoodJournalAPI.Models;

namespace FoodJournalAPI.Validations;

public class FoodValidation
{
    public FoodValidation() { }
    
    public bool IsFoodTypeValid(string mealType)
    {
        return mealType.Equals(FoodTypeConstants.Junk, StringComparison.OrdinalIgnoreCase)
               || mealType.Equals(FoodTypeConstants.Regular, StringComparison.OrdinalIgnoreCase);
    }
}