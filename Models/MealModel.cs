namespace FoodJournalAPI.Models
{
    public class MealModel
    {
        public Guid? MealID { get; set; }

        public string? MealName { get; set; }

        public string? MealType { get; set; }

        public DateTime? MealAddedDate { get; set; }
    }
}

public class MealTypeConstants
{
    public static readonly string BreakFast = "Breakfast";
    public static readonly string Lunch = "Lunch";
    public static readonly string Dinner = "Dinner";
    public static readonly string Snack = "Snack";
}
