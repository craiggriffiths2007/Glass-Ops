using GlassOps.Customer.Models;

namespace GlassOps.Customer.Services;

public static class DemoCustomerData
{
    public static CustomerRepair CurrentRepair { get; } = new()
    {
        Guid = Guid.Parse("A53129C5-0FC5-4B62-BEE8-2B61B73F0C3B"),
        Reference = "GO-10482",
        AddressLine1 = "12 Green Lane",
        Town = "Bolton",
        Postcode = "BL1 4AA",
        Status = ContractStatus.SurveyCompleted,
        StatusTitle = "Parts ordered",
        StatusDescription = "Your replacement glass has been ordered and is being prepared for fitting.",
        StatusEta = "Expected around 14 September",
        NextAppointment = new CustomerAppointment
        {
            Type = "Fitting appointment",
            DateTime = new DateTime(2026, 9, 18, 9, 30, 0),
            EngineerName = "To be confirmed",
            Notes = "We will confirm your fitter before the appointment."
        },
        Items =
        [
            new CustomerRepairItem
            {
                Title = "Replacement sealed glass unit",
                Description = "A replacement double-glazed unit has been ordered to match the existing window.",
                Location = "Living room"
            },
            new CustomerRepairItem
            {
                Title = "Window handle",
                Description = "The damaged handle will be replaced during the same visit.",
                Location = "Living room"
            }
        ],
        Photos =
        [
            new CustomerPhoto
            {
                Url = "images/demo/living-room-window.svg",
                Title = "Living room window",
                Description = "Initial survey photo showing the damaged sealed glass unit in the living room.",
                Category = "Survey",
                DateTime = new DateTime(2026, 9, 4, 10, 52, 0)
            },
            new CustomerPhoto
            {
                Url = "images/demo/window-handle.svg",
                Title = "Damaged window handle",
                Description = "The surveyor recorded the damaged handle so the correct replacement can be supplied.",
                Category = "Survey",
                DateTime = new DateTime(2026, 9, 4, 10, 56, 0)
            },
            new CustomerPhoto
            {
                Url = "images/demo/glass-measurement.svg",
                Title = "Glass measured",
                Description = "Survey measurement used to order the replacement sealed glass unit.",
                Category = "Survey",
                DateTime = new DateTime(2026, 9, 4, 11, 2, 0)
            },
            new CustomerPhoto
            {
                Url = "images/demo/exterior-window.svg",
                Title = "External view",
                Description = "External survey view of the affected living room window.",
                Category = "Survey",
                DateTime = new DateTime(2026, 9, 4, 11, 8, 0)
            },
            new CustomerPhoto
            {
                Url = "images/demo/glass-unit.svg",
                Title = "Replacement unit ready",
                Description = "The replacement sealed unit has arrived and is ready for the fitting appointment.",
                Category = "Parts",
                DateTime = new DateTime(2026, 9, 14, 13, 25, 0)
            },
            new CustomerPhoto
            {
                Url = "images/demo/completed-window.svg",
                Title = "Completed repair",
                Description = "Example completion photo. Once the repair is finished, the fitter's approved completion photos will appear here.",
                Category = "Completed",
                DateTime = new DateTime(2026, 9, 18, 11, 42, 0)
            }
        ],
        Updates =
        [
            new CustomerRepairUpdate
            {
                DateTime = new DateTime(2026, 9, 4, 14, 32, 0),
                Title = "Parts ordered",
                Description = "Your replacement glass and handle have been ordered.",
                IsCurrent = true
            },
            new CustomerRepairUpdate
            {
                DateTime = new DateTime(2026, 9, 4, 11, 20, 0),
                Title = "Survey completed",
                Description = "Your surveyor completed the property survey and confirmed the items required."
            },
            new CustomerRepairUpdate
            {
                DateTime = new DateTime(2026, 9, 2, 9, 0, 0),
                Title = "Survey booked",
                Description = "Your survey appointment was booked for 4 September."
            },
            new CustomerRepairUpdate
            {
                DateTime = new DateTime(2026, 9, 1, 15, 45, 0),
                Title = "Repair reported",
                Description = "We received your repair and created your Glass Ops reference."
            }
        ]
    };
}
