using System.ComponentModel;

namespace GlassOps.Customer.Models;

public enum ContractStatus
{
    Reported = 0,
    SurveyBooked = 1,
    SurveyCompleted = 2,
    FittingBooked = 3,
    FittingCompleted = 4,
    Cancelled = 5,

    Estimating = 6,
    EstimateCompleted = 7,
    AwaitingAuthorisation = 8,
    Authorised = 9,

    // Future internal statuses
    PartsOrdered = 10,
    PartsReceived = 11,
    AwaitingInspection = 12
}

public class CustomerRepair
{
    public int ContractId { get; set; }
    public Guid Guid { get; set; } = Guid.NewGuid();
    public string Reference { get; set; } = "";
    public string CustomerName { get; set; } = "";
    public string AddressLine1 { get; set; } = "";
    public string Town { get; set; } = "";
    public string Postcode { get; set; } = "";
    public string DamageDescription { get; set; } = "";
    public string CauseOfDamage { get; set; } = "";
    public ContractStatus Status { get; set; }
    public string StatusTitle { get; set; } = "";
    public string StatusDescription { get; set; } = "";
    public string StatusEta { get; set; } = "";
    public CustomerAppointment? NextAppointment { get; set; }
    public List<CustomerRepairItem> Items { get; set; } = [];
    public List<CustomerRepairUpdate> Updates { get; set; } = [];
    public List<CustomerPhoto> Photos { get; set; } = [];
}

public class CustomerAppointment
{
    public string Type { get; set; } = "";
    public DateTime DateTime { get; set; }
    public string EngineerName { get; set; } = "";
    public string Notes { get; set; } = "";
}

public class CustomerRepairItem
{
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public string Location { get; set; } = "";
}

public class CustomerRepairUpdate
{
    public DateTime DateTime { get; set; }
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public bool IsCurrent { get; set; }
}

public class CustomerPhoto
{
    public string Url { get; set; } = "";
    public string Title { get; set; } = "";
    public string Description { get; set; } = "";
    public string Category { get; set; } = "";
    public DateTime DateTime { get; set; }
}


public class CustomerAccountDTO
{
    public string Name { get; set; } = "";
    public string Email { get; set; } = "";

    public string AddressLine1 { get; set; } = "";
    public string AddressLine2 { get; set; } = "";
    public string Town { get; set; } = "";
    public string Postcode { get; set; } = "";

    public string Phone { get; set; } = "";
}
