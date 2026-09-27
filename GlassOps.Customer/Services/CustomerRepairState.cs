using GlassOps.Customer.Models;

namespace GlassOps.Customer.Services;

public sealed class CustomerRepairState
{
    private readonly CustomerApiService _api;

    public CustomerRepairState(CustomerApiService api)
    {
        _api = api;
    }

    public CustomerRepair? CurrentRepair { get; private set; }

    public async Task<CustomerRepair?> GetAsync(bool forceRefresh = false)
    {
        if (CurrentRepair is not null && !forceRefresh)
            return CurrentRepair;

        CurrentRepair = await _api.GetCurrentRepairAsync();
        return CurrentRepair;
    }

    public void Clear() => CurrentRepair = null;
}
