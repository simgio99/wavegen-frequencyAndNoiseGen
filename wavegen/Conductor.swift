//
//  Conductor.swift
//  tinnitus
//
//  Created by Simone Giordano on 12/03/22.
//

import Foundation
import AudioKit
import SoundpipeAudioKit

class AudioConductor: ObservableObject {
    static let shared = AudioConductor()
    let engine = AudioEngine()
    var fft: FFTTap?
    let FFT_SIZE = 2048
    @Published var mixer: Mixer!
    
    let sampleRate: double_t = 44100
    @Published var frequency: Oscillator = Oscillator()
    var outputLimiter: PeakLimiter!
    let whiteNoise = WhiteNoise(amplitude: 0.5)
    @Published var amplitudes : [Double] = Array(repeating: 0.5, count: 50)
    init() {
        
        
        
        self.frequency = Oscillator(waveform: Table(.sine), frequency: 440, amplitude: 0.5, detuningOffset: 0, detuningMultiplier: 0)
        
        mixer = Mixer(self.frequency, whiteNoise)
        outputLimiter = PeakLimiter(mixer)
        
        engine.output = outputLimiter
        // connect the fft tap to the mic mixer and send the fft data to our updateAmplitudes function on callback (when data is available)
        fft = FFTTap(mixer) { fftData in
            DispatchQueue.main.async {
                self.updateAmplitudes(fftData)
            }
        }
        guard let fft = fft else {
            fatalError()
        }

        //MARK: START AUDIOKIT
        do{
            try engine.start()
            fft.start()
           
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        mixer.volume = 0.5
    }
    func switchWaveform(waveform: TableType) {
        DispatchQueue.main.async { [unowned self] in
        objectWillChange.send()
       
        engine.stop()
        frequency.stop()
        frequency = Oscillator(waveform: Table(waveform), frequency: frequency.frequency, amplitude: 0.5, detuningOffset: 0.0, detuningMultiplier: 0.0)
        
        mixer = Mixer(frequency, whiteNoise)
       
        outputLimiter = PeakLimiter(mixer)
        
        engine.output = outputLimiter
        
        do{
            try engine.start()
            
           
        }
        catch{
            assert(false, error.localizedDescription)
        }
        
        mixer.volume = 0.5
        }
        
        
    }
    /// Analyze fft data and write to our amplitudes array
    func updateAmplitudes(_ fftData: [Float]){
        
        // loop by two through all the fft data
        for i in stride(from: 0, to: self.FFT_SIZE - 1, by: 2) {
            
            // get the real and imaginary parts of the complex number
            let real = fftData[i]
            let imaginary = fftData[i + 1]
            
            let normalizedBinMagnitude = 2.0 * sqrt(real * real + imaginary * imaginary) / Float(self.FFT_SIZE)
            let amplitude = Double(20.0 * log10(normalizedBinMagnitude))
            
            // scale the resulting data
            let scaledAmplitude = (amplitude + 250) / 229.80
            
            // add the amplitude to our array (further scaling array to look good in visualizer)
            DispatchQueue.main.async {
                if(i/2 < self.amplitudes.count){
                    var mappedAmplitude = self.map(n: scaledAmplitude, start1: 0.3, stop1: 0.9, start2: 0.0, stop2: 1.0)
                    
                    // restrict the range to 0.0 - 1.0
                    if (mappedAmplitude < 0) {
                        mappedAmplitude = 0
                    }
                    if (mappedAmplitude > 1.0) {
                        mappedAmplitude = 1.0
                    }
                    
                    self.amplitudes[i/2] = mappedAmplitude
                }
            }
        }
    }
    /// simple mapping function to scale a value to a different range
    func map(n:Double, start1:Double, stop1:Double, start2:Double, stop2:Double) -> Double {
        return ((n-start1)/(stop1-start1))*(stop2-start2)+start2;
    }
}
