//
//  JustBreatheDetailsView.swift
//  JustBreath
//
//  ANIMATION AND MEANING: Guiding Users. In guided meditation, animations are normally used to guide users to complete tasks.
//

import Foundation
import SwiftUI

enum BreathingState {
    case inhale, exhale
}

struct JustBreatheDetailsView: View {
    
    @State private var breatheIn = true
    @State private var breatheOut = false
    
    var body: some View{
        
        VStack{
            Text("just breathe")
                .font(.largeTitle)
            
            Text("conquer the anxiety of life")
                .font(.title)
            
            Text("live in the moment")
                .font(.title2)
            
            ZStack {
                Text("breathe out")
                    .opacity(breatheOut ? 0 : 1) // Opacity animation
                    .animation(.easeInOut(duration: 2).delay(2).repeatForever(autoreverses: true), value: breatheOut)
                
                Text("breathe in")
                    .opacity(breatheIn ? 0 : 1)
                    .scaleEffect(breatheIn ? 0 : 1, anchor: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .animation(.easeInOut(duration: 2).delay(2).repeatForever(autoreverses: true), value: breatheIn)
                
            }
            .onAppear() {
                breatheOut.toggle()
                breatheIn.toggle()
            }
            .padding(.top, 50)
            
        }
    }
}

struct JustBreatheDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        JustBreatheDetailsView()
            .preferredColorScheme(.dark)
    }
}
