namespace GlassOps.Customer.Services;

public sealed class CustomerSessionService
{
    private const string AuthenticationKey = "customer_authentication";
    private const string CustomerNameKey = "customer_name";
    private const string CustomerIdKey = "customer_id";

    private const string ContractIdKey = "customer_contract_id";

    public int ContractId { get; private set; }

    private bool _restored;

    public string AuthenticationString { get; private set; } = "";
    public string CustomerName { get; private set; } = "";
    public int CustomerId { get; private set; }

    public bool IsLoggedIn =>
        !string.IsNullOrWhiteSpace(AuthenticationString);

    public async Task RestoreAsync()
    {
        if (_restored)
            return;

        _restored = true;

        try
        {
            AuthenticationString =
                await SecureStorage.Default.GetAsync(AuthenticationKey) ?? "";

            CustomerName =
                await SecureStorage.Default.GetAsync(CustomerNameKey) ?? "";

            var customerIdText =
                await SecureStorage.Default.GetAsync(CustomerIdKey);

            CustomerId =
                int.TryParse(customerIdText, out var customerId)
                    ? customerId
                    : 0;

            var contractIdText =
                await SecureStorage.Default.GetAsync(ContractIdKey);

            ContractId =
                int.TryParse(contractIdText, out var contractId)
                    ? contractId
                    : 0;
        }
        catch
        {
            ClearInMemory();
        }
    }

    public async Task SetAsync(
        string authenticationString,
        int customerId,
        int contractId,
        string customerName)
    {
        AuthenticationString = authenticationString;
        CustomerId = customerId;
        ContractId = contractId;
        CustomerName = customerName;
        _restored = true;

        await SecureStorage.Default.SetAsync(
            AuthenticationKey,
            authenticationString);

        await SecureStorage.Default.SetAsync(
            CustomerIdKey,
            customerId.ToString());

        await SecureStorage.Default.SetAsync(
            ContractIdKey,
            contractId.ToString());

        await SecureStorage.Default.SetAsync(
            CustomerNameKey,
            customerName);
    }

    public void Logout()
    {
        SecureStorage.Default.Remove(AuthenticationKey);
        SecureStorage.Default.Remove(CustomerIdKey);
        SecureStorage.Default.Remove(CustomerNameKey);
        SecureStorage.Default.Remove(ContractIdKey);

        ClearInMemory();
        _restored = true;
    }

    private void ClearInMemory()
    {
        AuthenticationString = "";
        CustomerName = "";
        CustomerId = 0;
        ContractId = 0;
    }
}