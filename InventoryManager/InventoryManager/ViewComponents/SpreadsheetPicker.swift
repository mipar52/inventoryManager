import SwiftUI

struct SpreadsheetPicker: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        animation: .easeInOut
    )
    private var spreadsheets: FetchedResults<Spreadsheet>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
        animation: .easeInOut
    )
    private var sheets: FetchedResults<Sheet>
    @ObservedObject var viewModel: ScannerViewModel

    var body: some View {
        Menu {
            ForEach(spreadsheets, id: \.objectID) { spreadsheet in
                SpreadsheetSubmenu(
                    spreadsheet: spreadsheet,
                    selectedSpreadsheet: viewModel.selectedSpreadsheet,
                    selectedSheet: viewModel.selectedSheet,
                    onSelect: { sp, sh in
                        viewModel.selectedSpreadsheet = sp
                        viewModel.selectedSheet = sh
                    }
                )
            }
        } label: {
            HStack(spacing: 8) {
                Text(viewModel.selectedSpreadsheet?.name ?? "Select Spreadsheet")
                    .lineLimit(1)
                Image(systemName: "chevron.down")
            }
            .frame(width: 220, height: 44)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct SpreadsheetSubmenu: View {
    let spreadsheet: Spreadsheet
    let selectedSpreadsheet: Spreadsheet?
    let selectedSheet: Sheet?
    let onSelect: (Spreadsheet, Sheet) -> Void

    var body: some View {
        let sheets = sheetsArray(for: spreadsheet)

        if sheets.isEmpty {
            Menu(spreadsheet.name ?? "Untitled") {
                Button("No sheets") {}.disabled(true)
            }
        } else {
            Menu(spreadsheet.name ?? "Untitled") {
                ForEach(sheets, id: \.objectID) { sheet in
                    Button {
                        onSelect(spreadsheet, sheet)
                    } label: {
                        HStack {
                            Text(sheet.name ?? "Untitled sheet")
                            if isSelected(sheet: sheet, in: spreadsheet) {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: helpers
    private func sheetsArray(for spreadsheet: Spreadsheet) -> [Sheet] {
        let set = (spreadsheet.sheets as? Set<Sheet>) ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }

    private func isSelected(sheet: Sheet, in spreadsheet: Spreadsheet) -> Bool {
        selectedSpreadsheet?.objectID == spreadsheet.objectID &&
        selectedSheet?.objectID == sheet.objectID
    }
}
