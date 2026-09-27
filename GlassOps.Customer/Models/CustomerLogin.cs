namespace GlassOps.Customer.Models;

public class CustomerLoginRequest
{
    public string Reference { get; set; } = "";
    public string Email { get; set; } = "";
    public string Password { get; set; } = "";
}

public class CustomerLoginResult
{
    public string AuthenticationString { get; set; } = "";
    public int CustomerId { get; set; }
    public int ContractId { get; set; }
    public string CustomerName { get; set; } = "";
}

public class CustomerApiRequest
{
    public string AuthenticationString { get; set; } = "";
    public int ContractId { get; set; }
}