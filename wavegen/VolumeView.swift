//
//  VolumeView.swift
//  tinnitus
//
//  Created by Simone Giordano on 12/03/22.
//

import SwiftUI

struct VolumeView: View {
    @EnvironmentObject  var conductor: AudioConductor
    var body: some View {
        HStack {
            ForEach(0..<12) { index in
                
                Rectangle()
                    .frame(width: 20, height: 40 + CGFloat(index*3))
                    .foregroundColor(.accentColor)
                    .shadow(radius: 4)
                    .opacity(conductor.mixer.volume >= Float(index)/12 ? 1.0 : 0.3)
                    .onTapGesture {
                        withAnimation{
                        conductor.mixer.volume = Float(index)/12
                        }
                    }
                                        
                    
            }
        }
    }
}

struct VolumeView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeView().environmentObject(AudioConductor.shared)
    }
}
