import SwiftUI
import SwiftData

struct InventoryView: View {
    @Query(sort: \Sticker.dateCreated) private var stickers: [Sticker]

    @State private var showingAddSticker = false

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    private var totalUnits: Int {
        stickers.reduce(0) { $0 + $1.currentUnits }
    }

    private var totalValue: Decimal {
        stickers.reduce(Decimal(0)) { $0 + Decimal($1.currentUnits) * $1.unitPrice }
    }

    var body: some View {
        NavigationStack {
            Group {
                if stickers.isEmpty {
                    ContentUnavailableView(
                        "No Stickers Yet",
                        systemImage: "square.grid.2x2",
                        description: Text("Tap + to add your first sticker.")
                    )
                } else {
                    ScrollView {
                        StatsHeader(
                            leading: ("Total Units", "\(totalUnits)"),
                            trailing: ("Total Value", totalValue.formatted(.eur))
                        )
                        .padding(.horizontal)
                            .padding(.top, 8)

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(stickers) { sticker in
                                NavigationLink(value: sticker) {
                                    StickerCardView(sticker: sticker)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("Inventory")
            .navigationDestination(for: Sticker.self) { sticker in
                StickerDetailView(sticker: sticker)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSticker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSticker) {
                AddStickerView()
            }
        }
    }
}
