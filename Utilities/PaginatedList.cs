namespace FoodJournalAPI.Utilities
{
    public class PaginatedList<T>
    {
        public List<T> Items { get; set; }
        public int CurrentPage { get; set; }
        public int TotalPages { get; set; }
        public int PageSize { get; set; }
        public int TotalCount { get; set; }
        public bool HasNext {  get; set; }
        public bool HasPrevious { get; set; }


        public PaginatedList(List<T> items, int currentPage, int totalCount, int pageSize)
        {
            Items = items;
            CurrentPage = currentPage;
            TotalCount = totalCount;
            TotalPages = (int)Math.Ceiling((double)TotalCount / pageSize); 
            PageSize = pageSize <= items.Count ? pageSize : items.Count;
            HasNext = CurrentPage < TotalPages - 1;
            HasPrevious = CurrentPage >= 1;
        }
        
        public static async Task<PaginatedList<T>> CreatePaginatedList(List<T> items, int currentPage, int totalCount, int pageSize)
        {
            return new PaginatedList<T>(items, currentPage, totalCount, pageSize);
        }
    }
}
