namespace GlassOps.Customer.Models;

public enum TicketStatus
{
    Open = 0,
    AwaitingCustomer = 1,
    AwaitingOffice = 2,
    Closed = 3
}

public enum TicketMessageSender
{
    Customer = 0,
    HeadOffice = 1
}

public sealed class CustomerCreateTicketRequest
{
    public string AuthenticationString { get; set; } = "";
    public int ContractId { get; set; }
    public string Subject { get; set; } = "";
    public string Message { get; set; } = "";
}

public sealed class CustomerTicketRequest
{
    public string AuthenticationString { get; set; } = "";
    public int TicketId { get; set; }
}

public sealed class CustomerTicketReplyRequest
{
    public string AuthenticationString { get; set; } = "";
    public int TicketId { get; set; }
    public string Message { get; set; } = "";
}

public sealed class CustomerTicketListItem
{
    public int Id { get; set; }
    public string Subject { get; set; } = "";
    public TicketStatus Status { get; set; }
    public DateTime Created { get; set; }
    public DateTime? LastMessageDate { get; set; }
    public int MessageCount { get; set; }
    public bool HasUnreadMessages { get; set; }
}

public sealed class CustomerTicket
{
    public int Id { get; set; }
    public int ContractId { get; set; }
    public string Subject { get; set; } = "";
    public TicketStatus Status { get; set; }
    public DateTime Created { get; set; }
    public List<CustomerTicketMessage> Messages { get; set; } = [];
}

public sealed class CustomerTicketMessage
{
    public int Id { get; set; }
    public string Message { get; set; } = "";
    public TicketMessageSender Sender { get; set; }

    public string SenderName { get; set; } = "";
    public DateTime Created { get; set; }
}
