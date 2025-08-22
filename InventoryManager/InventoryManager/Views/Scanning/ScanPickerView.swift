import SwiftUI

struct ScanPickerView: View {
    @EnvironmentObject private var selectionService: SelectionService

    @StateObject private var scannerVM = ScannerViewModel()
    @StateObject private var spreadsheetVM: SpreadsheetPickerViewModel

    @State private var isLiveScanPressed = false
    @State private var isPhotoPressed    = false
    @State private var showTargetPicker  = false

    init(selectionService: SelectionService) {
        _spreadsheetVM = StateObject(wrappedValue: SpreadsheetPickerViewModel(selectionService: selectionService))
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color.purple.opacity(0.25), Color.blue.opacity(0.25)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Button {
                        showTargetPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: targetIcon)
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.purple, .secondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Sending to")
                                    .font(.caption).foregroundStyle(.secondary)
                                Text(currentTargetText)
                                    .font(.headline)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .strokeBorder(.white.opacity(0.15))
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Choose spreadsheet and sheet")

                    VStack(spacing: 14) {
                        NavigationLink {
                            QRScanStreamView(
                                scannerViewModel: scannerVM,
                                spreadsheetPickerViewModel: spreadsheetVM
                            )
                        } label: {
                            FeatureCard(
                                title: "Live Scan",
                                subtitle: "Use camera to scan QR / barcodes",
                                systemImage: "viewfinder",
                                isPressed: isLiveScanPressed
                            )
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            isLiveScanPressed.toggle()
                            triggerHaptic()
                        })

                        NavigationLink {
                            PhotoPickerView(
                                scannerViewModel: scannerVM,
                                spreadsheetViewModel: spreadsheetVM
                            )
                        } label: {
                            FeatureCard(
                                title: "From Photo",
                                subtitle: "Pick an image and detect codes",
                                systemImage: "photo.on.rectangle",
                                isPressed: isPhotoPressed
                            )
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            isPhotoPressed.toggle()
                            triggerHaptic()
                        })
                    }

                    Spacer(minLength: 16)

                    PermissionHintView()
                }
                .padding(20)
                .navigationTitle("Pick a scanning method")
                .navigationBarTitleDisplayMode(.large)
            }
            .sheet(isPresented: $showTargetPicker) {
                // Put your nested menu/picker screen here
                SheetPickerView(viewModel: spreadsheetVM,
                                spreadsheet: spreadsheetVM.selectedSpreadsheet ?? Spreadsheet())
                    .presentationDetents([.medium, .large])
            }
            .task { spreadsheetVM.loadSelection() } // initial load
        }
    }

    private var currentTargetText: String {
        if let sp = spreadsheetVM.selectedSpreadsheet?.name,
           let sh = spreadsheetVM.selectedSheet?.name {
            return "\(sp) • \(sh)"
        }
        if let sp = spreadsheetVM.selectedSpreadsheet?.name {
            return sp
        }
        return "Not selected"
    }

    private var targetIcon: String {
        spreadsheetVM.selectedSpreadsheet == nil ? "exclamationmark.triangle.fill" : "checkmark.seal.fill"
    }

    private func triggerHaptic() {
        if #available(iOS 17.0, *) {
            // Subtle feedback on tap
          //  UIApplication.shared.perform(.playHapticTransient) // or use .sensoryFeedback in buttonStyle
        } else {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
