using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace FoodJournalAPI.Utilities;

public class ModelStateErrorMessageGenerator
{
    public static string ModelStateErrorMessage(ModelStateDictionary modelStateDictionary)
    {
        return string.
            Join("\n", modelStateDictionary
                .Values
                .SelectMany(model => model.Errors)
                .Select(e => e.ErrorMessage));
    }
}