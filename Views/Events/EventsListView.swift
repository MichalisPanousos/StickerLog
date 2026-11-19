import SwiftUI
import SwiftData

struct EventsListView: View {
    @Query(sort: \Event.dateCreated, order: .reverse) private var events: [Event]

    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    ContentUnavailableView(
                        "No Events Yet",
                        systemImage: "bag",
                        description: Text("Sales recorded against an event will appear here.")
                    )
                } else {
                    List {
                        ForEach(events) { event in
                            NavigationLink(value: event) {
                                EventRowView(event: event)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Events")
            .navigationDestination(for: Event.self) { event in
                EventDetailView(event: event)
            }
        }
    }
}

private struct EventRowView: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.name)
                .font(.headline)
            HStack {
                Text("\(event.totalUnitsSold) units sold")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(event.totalValue, format: .eur)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
