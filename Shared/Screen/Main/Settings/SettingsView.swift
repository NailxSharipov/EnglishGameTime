//
//  SettingsView.swift
//  BigBanEng
//
//  Created by Nail Sharipov on 01.06.2022.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject
    private var mainViewModel: MainView.ViewModel
    
    @StateObject
    private var viewModel = ViewModel()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 8) {

            }
            .frame(maxWidth: 300, alignment: .center)
            .padding([.trailing, .leading], 16)
        }
    }
    
}
