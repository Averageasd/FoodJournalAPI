using System.ComponentModel.DataAnnotations;

namespace FoodJournalAPI.Models;

public class FoodModel
{
    public Guid? FoodID { get; set; }  
    [Required(ErrorMessage = "Food name is required")]
    public string? FoodName { get; set; }
    [Required(ErrorMessage = "Food type is required")]
    public string? FoodType { get; set; }

    public int? Quantity { get; set; }
}

public class FoodTypeConstants
{
    public static readonly string Regular = "Regular";
    public static readonly string Junk = "Junk";
}