namespace FoodJournalAPI.Validations;

public class MealValidation
{
    public MealValidation() { }

    public bool IsMealTypeValid(string mealType)
    {
        return mealType.Equals(MealTypeConstants.Dinner, StringComparison.OrdinalIgnoreCase)
               || mealType.Equals(MealTypeConstants.Lunch, StringComparison.OrdinalIgnoreCase)
               || mealType.Equals(MealTypeConstants.BreakFast, StringComparison.OrdinalIgnoreCase)
               || mealType.Equals(MealTypeConstants.Snack , StringComparison.OrdinalIgnoreCase);
    }
}