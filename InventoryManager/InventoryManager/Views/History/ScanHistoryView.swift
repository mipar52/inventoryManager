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
                            Section(header: Text(dayTitle(for: day)).font(.subheadline).foregroundStyle(.secondary)) {
                                ForEach(sectioned[day] ?? [], id: \.objectID) { item in
                                    NavigationLink {
                                        QrCodeDetailsView()
                                    } label: {
                                        QRRow(item: item)
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            delete(item)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            UIPasteboard.general.string = item.stringData ?? ""
                                        } label: {
                                            Label("Copy", systemImage: "doc.on.doc")
                                        }
                                    }
                                    .contextMenu {
                                        Button {
                                            UIPasteboard.general.string = item.stringData ?? ""
                                        } label: {
                                            Label("Copy", systemImage: "doc.on.doc")
                                        }
                                        if let s = item.stringData {
                                            ShareLink(item: s) { Label("Share", systemImage: "square.and.arrow.up") }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Scan History")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if !scans.isEmpty {
                        Button {
                            Task { await sendAll() }
                        } label: {
                            Image(systemName: "paperplane.circle.fill")
                                .symbolEffect(.bounce, value: isSendingAll)
                        }
                        .accessibilityLabel("Send all scans")

                        Button(role: .destructive) { confirmDeleteAll = true } label: {
                            Image(systemName: "trash")
                        }
                        .accessibilityLabel("Delete all scans")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .automatic),
                        prompt: "Search scanned text")
            .alert("Delete All Scans?", isPresented: $confirmDeleteAll) {
                Button("Delete All", role: .destructive) { deleteAll() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This cannot be undone.")
            }
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

    // MARK: - Actions

    private func delete(_ item: QRCodeData) {
        context.delete(item)
        try? context.save()
    }

    private func deleteAll() {
        for s in scans { context.delete(s) }
        try? context.save()
    }

    private func sendAll() async {
        // hook to your append-to-sheet logic; consider batching & error handling
        isSendingAll.toggle()
        // simulate brief feedback
        try? await Task.sleep(nanoseconds: 500_000_000)
        isSendingAll.toggle()
        // After successful send, optionally mark items as sent in Core Data
    }

    // MARK: - Helpers

    private func dayTitle(for day: DateOnly) -> String {
        if Calendar.current.isDateInToday(day.date) { return "Today" }
        if Calendar.current.isDateInYesterday(day.date) { return "Yesterday" }
        let f = DateFormatter(); f.dateStyle = .medium; f.timeStyle = .none
        return f.string(from: day.date)
    }
}

private struct QRRow: View {
    let item: QRCodeData

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "qrcode.viewfinder")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .purple)
                .frame(width: 36, height: 36)
                .background(Circle().fill(.ultraThinMaterial))
            VStack(alignment: .leading, spacing: 4) {
                Text(item.stringData ?? "—")
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(2)
                Text(relativeTime)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }

    private var relativeTime: String {
        let date = item.timestamp ?? Date()
        let r = RelativeDateTimeFormatter()
        r.unitsStyle = .short
        return r.localizedString(for: date, relativeTo: Date())
    }
}

private struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "qrcode.viewfinder")
                .font(.system(size: 56))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white.opacity(0.9), .purple)
                .symbolEffect(.pulse.byLayer, options: .repeat(.periodic(Int(1.8))))
            Text("No scans yet")
                .font(.title3).bold()
            Text("Scan a code using Live Scan or pick a photo to get started.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct ScanDetailPlaceholder: View {
    let objectID: NSManagedObjectID
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.magnifyingglass").font(.largeTitle)
            Text("Scan detail view").font(.headline)
            Text("ObjectID: \(objectID.uriRepresentation().absoluteString)")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding()
    }
}

// MARK: - Date grouping helper

private struct DateOnly: Hashable, Comparable {
    let y: Int; let m: Int; let d: Int
    var date: Date {
        var c = DateComponents(year: y, month: m, day: d)
        return Calendar.current.date(from: c) ?? Date()
    }
    init(from date: Date) {
        let c = Calendar.current.dateComponents([.year,.month,.day], from: date)
        y = c.year ?? 0; m = c.month ?? 0; d = c.day ?? 0
    }
    static func < (lhs: DateOnly, rhs: DateOnly) -> Bool {
        if lhs.y != rhs.y { return lhs.y < rhs.y }
        if lhs.m != rhs.m { return lhs.m < rhs.m }
        return lhs.d < rhs.d
    }
}
#Preview {
    ScanHistoryView()
}
