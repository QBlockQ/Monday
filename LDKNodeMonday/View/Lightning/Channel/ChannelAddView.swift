//
//  ChannelAddView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/21/23.
//

import BitcoinUI
import CodeScanner
import SwiftUI

struct ChannelAddView: View {
    @ObservedObject var viewModel: ChannelAddViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingScanner = false
    @State private var showingChannelAddViewErrorAlert = false
    @State private var keyboardOffset: CGFloat = 0
    @FocusState private var isFocused: Bool
    let pasteboard = UIPasteboard.general

    var body: some View {

        ZStack {
            Color(uiColor: UIColor.systemBackground)

            VStack {

                HStack {

                    Button {
                        if pasteboard.hasStrings {
                            if let string = pasteboard.string {
                                if let peer = string.parseConnectionInfo() {
                                    viewModel.nodeId = peer.nodeID
                                    viewModel.address = peer.address
                                } else {
                                    viewModel.channelAddViewError = .init(
                                        title: "Unexpected error",
                                        detail: "Connection info could not be parsed."
                                    )
                                }
                            } else {
                                //viewModel.channelAddViewError = .init(title: "Unexpected error", detail: "Text from Pasteboard not found.")
                            }
                        } else {
                            DispatchQueue.main.async {
                                viewModel.channelAddViewError = .init(
                                    title: "Unexpected error",
                                    detail: "Pasteboard has no text."
                                )
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Paste")
                        }
                    }

                    Spacer()

                    Button {
                        isShowingScanner = true
                    } label: {
                        HStack {
                            Image(systemName: "qrcode.viewfinder")
                            Text("Scan")
                        }
                    }

                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .tint(viewModel.networkColor)
                .padding()
                .padding(.top, 20.0)

                if viewModel.isProgressViewShowing {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }

                VStack(alignment: .leading) {

                    Text("Node ID")
                        .bold()

                    ZStack {

                        TextField(
                            "03a5b467d7f...4c2b099b8250c",
                            text: $viewModel.nodeId
                        )
                        .onChange(of: viewModel.nodeId) { newValue in
                            viewModel.nodeId = newValue.replacingOccurrences(of: " ", with: "")
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .truncationMode(.middle)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 32))

                        if !viewModel.nodeId.isEmpty {
                            HStack {
                                Spacer()
                                Button(action: {
                                    self.viewModel.nodeId = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 8)
                            }
                        }
                    }

                    Text("Address")
                        .bold()

                    ZStack {
                        TextField(
                            "172.18.0.2:9735",
                            text: $viewModel.address
                        )
                        .onChange(of: viewModel.nodeId) { newValue in
                            viewModel.nodeId = newValue.replacingOccurrences(of: " ", with: "")
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .truncationMode(.middle)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 32))

                        if !viewModel.address.isEmpty {

                            HStack {
                                Spacer()
                                Button {
                                    self.viewModel.address = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 8)
                            }

                        }
                    }

                    Text("Sats")
                        .bold()

                    ZStack {
                        TextField(
                            "125000",
                            text: $viewModel.channelAmountSats
                        )
                        .keyboardType(.numberPad)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 32))

                        if !viewModel.channelAmountSats.isEmpty {

                            HStack {

                                Spacer()

                                Button {
                                    self.viewModel.channelAmountSats = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.trailing, 8)

                            }
                        }
                    }

                }
                .padding(.horizontal)
                .padding(.bottom, 10)

                Button {
                    isFocused = false
                    let channelAmountSats = UInt64(viewModel.channelAmountSats) ?? UInt64(101010)
                    Task {
                        await viewModel.openChannel(
                            nodeId: viewModel.nodeId,
                            address: viewModel.address,
                            channelAmountSats: channelAmountSats,
                            pushToCounterpartyMsat: nil
                        )
                        if viewModel.isOpenChannelFinished == true {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                } label: {
                    Text("Open Channel")
                        .bold()
                        .foregroundColor(Color(uiColor: UIColor.systemBackground))
                        .frame(maxWidth: .infinity)
                        .padding(.all, 8)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.borderedProminent)
                .tint(viewModel.networkColor)
                .padding(.horizontal)
                .padding(.bottom, 80.0)

                Spacer()

            }
            .padding()
            .focused($isFocused)
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(
                    codeTypes: [.qr],
                    simulatedData:
                        "LNBC10U1P3PJ257PP5YZTKWJCZ5FTL5LAXKAV23ZMZEKAW37ZK6KMV80PK4XAEV5QHTZ7QDPDWD3XGER9WD5KWM36YPRX7U3QD36KUCMGYP282ETNV3SHJCQZPGXQYZ5VQSP5USYC4LK9CHSFP53KVCNVQ456GANH60D89REYKDNGSMTJ6YW3NHVQ9QYYSSQJCEWM5CJWZ4A6RFJX77C490YCED6PEMK0UPKXHY89CMM7SCT66K8GNEANWYKZGDRWRFJE69H9U5U0W57RRCSYSAS7GADWMZXC8C6T0SPJAZUP6",
                    completion: handleScan
                )
            }
            .alert(isPresented: $showingChannelAddViewErrorAlert) {
                Alert(
                    title: Text(viewModel.channelAddViewError?.title ?? "Unknown"),
                    message: Text(viewModel.channelAddViewError?.detail ?? ""),
                    dismissButton: .default(Text("OK")) {
                        viewModel.channelAddViewError = nil
                    }
                )
            }
            .onReceive(viewModel.$channelAddViewError) { errorMessage in
                if errorMessage != nil {
                    showingChannelAddViewErrorAlert = true
                }
            }
            .onReceive(viewModel.$isOpenChannelFinished) { _ in }
            .onAppear {
                viewModel.getColor()
            }

        }
        .ignoresSafeArea()

    }

}

extension ChannelAddView {

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        switch result {
        case .success(let result):
            let scannedQRCode = result.string.lowercased()
            if let peer = scannedQRCode.parseConnectionInfo() {
                viewModel.nodeId = peer.nodeID
                viewModel.address = peer.address
            } else {
                viewModel.channelAddViewError = .init(
                    title: "QR Parsing Error",
                    detail: "Failed to parse the QR code."
                )
            }
        case .failure(let error):
            viewModel.channelAddViewError = .init(
                title: "Scan Error",
                detail: error.localizedDescription
            )
        }
    }

}

struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        ChannelAddView(viewModel: .init())
        ChannelAddView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
