//
//  ProfileScene.swift
//  MindGarden
//
//  Created by Dante Kim on 7/6/21.
//

import SwiftUI
import MessageUI
import Purchases
import FirebaseDynamicLinks
import Firebase
import StoreKit
import GTMAppAuth

enum settings {
    case referrals
    case settings
    case journey
}

struct ProfileScene: View {
    @EnvironmentObject var userModel: UserViewModel
    @EnvironmentObject var gardenModel: GardenViewModel
    @EnvironmentObject var viewRouter: ViewRouter
    @ObservedObject var profileModel: ProfileViewModel
    @State private var selection: settings = .settings
    @State private var showNotification = false
    @State private var isSignedIn = true
    @State private var tappedSignedIn = false
    @State private var showMailView = false
    @State private var mailNeedsSetup = false
    @State private var notificationOn = false
    @State private var showNotif = false
    @State private var dateTime = Date()
    @State private var restorePurchase = false
    @State private var numRefs = 0
    @State private var refDate = ""
    @State private var tappedRate = false
    @State private var showSpinner = false

    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()

    var body: some View {
        LoadingView(isShowing: $showSpinner) {
        VStack {
            if #available(iOS 14.0, *) {
                NavigationView {
                    GeometryReader { g in
                        let width = g.size.width
                        let height = g.size.height
                        ZStack {
                            Clr.darkWhite.edgesIgnoringSafeArea(.all).animation(nil)
                            VStack(alignment: .center, spacing: 0) {
                                HStack(alignment: .bottom, spacing: 0) {
                                    SelectionButton(selection: $selection, type: .referrals)
                                        .frame(width: abs(g.size.width/4 - 1))
                                    VStack {
                                        Rectangle().fill(Color.gray.opacity(0.3))
                                            .frame(width: 2, height: 35)
                                            .padding(.top, 10)
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 5)
                                    }.frame(width: 5)
                                    SelectionButton(selection: $selection, type: .settings)
                                        .frame(width: abs(g.size.width/4 - 1))
                                    VStack {
                                        Rectangle().fill(Color.gray.opacity(0.3))
                                            .frame(width: 2, height: 35)
                                            .padding(.top, 10)
                                        Rectangle()
                                            .fill(Color.gray.opacity(0.3))
                                            .frame(height: 5)
                                    }.frame(width: 5)
                                    SelectionButton(selection: $selection, type: .journey)
                                        .frame(width: abs(g.size.width/4 - 1))
                                }.background(Clr.darkWhite).frame(height: 50)
                                    .cornerRadius(12)
                                    .neoShadow()
                                if showNotification && selection == .settings {
                                    Button {
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        showNotification = false
                                    } label: {
                                        Capsule()
                                            .fill(Clr.darkWhite)
                                            .padding(.horizontal)
                                            .overlay(
                                                Text("Go Back")
                                                    .font(Font.mada(.semiBold, size: 20))
                                                    .foregroundColor(Clr.darkgreen)
                                            )
                                            .frame(width: width * 0.35, height: 30)
                                    }
                                    .buttonStyle(NeumorphicPress())
                                    .padding(.top)
                                }

                                if selection == .settings {
                                    if showNotification {
                                        List {
                                            Row(title: "Daily Reminder", img: Image(systemName: "bell.fill"), swtch: true, action: {}, showNotif: $showNotif)
                                                .frame(height: 40)
                                        }.frame(maxHeight: g.size.height * 0.60)
                                            .padding()
                                            .neoShadow()
                                            .transition(.slide)
                                            .animation(.default)
                                    } else {
                                        List {
                                            Row(title: "Notifications", img: Image(systemName: "bell.fill"), action: {
                                                showNotification = true
                                                Analytics.shared.log(event: .profile_tapped_notifications)
                                            }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)
                                            Row(title: "Invite Friends", img: Image(systemName: "arrowshape.turn.up.right.fill"), action: {
                                                Analytics.shared.log(event: .profile_tapped_invite)
                                                actionSheet() }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)
                                            Row(title: "Contact Us", img: Image(systemName: "envelope.fill"), action: {
                                                Analytics.shared.log(event: .profile_tapped_email)
                                                if MFMailComposeViewController.canSendMail() {
                                                    showMailView = true
                                                } else {
                                                    mailNeedsSetup = true
                                                }
                                            }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)
                                            Row(title: "Restore Purchases", img: Image(systemName: "arrow.triangle.2.circlepath"), action: {
                                                Analytics.shared.log(event: .profile_tapped_restore)
                                                Purchases.shared.restoreTransactions { (purchaserInfo, error) in
                                                    if purchaserInfo?.entitlements.all["isPro"]?.isActive == true {
                                                        UserDefaults.standard.setValue(true, forKey: "isPro")
                                                        restorePurchase = true
                                                    } else {
                                                        UserDefaults.standard.setValue(false, forKey: "isPro")
                                                    }
                                                }
                                            }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)
                                            if !UserDefaults.standard.bool(forKey: "isPro") {
                                                Row(title: "Go Pro", img: Image(systemName: "heart.fill"), action: {
                                                    Analytics.shared.log(event: .profile_tapped_goPro)
                                                    withAnimation {
                                                        fromPage = "profile"
                                                        viewRouter.currentPage = .pricing
                                                    }
                                                }, showNotif: $showNotif)
                                                    .frame(height: K.isSmall() ? 30 : 40)
                                            }
                                            Row(title: "Feedback Form", img: Image(systemName: "doc.on.clipboard"), action: {
                                                Analytics.shared.log(event: .profile_tapped_feedback)
                                                if let url = URL(string: "https://tally.so/r/3EB1Bw") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)
                                            Row(title: "Our Roadmap", img: Image(systemName: "map.fill"), action: {
                                                Analytics.shared.log(event: .profile_tapped_roadmap)
                                                if let url = URL(string: "https://mindgarden.nolt.io/") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)

                                            Row(title: "Join the Community", img: Img.redditIcon, action: {
                                                Analytics.shared.log(event: .profile_tapped_reddit)
                                                if let url = URL(string: "https://www.reddit.com/r/MindGarden/") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }, showNotif: $showNotif).frame(height: 40)
                                                .frame(height: K.isSmall() ? 30 : 40)

                                            Row(title: "Daily Motivation", img: Img.instaIcon, action: {
                                                Analytics.shared.log(event: .profile_tapped_instagram)
                                                if let url = URL(string: "https://www.instagram.com/mindgardn/") {
                                                    UIApplication.shared.open(url)
                                                }
                                            }, showNotif: $showNotif)
                                                .frame(height: K.isSmall() ? 30 : 40)
                                        }.frame(maxHeight: g.size.height * (K.isSmall() ? 0.725 : 0.8))
                                            .padding([.horizontal])
                                            .neoShadow()
                                    }
                                } else if selection == .journey {
                                    // Journey
                                    ZStack {
                                        Rectangle()
                                            .fill(Clr.darkWhite)
                                            .cornerRadius(12)
                                            .neoShadow()
                                        VStack(alignment: .leading) {
                                            HStack(alignment: .center, spacing: 10) {
                                                Image(systemName: "calendar")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                Text("MindGarden Journey Began")
                                                    .font(Font.mada(.regular, size: 20))
                                                    .foregroundColor(Clr.black1)
                                                    .padding(.top, 3)
                                            }.frame(width: abs(width - 75), alignment: .leading)
                                                .frame(height: 25)
                                            Text("\(profileModel.signUpDate)")
                                                .font(Font.mada(.bold, size: 34))
                                                .foregroundColor(Clr.darkgreen)
                                        }
                                    }.frame(width: abs(width - 75), height: height/6)
                                        .padding()
                                        .padding(.leading)
                                    ZStack {
                                        Rectangle()
                                            .fill(Clr.darkWhite)
                                            .cornerRadius(12)
                                            .neoShadow()
                                        VStack(alignment: .leading) {
                                            HStack(alignment: .center, spacing: 10) {
                                                Image(systemName: "clock")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                Text("Total Time Meditated")
                                                    .font(Font.mada(.regular, size: 20))
                                                    .foregroundColor(Clr.black1)
                                                    .padding(.top, 3)
                                            }.frame(width: abs(width - 100), alignment: .leading)
                                                .frame(height: 25)
                                                .onTapGesture(count: 4) {
                                                    print("close")
                                                    UserDefaults.standard.setValue(true, forKey: "trippleTapped")
                                                    UserDefaults.standard.setValue(true, forKey: "isPro")
                                                }
                                            HStack {
                                                Text(profileModel.totalMins/60 == 0 ? "0.5" : "\(profileModel.totalMins/60)")
                                                    .font(Font.mada(.bold, size: 40))
                                                    .foregroundColor(Clr.darkgreen)
                                                Text("minutes")
                                                    .font(Font.mada(.regular, size: 28))
                                                    .foregroundColor(Clr.black1)
                                            }
                                        }
                                    }.frame(width: abs(width - 75), height: height/6)
                                        .padding()
                                        .padding(.leading)
                                    ZStack {
                                        Rectangle()
                                            .fill(Clr.darkWhite)
                                            .cornerRadius(12)
                                            .neoShadow()
                                        VStack(alignment: .leading) {
                                            HStack(alignment: .center, spacing: 10) {
                                                Image(systemName: "star.fill")
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fit)
                                                Text("Total Meditation Sessions")
                                                    .font(Font.mada(.regular, size: 20))
                                                    .foregroundColor(Clr.black1)
                                                    .padding(.top, 3)
                                            }.frame(width: abs(width - 100), alignment: .leading)
                                                .frame(height: 25)
                                            HStack {
                                                Text("\(profileModel.totalSessions)")
                                                    .font(Font.mada(.bold, size: 40))
                                                    .foregroundColor(Clr.darkgreen)
                                                Text("Sessions")
                                                    .font(Font.mada(.semiBold, size: 28))
                                                    .foregroundColor(Clr.black1)
                                            }
                                        }
                                    }.frame(width: abs(width - 75), height: height/6)
                                        .padding()
                                        .padding(.leading)
                                } else {
                                    VStack {
                                        (Text("🎁 Get & give 2 weeks free of MindGarden Pro for every friend that signs up using your link for a ")
                                            .font(Font.mada(.bold, size: 20))
                                            .foregroundColor(Clr.black2)
                                        + Text("limited time")
                                            .font(Font.mada(.bold, size: 20))
                                            .foregroundColor(Clr.darkgreen))
                                            .multilineTextAlignment(.leading)
                                            .offset(y: -20)
                                        ZStack {
                                            Rectangle()
                                                .fill(Clr.darkWhite)
                                                .cornerRadius(12)
                                                .frame(width: abs(width - 100))
                                                .neoShadow()
                                            VStack(alignment: .leading) {
                                                HStack(alignment: .center, spacing: 10) {
                                                    Image(systemName: "number")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .foregroundColor(Clr.darkgreen)
                                                    Text("Total Referrals")
                                                        .font(Font.mada(.regular, size: 20))
                                                        .foregroundColor(Clr.black1)
                                                        .padding(.top, 3)
                                                }.frame(width: abs(width - 150), alignment: .leading)
                                                    .frame(height: 25)
                                                HStack {
                                                    Text("\(numRefs)")
                                                        .font(Font.mada(.bold, size: 40))
                                                        .foregroundColor(Clr.darkgreen)
                                                    Text("Referrals")
                                                        .font(Font.mada(.semiBold, size: 28))
                                                        .foregroundColor(Clr.black1)
                                                }.frame(width: abs(width - 150), alignment: .leading)
                                                HStack(alignment: .center, spacing: 10) {
                                                    Image(systemName: "calendar")
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                    Text("Pro Expires On:")
                                                        .font(Font.mada(.regular, size: 20))
                                                        .foregroundColor(Clr.black1)
                                                        .padding(.top, 3)
                                                }.frame(width: abs(width - 150), alignment: .leading)
                                                    .frame(height: 25)
                                                Text("\(refDate)")
                                                    .font(Font.mada(.bold, size: 24))
                                                    .foregroundColor(Clr.darkgreen)
                                                    .frame(width: abs(width - 150), alignment: .leading)
                                            }.padding()
                                        }.frame(width: abs(width - 100), height: height/4)
                                            .padding(.horizontal)
                                    }
                                    .frame(width: abs(width - 100))
                                    .offset(y: 40)
//                                    ZStack {
//                                        Rectangle()
//                                            .fill(Clr.darkWhite)
//                                            .cornerRadius(12)
//                                            .neoShadow()
//                                        VStack(alignment: .leading) {
//                                            HStack(alignment: .center, spacing: 10) {
//                                                Image(systemName: "number")
//                                                    .resizable()
//                                                    .aspectRatio(contentMode: .fit)
//                                                Text("Total Referrals")
//                                                    .font(Font.mada(.regular, size: 20))
//                                                    .foregroundColor(Clr.black1)
//                                                    .padding(.top, 3)
//                                            }.frame(width: abs(width - 100), alignment: .leading)
//                                                .frame(height: 25)
//                                            HStack {
//
//                                            }
//                                        }
//                                    }.frame(width: abs(width - 75), height: height/6)
//                                        .padding()
//                                        .padding(.leading)

                                }
                                if selection == .referrals {
                                    Button {
                                        Analytics.shared.log(event: .profile_tapped_refer_friend)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        actionSheet()
                                    } label: {
                                        Capsule()
                                            .fill(Clr.darkgreen)
                                            .neoShadow()
                                            .overlay(Text("Refer a friend")
                                                        .foregroundColor(.white)
                                                        .font(Font.mada(.bold, size: 24)))
                                    }
                                    .frame(width: abs(width - 100), height: 50, alignment: .center)
                                    .padding(.top, 80)
                                    if !tappedRate {
                                            Text("⭐️ Rate the app for an extra free week of Pro")
                                                .foregroundColor(Clr.darkgreen)
                                                .font(Font.mada(.bold, size: 20))
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(2)
                                                .padding(.top)
                                                .frame(width: abs(width - 100))
                                        Button {
                                            Analytics.shared.log(event: .profile_tapped_rate)
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                            if let windowScene = UIApplication.shared.windows.first?.windowScene { SKStoreReviewController.requestReview(in: windowScene)
                                                let plusIndex = userModel.referredStack.indexInt(of: "+") ?? 0
                                                refDate =  userModel.referredStack.substring(to: plusIndex)
                                                numRefs = Int(userModel.referredStack.substring(from: plusIndex + 1)) ?? 0
                                            }
                                            tappedRate = true
                                            userModel.updateReffered(refDate: refDate, numRefs: numRefs)
                                        } label: {
                                            Capsule()
                                                .fill(Clr.yellow)
                                                .neoShadow()
                                                .overlay(
                                                    Text("Rate MindGarden")
                                                        .foregroundColor(Clr.darkgreen)
                                                        .font(Font.mada(.bold, size: 20))
                                                        .minimumScaleFactor(0.5)
                                                        .lineLimit(2)
                                                        .padding(9))
                                        }
                                        .frame(width: abs(width - 100), height: 50, alignment: .center)
                                        .padding(.top, 10)
                                    }
                                } else {
                                    Button {
                                        Analytics.shared.log(event: .profile_tapped_logout)
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        profileModel.signOut()
                                        UserDefaults.standard.setValue(false, forKey: K.defaults.loggedIn)
                                        UserDefaults.standard.setValue("White Daisy", forKey: K.defaults.selectedPlant)
                                        UserDefaults.standard.setValue(false, forKey: "isPro")
                                        withAnimation {
                                            viewRouter.currentPage = .authentication
                                        }
                                    } label: {
                                        Capsule()
                                            .fill(Clr.redGradientBottom)
                                            .neoShadow()
                                            .overlay(Text("Sign Out").foregroundColor(.white).font(Font.mada(.bold, size: 24)))
                                    }
                                    .frame(width: abs(width - 100), height: 50, alignment: .center)
                                    .padding(.top, K.isSmall() ? 5 : 15)
                                }
                                Spacer()
                            }.navigationBarTitle("\(userModel.name)", displayMode: .inline)
                                .frame(width: width, height: height)
                                .background(Clr.darkWhite)
                        }
                    }
                }
                .onAppear {
                    // Set the default to clear
                    UITableView.appearance().backgroundColor = .clear
                    UITableView.appearance().showsVerticalScrollIndicator = false
//                    UITableView.appearance().isScrollEnabled = false
                    profileModel.update(userModel: userModel, gardenModel: gardenModel)
                }
                .sheet(isPresented: $showMailView) {
                    MailView()
                }
                .fullScreenCover(isPresented: $showNotif) {
                    NotificationScene(fromSettings: true)
                }
                .alert(isPresented: $mailNeedsSetup) {
                    Alert(title: Text("Your mail is not setup"), message: Text("Please try manually emailing team@mindgarden.io thank you."))
                }
                .alert(isPresented: $restorePurchase) {
                    Alert(title: Text("Success!"), message: Text("You've restored MindGarden Pro"))
                }
                .onAppearAnalytics(event: .screen_load_profile)
            } else {
                // Fallback on earlier versions
            }
        }
        }.onAppear {
            tappedRate = UserDefaults.standard.bool(forKey: "tappedRate")
            if userModel.referredStack == "" {
                if !UserDefaults.standard.bool(forKey: "isPro") {
                    refDate = "No referrals"
                } else {
                    refDate = "Pro account is active"
                }
                numRefs = 0
            } else {
                let plusIndex = userModel.referredStack.indexInt(of: "+") ?? 0
                refDate =  userModel.referredStack.substring(to: plusIndex)
                numRefs = Int(userModel.referredStack.substring(from: plusIndex + 1)) ?? 0
            }
            if UserDefaults.standard.bool(forKey: "isPro") {
                selection = .settings
            } else {
                selection = .referrals
            }
        }
    }

    func actionSheet() {
        guard var urlShare2 = URL(string: "https://mindgarden.io") else { return }
        if selection == .referrals {
            showSpinner = true
            guard let uid = Auth.auth().currentUser?.email else { return }
            guard let link = URL(string: "https://mindgarden.io?referral=\(uid)") else { return }
            let referralLink = DynamicLinkComponents(link: link, domainURIPrefix: "https://mindgarden.page.link")


            if let myBundleId = Bundle.main.bundleIdentifier {
                referralLink?.iOSParameters = DynamicLinkIOSParameters(bundleID: myBundleId)
                referralLink?.iOSParameters?.minimumAppVersion = "1.18"
                referralLink?.iOSParameters?.appStoreID = "1588582890"
            }

            let newDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())
            let newDateString = dateFormatter.string(from: newDate ?? Date())
            referralLink?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
            referralLink?.socialMetaTagParameters?.title = "\(userModel.name) invited you to MindGarden"
            referralLink?.socialMetaTagParameters?.descriptionText = "📱 Download the app by \(newDateString) to claim your 2 free weeks of PRO! ⬇️ Keep it checked"
            guard let imgUrl = URL(string: "https://i.ibb.co/1GW6YxY/MINDGARDEN.png") else { return }
            referralLink?.socialMetaTagParameters?.imageURL = imgUrl
            referralLink?.shorten { (shortURL, warnings, error) in
              if let error = error {
                print(error.localizedDescription)
                return
              }
                urlShare2 = shortURL!
                let activityVC = UIActivityViewController(activityItems: [urlShare2], applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: {
                    showSpinner = false
                })
            }
        } else {
            let activityVC = UIActivityViewController(activityItems: [urlShare2], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
    }


    struct Row: View {
        var title: String
        var img: Image
        var swtch: Bool = false
        var action: () -> ()
        @State var notifOn = false
        @Binding var showNotif: Bool

        var body: some View {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                action()
            } label: {
                VStack(spacing: 20) {
                    HStack() {
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 20)
                            .offset(x: -10)
                            .foregroundColor(Clr.darkgreen)
                        Text(title)
                            .font(Font.mada(.medium, size: 20))
                            .foregroundColor(Clr.black1)
                        Spacer()
                        if title == "Notifications" {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        } else if swtch {
                            if #available(iOS 14.0, *) {
                                Toggle("", isOn: $notifOn)
                                    .onChange(of: notifOn) { val in
                                        UserDefaults.standard.setValue(val, forKey: "notifOn")
                                        if val {
                                            Analytics.shared.log(event: .profile_tapped_toggle_on_notifs)
                                            showNotif = true
                                        } else { //turned off
                                            Analytics.shared.log(event: .profile_tapped_toggle_off_notifs)
                                            UserDefaults.standard.setValue(false, forKey: "notifOn")
                                            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                                        }
                                    }.toggleStyle(SwitchToggleStyle(tint: Clr.gardenGreen))
                                    .frame(width: UIScreen.main.bounds.width * 0.1)
                            }
                        }
                    }.padding()
                }
                .listRowBackground(Clr.darkWhite)
            }.onAppear {
                notifOn = UserDefaults.standard.bool(forKey: "notifOn")
            }
        }
    }
}

struct ProfileScene_Previews: PreviewProvider {
    static var previews: some View {
        ProfileScene(profileModel: ProfileViewModel())
    }
}

struct SelectionButton: View {
    @Binding var selection: settings
    var type: settings

    var body: some View {
        VStack {
            Spacer()
            Button {
                if type == .settings {
                    Analytics.shared.log(event: .profile_tapped_settings)
                } else if type == .journey{
                    Analytics.shared.log(event: .profile_tapped_journey)
                } else {
                    Analytics.shared.log(event: .profile_tapped_refer)
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                selection = type
            } label: {
                HStack(alignment: .top) {
                    Text(type == .settings ?  "Settings" : type == .referrals ? "Referrals" : "Journey")
                        .font(Font.mada(.bold, size: 18))
                        .foregroundColor(selection == type ? Clr.brightGreen : Clr.black1)
                        .padding(.top, 10)
                }
            }.frame(height: 25, alignment: .center)
            Spacer()
            Rectangle()
                .fill(selection == type ?  Clr.brightGreen : Color.gray.opacity(0.3))
                .frame(height: 8)
        }.frame(height: 52)

    }
}
