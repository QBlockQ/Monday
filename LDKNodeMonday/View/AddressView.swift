//
//  AddressView.swift
//  LDKNodeMonday
//
//  Created by Matthew Ramsden on 2/20/23.
//

import SwiftUI
import LightningDevKitNode
import WalletUI

class AddressViewModel: ObservableObject {
    @Published var address: String = ""
    @Published var synced: Bool = false
    @Published var balance: String = "0"
    
    func getAddress() {
        guard let address = LightningNodeService.shared.getAddress() else {
            self.address = ""
            return
        }
        self.address = address
    }
    
}

struct AddressView: View {
    @ObservedObject var viewModel: AddressViewModel
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color(uiColor: UIColor.systemBackground)
                
                VStack {
                    
                    QRCodeView(address: viewModel.address)
                        .padding()
                    
                    Text("Copy Address")
                        .bold()
                    
                    Text("Receive bitcoin from other wallets or exchanges with these addresses.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(alignment: .center) {
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 50.0, height: 50.0)
                                .foregroundColor(.orange)
                            Image(systemName: "bitcoinsign")
                                .font(.title)
                                .foregroundColor(Color(uiColor: .systemBackground))
                                .bold()
                        }
                        
                        VStack(alignment: .leading, spacing: 5.0) {
                            Text("Bitcoin Network")
                                .font(.caption)
                                .bold()
                            Text(viewModel.address)
                                .font(.caption)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button {
                            UIPasteboard.general.string = viewModel.address
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                    .font(.subheadline)
                            }
                            .bold()
                        }
                        
                    }
                    .padding()
                    
                }
                .padding()
                .navigationTitle("Address")
                .onAppear {
                    Task {
                        viewModel.getAddress()
                    }
                }
                
            }
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(viewModel: .init())
        AddressView(viewModel: .init())
            .environment(\.colorScheme, .dark)
    }
}
