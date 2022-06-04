//
//  tinnitusApp.swift
//  tinnitus
//
//  Created by Simone Giordano on 12/03/22.
//

import SwiftUI

@main
struct tinnitusApp: App {
   

    var body: some Scene {
        WindowGroup {
            TabView {
                NoiseView()
                   
                .environmentObject(AudioConductor.shared)
                .tabItem{
                    Label("Noise", systemImage: "wave.3.left")
                }
                FrequencyView()
                    
                .environmentObject(AudioConductor.shared)
                .tabItem{
                    Label("Frequency", systemImage: "alternatingcurrent")
                }
            }
        }
    }
}
