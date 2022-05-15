//
//  ContentView.swift
//  Shared
//
//  Created by Nail Sharipov on 12.05.2022.
//

import SwiftUI

#if os(iOS)
struct ContentView: View {
    var body: some View {
        NavigationView {
            SelectView()
        }.navigationViewStyle(.stack)
    }
}
#else
struct ContentView: View {
    var body: some View {
        NavigationView {
            SelectView()
        }.navigationViewStyle(.automatic)
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
