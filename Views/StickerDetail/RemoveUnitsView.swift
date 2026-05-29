import SwiftUI
import SwiftData

struct RemoveUnitsView: View {
    @Bindable var sticker: Sticker
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Event.dateCreated, order: .reverse) private var events: [Event]

    @State private var quantityText = ""
    @State private var selectedDestination: Destination = .correction
    @State private var selectedEvent: Event?
    @State private var newEventName = ""

    enum Destination: String, CaseIterable {
        case existingEvent = "Existing Event"
        case newEvent      = "New Event"
        case correction    = "No event (correction)"
    }

    private var quantity: Int? { Int(quantityText) }

    private var quantityExceedsStock: Bool {
        guard let q = quantity else { return false }
        return q > sticker.currentUnits
    }

    private var isValid: Bool {
        guard let q = quantity, q >= 1, !quantityExceedsStock else { return false }
        switch selectedDestination {
        case .existingEvent: return selectedEvent != nil
        case .newEvent:      return !newEventName.trimmingCharacters(in: .whitespaces).isEmpty
        case .correction:    return true
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                quantitySection
                destinationSection
                eventDetailSection
            }
            .navigationTitle("Remove Units")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!isValid)
                }
            }
            .onAppear {
                selectedDestination = events.isEmpty ? .correction : .existingEvent
            }
        }
    }

    private var quantitySection: some View {
        Section("Quantity to Remove") {
            TextField("e.g. 3", text: $quantityText)
                .keyboardType(.numberPad)
            if quantityExceedsStock {
                Text("Not enough units (have \(sticker.currentUnits))")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }

    private var destinationSection: some View {
        Section("Destination") {
            Picker("Type", selection: $selectedDestination) {
                ForEach(Destination.allCases, id: \.self) { dest in
                    Text(dest.rawValue).tag(dest)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }

    @ViewBuilder
    private var eventDetailSection: some View {
        switch selectedDestination {
        case .existingEvent:
            Section("Event") {
                if events.isEmpty {
                    Text("No events yet — choose New Event to create one.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Select Event", selection: $selectedEvent) {
                        Text("Select…").tag(Optional<Event>.none)
                        ForEach(events) { event in
                            Text(event.name).tag(Optional(event))
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
        case .newEvent:
            Section("New Event Name") {
                TextField("e.g. Summer Market", text: $newEventName)
            }
        case .correction:
            EmptyView()
        }
    }

    private func save() {
        guard let quantity, quantity >= 1, quantity <= sticker.currentUnits else { return }

        sticker.currentUnits -= quantity

        let entry: LogEntry

        switch selectedDestination {
        case .existingEvent:
            guard let event = selectedEvent else { return }
            entry = LogEntry(
                quantityChange: -quantity,
                date: .now,
                type: .sale,
                priceAtTime: sticker.unitPrice,
                sticker: sticker,
                event: event
            )

        case .newEvent:
            let trimmedName = newEventName.trimmingCharacters(in: .whitespaces)
            guard !trimmedName.isEmpty else { return }
            let event = Event(name: trimmedName)
            modelContext.insert(event)
            entry = LogEntry(
                quantityChange: -quantity,
                date: .now,
                type: .sale,
                priceAtTime: sticker.unitPrice,
                sticker: sticker,
                event: event
            )

        case .correction:
            entry = LogEntry(
                quantityChange: -quantity,
                date: .now,
                type: .correction,
                priceAtTime: nil,
                sticker: sticker,
                event: nil
            )
        }

        modelContext.insert(entry)
        dismiss()
    }
}
