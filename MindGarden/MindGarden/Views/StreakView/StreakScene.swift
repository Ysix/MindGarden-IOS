//
//  ContentView.swift
//
//
//  Created by Vishal Davara on 28/02/22.
//

import SwiftUI


struct StreakScene: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var gardenModel: GardenViewModel
    @Binding var streakNumber: Int
    var title : String {
        return "\(streakNumber) Day Streak"
    }
    
    var subTitle : String {
        switch streakNumber {
        case 1:  return "👣 A journey of a thousand miles begins with a single step - Lao Tzu"
        case 2:  return "Great Work! Let's make it \(streakNumber+1) in a row \ntomorrow!"
        case 3: return "3 is a magical 🦄 number, and you're on fire!"
        case 4: return "👀 Wow only 22% of our users make it this far"
        case 7: return "🎉 1 Full Week! You're killing it"
        case 10: return "Double digits!!! Only 10% of our users make it this far"
        case 14: return "🎉 2 Full Weeks!! You're a star"
        case 21: return "🎉 3 Full Weeks!! You've offially made it a habit"
        case 30: return "👏 Everyone here on the MindGarden team applauds you"
        case 50: return "🥑 We're half way to a 100!"
        case 60: return "2 Full MONTHS! You're in the 1% of MindGarden meditators"
        default: return "Great Work! Let's make it \(streakNumber+1) in a row \ntomorrow!"
        }
    }
    @State var timeRemaining = 2
    @State private var timer : Timer?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    LottieAnimationView(filename: "fire", loopMode: .playOnce, isPlaying: .constant(true))
                        .frame(width: 500, height: 500, alignment: .center)
                        .opacity(timeRemaining <= 0 ? 0 : 1)
                    LottieAnimationView(filename: "second_part_loop", loopMode: .loop, isPlaying: .constant(true))
                        .frame(width: 500, height: 500, alignment: .center)
                        .opacity(timeRemaining <= 0 ? 1 : 0)
                }
                Spacer()
                Text(title)
                    .streakTitleStyle()
                Text(subTitle)
                    .streakBodyStyle()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 150)
                    .offset(y: -25)
                
                DaysProgressBar()
                Spacer()
                Button {
                    //TODO: implement continue tap event
                    viewRouter.currentPage = .garden
                } label: {
                    Capsule()
                        .fill(Clr.gardenRed)
                        .frame(width: UIScreen.main.bounds.width * 0.85 , height: 58)
                        .overlay(
                            Text("Continue")
                                .font(Font.mada(.bold, size: 24))
                                .foregroundColor(.white)
                        )
                }
                .buttonStyle(NeumorphicPress())
                .shadow(color: Clr.shadow.opacity(0.3), radius: 5, x: 5, y: 5)
                .padding(.top, 50)
            }
            .offset(y: -145)
        }
//        .sheet(isPresented: $isSharePresented) {
//            ReferralView(url: $urlShare2)
//        }
        .onAppear() {
            MGAudio.sharedInstance.stopSound()
            MGAudio.sharedInstance.playSounds(soundFileNames: ["fire_ignite.mp3","fire.mp3"])
            self.animate()
        }
        .onDisappear() {
            MGAudio.sharedInstance.stopSound()
            timer?.invalidate()
        }
//        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { theValue in
//            print("-----> The Value is \(theValue)") // <--- this will be executed
//            if timeRemaining > 0 {
//                timeRemaining -= 1
//            }
//        }

        .background(Clr.darkWhite)
    }
    
    private func animate() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}

struct StreakScene_Previews: PreviewProvider {
    static var previews: some View {
        StreakScene(streakNumber: .constant(3))
    }
}
