using System.Net;
using System.Net.Http.Json;
using GlassOps.Customer.Models;

namespace GlassOps.Customer.Services;

public sealed class CustomerApiService
{
    public class CustomerImageRequestDTO
    {
        public string AuthenticationString { get; set; } = "";
        public int ContractId { get; set; }
        public string Filename { get; set; } = "";
    }

    private readonly HttpClient _httpClient;
    private readonly CustomerSessionService _session;

    public CustomerApiService(HttpClient httpClient, CustomerSessionService session)
    {
        _httpClient = httpClient;
        _session = session;
    }

    public async Task<(bool Success, string Message)> LoginAsync(
        string reference,
        string email,
        string password)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/Login",
                new CustomerLoginRequest
                {
                    Reference = reference.Trim(),
                    Email = email.Trim(),
                    Password = password
                });

            if (!response.IsSuccessStatusCode)
            {
                var error = await TryReadReasonAsync(response);
                return (false, string.IsNullOrWhiteSpace(error) ? "Login failed." : error);
            }

            var result = await response.Content.ReadFromJsonAsync<CustomerLoginResult>();

            if (result is null || string.IsNullOrWhiteSpace(result.AuthenticationString))
                return (false, "The server returned an invalid login response.");

            await _session.SetAsync(
                    result.AuthenticationString,
                    result.CustomerId,
                    result.ContractId,
                    result.CustomerName);

            return (true, "");
        }
        catch (HttpRequestException)
        {
            return (false, "Unable to contact Glass Ops. Check your internet connection and try again.");
        }
        catch
        {
            return (false, "Something went wrong while signing in.");
        }
    }

    public async Task<CustomerRepair?> GetCurrentRepairAsync(CancellationToken cancellationToken = default)
    {
        await _session.RestoreAsync();

        if (!_session.IsLoggedIn)
            return null;

        var response = await _httpClient.PostAsJsonAsync(
            "Customer/CurrentRepair",
            new CustomerApiRequest
            {
                AuthenticationString = _session.AuthenticationString,
                ContractId = _session.ContractId
            },
            cancellationToken);

        if (response.StatusCode == HttpStatusCode.Unauthorized)
        {
            _session.Logout();
            return null;
        }

        if (response.StatusCode == HttpStatusCode.NotFound)
            return null;

        response.EnsureSuccessStatusCode();
        return await response.Content.ReadFromJsonAsync<CustomerRepair>(cancellationToken: cancellationToken);
    }

    public async Task<string?> GetCustomerImageAsync(string imageUrlOrFilename)
    {
        await _session.RestoreAsync();

        if (!_session.IsLoggedIn)
            return null;

        try
        {
            string filename = imageUrlOrFilename;

            if (Uri.TryCreate(imageUrlOrFilename, UriKind.Absolute, out var absoluteUri))
                filename = Path.GetFileName(absoluteUri.LocalPath);
            else
                filename = Path.GetFileName(imageUrlOrFilename);

            if (string.IsNullOrWhiteSpace(filename))
                return null;

            var response = await _httpClient.PostAsJsonAsync(
                "Customer/GetImage",
                new CustomerImageRequestDTO
                {
                    AuthenticationString = _session.AuthenticationString,
                    ContractId = _session.ContractId,
                    Filename = filename
                });

            if (response.StatusCode == HttpStatusCode.Unauthorized)
            {
                _session.Logout();
                return null;
            }

            if (!response.IsSuccessStatusCode)
                return null;

            byte[] bytes = await response.Content.ReadAsByteArrayAsync();

            string contentType =
                response.Content.Headers.ContentType?.MediaType
                ?? "image/jpeg";

            return $"data:{contentType};base64,{Convert.ToBase64String(bytes)}";
        }
        catch
        {
            return null;
        }
    }

    private static async Task<string> TryReadReasonAsync(HttpResponseMessage response)
    {
        try
        {
            var result = await response.Content.ReadFromJsonAsync<ApiError>();
            return result?.ReasonPhrase ?? "";
        }
        catch
        {
            return "";
        }
    }

    private sealed class ApiError
    {
        public string ReasonPhrase { get; set; } = "";
    }


    public async Task<CustomerAccountDTO?> GetAccountAsync()
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/Account",
                new CustomerApiRequest
                {
                    AuthenticationString =
                        _session.AuthenticationString,
                    ContractId = _session.ContractId
                });

            if (!response.IsSuccessStatusCode)
                return null;

            return await response.Content
                .ReadFromJsonAsync<CustomerAccountDTO>();
        }
        catch
        {
            return null;
        }
    }

    public async Task<(bool Success, string Message)> ChangePasswordAsync(
    string currentPassword,
    string newPassword)
    {
        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/ChangePassword",
                new
                {
                    AuthenticationString =
                        _session.AuthenticationString,

                    CurrentPassword = currentPassword,
                    NewPassword = newPassword
                });

            if (response.IsSuccessStatusCode)
                return (true, "Your password has been changed.");

            return (false, "Unable to change password.");
        }
        catch
        {
            return (false, "Unable to contact Glass Ops.");
        }
    }

    public async Task<(bool Success, string Message, int TicketId)> CreateTicketAsync(
        int contractId,
        string subject,
        string message)
    {
        await _session.RestoreAsync();

        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/CreateTicket",
                new CustomerCreateTicketRequest
                {
                    AuthenticationString = _session.AuthenticationString,
                    ContractId = contractId,
                    Subject = subject.Trim(),
                    Message = message.Trim()
                });

            if (response.StatusCode == HttpStatusCode.Unauthorized)
            {
                _session.Logout();
                return (false, "Your session has expired. Please sign in again.", 0);
            }

            if (!response.IsSuccessStatusCode)
            {
                var error = await TryReadReasonAsync(response);
                return (false, string.IsNullOrWhiteSpace(error) ? "Unable to send your message." : error, 0);
            }

            var result = await response.Content.ReadFromJsonAsync<CreateTicketResult>();
            return (true, "Your message has been sent.", result?.TicketId ?? 0);
        }
        catch (HttpRequestException)
        {
            return (false, "Unable to contact Glass Ops. Check your internet connection and try again.", 0);
        }
        catch
        {
            return (false, "Something went wrong while sending your message.", 0);
        }
    }

    public async Task<List<CustomerTicketListItem>> GetTicketsAsync()
    {
        await _session.RestoreAsync();

        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/Tickets",
                new CustomerApiRequest
                {
                    AuthenticationString = _session.AuthenticationString,
                    ContractId = _session.ContractId
                });

            if (response.StatusCode == HttpStatusCode.Unauthorized)
            {
                _session.Logout();
                return [];
            }

            if (!response.IsSuccessStatusCode)
                return [];

            return await response.Content.ReadFromJsonAsync<List<CustomerTicketListItem>>() ?? [];
        }
        catch
        {
            return [];
        }
    }

    public async Task<CustomerTicket?> GetTicketAsync(int ticketId)
    {
        await _session.RestoreAsync();

        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/Ticket",
                new CustomerTicketRequest
                {
                    AuthenticationString = _session.AuthenticationString,
                    TicketId = ticketId
                });

            if (response.StatusCode == HttpStatusCode.Unauthorized)
            {
                _session.Logout();
                return null;
            }

            if (!response.IsSuccessStatusCode)
                return null;

            return await response.Content.ReadFromJsonAsync<CustomerTicket>();
        }
        catch
        {
            return null;
        }
    }

    public async Task<(bool Success, string Message)> ReplyToTicketAsync(
        int ticketId,
        string message)
    {
        await _session.RestoreAsync();

        try
        {
            var response = await _httpClient.PostAsJsonAsync(
                "Customer/ReplyToTicket",
                new CustomerTicketReplyRequest
                {
                    AuthenticationString = _session.AuthenticationString,
                    TicketId = ticketId,
                    Message = message.Trim()
                });

            if (response.StatusCode == HttpStatusCode.Unauthorized)
            {
                _session.Logout();
                return (false, "Your session has expired. Please sign in again.");
            }

            if (!response.IsSuccessStatusCode)
            {
                var error = await TryReadReasonAsync(response);
                return (false, string.IsNullOrWhiteSpace(error) ? "Unable to send your reply." : error);
            }

            return (true, "Reply sent.");
        }
        catch (HttpRequestException)
        {
            return (false, "Unable to contact Glass Ops. Check your internet connection and try again.");
        }
        catch
        {
            return (false, "Something went wrong while sending your reply.");
        }
    }

    private sealed class CreateTicketResult
    {
        public int TicketId { get; set; }
    }

}
