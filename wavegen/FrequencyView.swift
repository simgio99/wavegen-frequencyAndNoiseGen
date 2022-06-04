//
//  FrequencyView.swift
//  tinnitus
//
//  Created by Simone Giordano on 13/03/22.
//

import SwiftUI
import AudioKit
var WAVE_DICT = ["Sine"     :   TableType.sine,
                 "Square"   :   TableType.square,
                 "Sawtooth" :   TableType.sawtooth,
                 "Triangle" :   TableType.triangle]

struct FrequencyView: View {
    @EnvironmentObject var conductor: AudioConductor
    @State var frequencyValue: Float = 0.0
    private var feedbackGenerator = UINotificationFeedbackGenerator()
    private var waves = ["Sine", "Square", "Sawtooth", "Triangle"]
    @State var selectedWave = "Sine"
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                Spacer()
                Image(systemName: !conductor.frequency.isStarted ? "play.circle.fill" : "stop.circle.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                
                    .onTapGesture {
                       
                        conductor.frequency.isStarted ? conductor.frequency.stop(): conductor.frequency.start()
                        feedbackGenerator.notificationOccurred(.success)
                    }
               
                VolumeView()
                    .padding()
                Spacer()
                Picker("Signal Waveform", selection: $selectedWave) {
                    ForEach(waves, id: \.self) {
                        Text($0)
                    }
                }
                .onChange(of: selectedWave) {wave in
                    conductor.frequency.stop()
                    conductor.objectWillChange.send()
                    conductor.switchWaveform(waveform: WAVE_DICT[wave]!)
                }
                Text("\(Int(frequencyValue)) Hz")
                
                    .font(.title)
                    .fontWeight(.heavy)
                
                Slider(value: $frequencyValue, in: 0...1000, step: 1.0)
                    .onChange(of: frequencyValue) { targetFreq in
                        conductor.frequency.frequency = targetFreq
                    }
                    .padding()
                
                Image(systemName: "music.note.list")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .shadow(radius: 3.0)
                    .foregroundColor(.accentColor)
                Spacer()
            }.onDisappear {
                conductor.frequency.stop()
            }
            .navigationTitle("Frequency Generator")
        }
    }
}

struct FrequencyView_Previews: PreviewProvider {
    @State static var freq: Float = 0.0
    static var previews: some View {
        FrequencyView().environmentObject(AudioConductor.shared)
    }
}
