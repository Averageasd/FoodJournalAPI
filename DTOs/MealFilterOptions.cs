namespace FoodJournalAPI.DTOs
{
    public class MealFilterOptions
    {
        public string? MealName { get; set; } = null;
        
        public string? MealType { get; set; } = null;
        
        public string? FoodName { get; set; } = null;  
        
        public string? FoodType { get; set; } = null;
        
        public string SortColumn { get; set; } = "AddDate";

        public string SortOrder { get; set; } = "ASC";
        
        public int Page { get; set; } = 0;
        public int PageSize { get; set; } = 10;

    }
}
