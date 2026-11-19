import SwiftUI
import SwiftData

struct RemoveUnitsView: View {
    let sticker: Sticker
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Event.dateCreated, order: .reverse) private var events: [Event]

    @State private var quantityText = ""
    @State private var selectedDestination: Destination = .correction
    @State private var selectedEvent: Event?
    @State private var newEventName = ""
    @FocusState private var quantityFocused: Bool

    enum Destination: String, CaseIterable {
        case existingEvent = "Existing Event"
        case newEvent      = "New Event"
        case correction    = "No event (correction)"
    }

    private var quantity: Int? { Int(quantityInput: quantityText) }

    private var quantityExceedsStock: Bool {
        guard let q = quantity else { return false }
        return q > sticker.currentUnits
    }

    private var trimmedNewEventName: String {
        newEventName.trimmingCharacters(in: .whitespaces)
    }

    private var newEventNameIsTaken: Bool {
        events.contains { $0.name.localizedCaseInsensitiveCompare(trimmedNewEventName) == .orderedSame }
    }

    private var isValid: Bool {
        guard let q = quantity, q >= 1, !quantityExceedsStock else { return false }
        switch selectedDestination {
        case .existingEvent: return selectedEvent != nil
        case .newEvent:      return !trimmedNewEventName.isEmpty && !newEventNameIsTaken
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
                selectedEvent = events.first  // newest event
                quantityFocused = true
            }
        }
    }

    private var quantitySection: some View {
        Section("Quantity to Remove") {
            TextField("e.g. 3", text: $quantityText)
                .keyboardType(.numberPad)
                .focused($quantityFocused)
            if !quantityText.isEmpty && quantity == nil {
                Text(invalidQuantityMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            } else if quantityExceedsStock {
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
                    Picker("Event", selection: $selectedEvent) {
                        Text("Select…").tag(Optional<Event>.none)
                        ForEach(events) { event in
                            Text(event.name).tag(Optional(event))
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        case .newEvent:
            Section("New Event Name") {
                TextField("e.g. Summer Market", text: $newEventName)
                if newEventNameIsTaken {
                    Text("An event with this name already exists. Choose it under Existing Event.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        case .correction:
            EmptyView()
        }
    }

    private func save() {
        // All validation happens before anything is mutated.
        guard isValid, let quantity else { return }

        switch selectedDestination {
        case .existingEvent:
            sticker.record(-quantity, type: .sale, event: selectedEvent)
        case .newEvent:
            let event = Event(name: trimmedNewEventName)
            modelContext.insert(event)
            sticker.record(-quantity, type: .sale, event: event)
        case .correction:
            sticker.record(-quantity, type: .correction)
        }

        dismiss()
    }
}
