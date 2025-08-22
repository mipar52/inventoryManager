//
//  ScanHistoryView.swift
//  InventoryManager
//
//  Created by Milan Parađina on 01.08.2025..
//

import SwiftUI
import CoreData

struct ScanHistoryView: View {
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "timestamp", ascending: false)],
        animation: .easeInOut
    )
    private var scans: FetchedResults<QRCodeData>
    
    @State private var searchText = ""
    @State private var confirmDeleteAll = false
    @State private var isSendingAll = false
    @State private var isLoading = false
    @StateObject var vm: ScanHistoryViewModel
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.purple.opacity(0.18), Color.blue.opacity(0.18)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                if filtered.isEmpty {
                    EmptyStateView()
                        .padding()
                } else {
                    List {
                        ForEach(sectioned.keys.sorted(by: >), id: \.self) { day in
                            ScanHistorySection(
                                title: dayTitle(for: day),
                                scannedItems: Array(scans),
                                vm: vm)
                        }
                    }
                    .scrollContentBackground(.hidden)
                }
            }
            .onAppear(perform: {
                Task {
                    do {
                        try await vm.configure()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
            })
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !scans.isEmpty {
                        Button {
                            Task {
                                do {
                                    isSendingAll.toggle()
                                    isLoading.toggle()
                                    try await vm.sendAllScans(items: Array(scans))
                                    isLoading.toggle()
                                } catch {
                                    isLoading.toggle()
                                    
                                    debugPrint(error.localizedDescription)
                                }
                            }
                        } label: {
                            Image(systemName: "paperplane.circle.fill")
                                .symbolEffect(.bounce, value: isSendingAll)
                        }
                        .accessibilityLabel("Send all scans")
                        
                        Button(role: .destructive) {
                            do {
                                isLoading.toggle()
                                try vm.deleteAllItems()
                            } catch {
                                debugPrint(error.localizedDescription)
                            }
                        } label: {
                            Image(systemName: "trash")
                                .symbolEffect(.pulse, value: isLoading)
                        }
                        .accessibilityLabel("Delete all scans")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search scanned text")
            .alert("Delete All Scans?", isPresented: $confirmDeleteAll) {
                Button("Delete All", role: .destructive)
                {
                    do {
                        try vm.deleteAllItems()
                    } catch {
                        debugPrint(error.localizedDescription)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
            .loadingOverlay(
                $isLoading,
                text: "Getting stuff done",
                symbols: ["document.on.document.fill", "document.viewfinder.fill", "document.badge.arrow.up.fill"])
        }
    }
    
    // MARK: - Derived collections
    
    private var filtered: [QRCodeData] {
        guard !searchText.isEmpty else { return Array(scans) }
        let q = searchText.lowercased()
        return scans.filter { ($0.stringData ?? "").lowercased().contains(q) }
    }
    
    private var sectioned: [DateOnly: [QRCodeData]] {
        Dictionary(grouping: filtered, by: { DateOnly(from: $0.timestamp ?? Date()) })
    }
        
    private func dayTitle(for day: DateOnly) -> String {
        if Calendar.current.isDateInToday(day.date) { return "Today" }
        if Calendar.current.isDateInYesterday(day.date) { return "Yesterday" }
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none
        return f.string(from: day.date)
    }
}

#Preview {
    // ScanHistoryView()
}
