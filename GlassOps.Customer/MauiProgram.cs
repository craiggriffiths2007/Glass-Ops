using Microsoft.Extensions.Logging;
using GlassOps.Customer.Services;

namespace GlassOps.Customer
{
    public static class MauiProgram
    {
        public static MauiApp CreateMauiApp()
        {
            var builder = MauiApp.CreateBuilder();
            builder
                .UseMauiApp<App>()
                .ConfigureFonts(fonts =>
                {
                    fonts.AddFont("OpenSans-Regular.ttf", "OpenSansRegular");
                });

            builder.Services.AddMauiBlazorWebView();

            builder.Services.AddSingleton(new HttpClient
            {
#if DEBUG
                //BaseAddress = new Uri("http://10.70.89.97:100/")
                BaseAddress = new Uri("https://glassops.co.uk/")
#else
                    BaseAddress = new Uri("https://glassops.co.uk/")
#endif

            });

            builder.Services.AddSingleton<CustomerSessionService>();
            builder.Services.AddSingleton<CustomerApiService>();
            builder.Services.AddSingleton<CustomerRepairState>();

#if DEBUG
            builder.Services.AddBlazorWebViewDeveloperTools();
            builder.Logging.AddDebug();
#endif

            return builder.Build();
        }
    }
}
