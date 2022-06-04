//
//  ContentView.swift
//  tinnitus
//
//  Created by Simone Giordano on 12/03/22.
//

import SwiftUI
import CoreData
import AudioToolbox
import AVFoundation
import AVKit
import AudioKit
import SoundpipeAudioKit

struct NoiseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
  
    
 
    @EnvironmentObject var conductor: AudioConductor
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Image(systemName: !conductor.whiteNoise.isStarted ? "play.circle.fill" : "stop.circle.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                    
                    .onTapGesture {
                        conductor.whiteNoise.isStarted ? conductor.whiteNoise.stop(): conductor.whiteNoise.start()
                        
                    }
               
                VolumeView()
                Spacer()
                
            }.onDisappear {
                conductor.whiteNoise.stop()
            }
            .navigationTitle("Noise Generator")
        }
    }
}

struct NoiseView_Previews: PreviewProvider {
    static var previews: some View {
        NoiseView()
            .environmentObject(AudioConductor.shared)
        
    }
}
