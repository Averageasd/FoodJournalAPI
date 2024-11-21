using Microsoft.Data.SqlClient;
using System.Data;

namespace FoodJournalAPI.DapperContext
{
    public class Context
    {
        private readonly IConfiguration _configuration;
        private readonly string _connectionString;

        public Context(IConfiguration configuration)
        {
            _configuration = configuration;
            _connectionString = _configuration.GetConnectionString("devConnection");
        }

        public virtual IDbConnection GetDbConnection()
        {
            return new SqlConnection(_connectionString);
        }
    }
}