//
//  MoodElaborate.swift
//  MindGarden
//
//  Created by Vishal Davara on 05/07/22.
//

import SwiftUI
import Amplitude

var moodFirst = false
struct MoodElaborate: View {
    @EnvironmentObject var viewRouter: ViewRouter
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var gardenModel: GardenViewModel
    @State private var selectedSubMood: String = ""
    @State private var playEntryAnimation = false
    @State private var showDetail = false
    
    let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    var body: some View {
        ZStack {
            Clr.darkWhite.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                    .frame(height:50)
                HStack() {
                    Text("\(Date().toString(withFormat: "EEEE, MMM dd"))")
                        .font(Font.fredoka(.regular, size: 20))
                        .foregroundColor(Clr.black2)
                        .padding(.leading,30)
                    Spacer()
                    if UserDefaults.standard.string(forKey: K.defaults.onboarding) != "signedUp" {
                        CloseButton() {
                            Analytics.shared.log(event: .mood_tapped_x)
                            withAnimation {
                                viewRouter.currentPage = .meditate
                            }
                        }.padding(.trailing,20)
                    }
                }
                .frame(width: UIScreen.screenWidth)
                Mood.getMoodImage(mood: userModel.selectedMood)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth:70)
                    .padding(.top,30)
                    .opacity(playEntryAnimation ? 1 : 0)
                    .animation(.spring().delay(0.25), value: playEntryAnimation)
                Text("How would you describe how you’re feeling?")
                    .foregroundColor(Clr.black2)
                    .font(Font.fredoka(.semiBold, size: 28))
                    .multilineTextAlignment(.center)
                    .opacity(playEntryAnimation ? 1 : 0)
                    .animation(.spring().delay(0.25), value: playEntryAnimation)
                ZStack {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(userModel.selectedMood.options, id: \.self) { item in
                            Button {
                                moodFirst = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                UserDefaults(suiteName: "group.io.bytehouse.mindgarden.widget")?.setValue(userModel.selectedMood.title, forKey: "logMood")
                                withAnimation {
                                    selectedSubMood = item
                                    var num = UserDefaults.standard.integer(forKey: "numMoods")
                                    num += 1
                                    UserDefaults.standard.setValue(num, forKey: "numMoods")
                                    let identify = AMPIdentify()
                                        .set("num_moods", value: NSNumber(value: num))
                                    Amplitude.instance().identify(identify ?? AMPIdentify())
#if !targetEnvironment(simulator)
                                    Amplitude.instance().logEvent("tapped_mood", withEventProperties: ["selected_mood": item])
#endif
                                    print("logging, \("tapped_mood_\(item)")")
                                    
                                    
                                    if UserDefaults.standard.string(forKey: K.defaults.onboarding) == "signedUp" {
                                        UserDefaults.standard.setValue("mood", forKey: K.defaults.onboarding)
                                    }
                                    
                                    if let moods = gardenModel.grid[Date().get(.year)]?[Date().get(.month)]?[Date().get(.day)]?["moods"]  as? [[String: String]] {
                                        userModel.coins += max(20/(moods.count * 3), 1)
                                    } else {
                                        userModel.coins += 20
                                    }
                                    
                                    Amplitude.instance().logEvent("mood_elaborate", withEventProperties: ["elaboration": item])
                                    var moodSession = [String: String]()
                                    moodSession["timeStamp"] = Date.getTime()
                                    moodSession["elaboration"] = item
                                    userModel.elaboration = item
                                    moodSession["mood"] = userModel.selectedMood.title
                                
                                    gardenModel.save(key: "moods", saveValue: moodSession, coins: userModel.coins)
                                    if moodFromFinished {
                                        viewRouter.currentPage = .garden
                                        moodFromFinished = false
                                    } else {
                                        viewRouter.currentPage = .journal
                                    }
                                }
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .fill(Clr.darkWhite)
                                        .cornerRadius(16)
                                        .addBorder(.black, width: 1.5, cornerRadius: 16)
                                    Text(item)
                                        .font(Font.fredoka(.medium, size: 14))
                                        .foregroundColor(Clr.black2)
                                        .minimumScaleFactor(0.05)
                                        .lineLimit(1)
                                        .padding(.vertical,10)
                                        .padding(5)
                                }
                            }
                            .padding(.vertical, 5)
                            .offset(y: playEntryAnimation ? 0 : 100)
                            .opacity(playEntryAnimation ? 1 : 0)
                            .animation(.spring().delay(0.25), value: playEntryAnimation)
                            .buttonStyle(NeoPress())
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top,20)
                Spacer()
            }
        }.transition(.move(edge: .trailing))
        .onAppear {
            withAnimation(.easeIn(duration: 0.6)) {
                playEntryAnimation = true
            }
        }
        .onAppearAnalytics(event: .screen_load_mood_elaborate)
    }
}
