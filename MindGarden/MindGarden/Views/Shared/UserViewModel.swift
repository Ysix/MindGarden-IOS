//
//  UserViewModel.swift
//  MindGarden
//
//  Created by Dante Kim on 7/25/21.
//

import Foundation
import Combine
import Firebase
import FirebaseFirestore
import Purchases
import WidgetKit

class UserViewModel: ObservableObject {
    @Published var ownedPlants: [Plant] = [Plant(title: "White Daisy", price: 100, selected: false, description: "With their white petals and yellow centers, white daisies symbolize innocence and the other classic daisy traits, such as babies, motherhood, hope, and new beginnings.", packetImage: Img.daisyPacket, one: Img.daisy1, two: Img.daisy2, coverImage: Img.daisy3, head: Img.daisyHead, badge: Img.daisyBadge)]
    @Published var selectedPlant: Plant?
    @Published var willBuyPlant: Plant?
    @Published var streakFreeze = 0
    @Published var potion = ""
    @Published var chest = ""
    @Published var triggerAnimation = false
    @Published var timeRemaining =  TimeInterval()
    @Published var isPotion : Bool = false
    @Published var isChest : Bool = false
    @Published var coins: Int = 0
    @Published var plantedTrees = [String]()
    @Published var showPlantAnimation = false
    @Published var showCoinAnimation = false
    @Published var completedMeditations: [String] = []
    @Published var show50Off = false
    @Published var referredCoins: Int = 0
    @Published var userCoinCollectedLevel: Int = 0
    private var validationCancellables: Set<AnyCancellable> = []

    var name: String = ""
    var joinDate: String = ""
    var greeting: String = ""
    var referredStack: String = ""
    let db = Firestore.firestore()
    var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter
    }()

    init() {
        getSelectedPlant()
        getGreeting()
        updateTimeRemaining()
    }
    
    func updateTimeRemaining() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        if let date = dateFormatter.date(from: potion), date > Date() {
            timeRemaining = date - Date()
            isPotion = timeRemaining > 0
        } else if let date = dateFormatter.date(from: chest), date > Date() {
            timeRemaining = date - Date()
            isChest = timeRemaining > 0
        }
    }

    func getSelectedPlant() {
        if let plantTitle = UserDefaults.standard.string(forKey: K.defaults.selectedPlant) {
            self.selectedPlant = Plant.allPlants.first(where: { plant in
                return plant.title == plantTitle
            })
        }
    }
    
    func saveIAP() {
        if let email = Auth.auth().currentUser?.email {
            //Read Data from firebase, for syncing
            self.db.collection(K.userPreferences).document(email).updateData([
                "streakFreeze": streakFreeze,
                "potion": potion,
                "chest": chest
            ]) { (error) in
                if let e = error {
                    print("There was a issue saving data to firestore \(e) ")
                } else {
                    print("Succesfully saved meditations")
                }
            }
        } else {
            UserDefaults.standard.setValue(potion, forKey: "potion")
            UserDefaults.standard.setValue(chest, forKey: "chest")
            UserDefaults.standard.setValue(streakFreeze, forKey: "streakFreeze")
        }
    }

    func updateSelf() {
        if let defaultName = UserDefaults.standard.string(forKey: "name") {
            self.name = defaultName
        }
        
        if let coins = UserDefaults.standard.value(forKey: "coins") as? Int {
            self.coins = coins
        }

        
        if let email = Auth.auth().currentUser?.email {
            db.collection(K.userPreferences).document(email).getDocument { [self] (snapshot, error) in
                if let document = snapshot, document.exists {
                    if let joinDate = document[K.defaults.joinDate] as? String {
                        self.joinDate = joinDate
                    }

                    if let coins = document[K.defaults.coins] as? Int {
                        self.coins = coins
                        UserDefaults.standard.set(self.coins, forKey: "coins")
                    }

                    if let name = document["name"] as? String {
                        self.name = name
                        UserDefaults.standard.set(self.name, forKey: "name")
                        tappedSignIn = false
                    }
        
                    
                    if let strFreeze = document["streakFreeze"] as? Int {
                        self.streakFreeze = strFreeze
                    }
                    
                    if let fbPotion = document["potion"] as? String {
                        self.potion = fbPotion
                    }
                    
                    if let fbChest = document["chest"] as? String {
                        self.chest = fbChest
                    }
                    if let fbTrees = document["plantedTrees"] as? [String] {
                        self.plantedTrees = fbTrees
                    }
                    
                    if let refCoins = document["lastReferred"] as? Int {
                        self.referredCoins = refCoins
                    }

                    if let fbPlants = document[K.defaults.plants] as? [String] {
                        self.ownedPlants = Plant.allPlants.filter({ plant in
                            return fbPlants.contains(where: { str in
                                plant.title == str
                            })
                        })
                    }
                    
                    if let stack = document["referredStack"] as? String {
                        self.referredStack = stack
                        let plusIndex = stack.indexInt(of: "+") ?? 0
                        let numRefs = Int(stack.substring(from: plusIndex + 1)) ?? 0
                        
                        if numRefs > UserDefaults.standard.integer(forKey: "numRefs") {
                            showCoinAnimation = true
                            UserDefaults.standard.setValue(numRefs, forKey: "numRefs")
                        }
                        
                        if numRefs >= 1 && !UserDefaults.standard.bool(forKey: "referPlant") && !ownedPlants.contains(where: { plt in
                            plt.title == "Venus Fly Trap"
                        }) {
                            willBuyPlant = Plant.badgePlants.first(where: {$0.title == "Venus Fly Trap"})
                            buyPlant(unlockedStrawberry: true)
                            UserDefaults.standard.setValue(true, forKey: "referPlant")
                            showPlantAnimation = true
                        }
                    }
                    
                    if let completedMeditations = document[K.defaults.completedMeditations] as? [String] {
                        self.completedMeditations = completedMeditations
                        UserDefaults.standard.setValue(completedMeditations, forKey: K.defaults.completedMeditations)
                    }
                    
                    if let level = document[K.defaults.userCoinCollectedLevel] as? Int {
                        self.userCoinCollectedLevel = level
                        UserDefaults.standard.setValue(level, forKey: K.defaults.userCoinCollectedLevel)
                    }
                    
                    self.updateTimeRemaining()
                }
            }
        } else {
            if let plants = UserDefaults.standard.value(forKey: K.defaults.plants) as? [String] {
                self.ownedPlants = Plant.plants.filter({ plant in
                    return plants.contains(where: { str in
                        plant.title == str
                    })
                })
                let badgePlants = Plant.badgePlants.filter({ plant in
                    return plants.contains(where: { str in
                        plant.title == str
                    })
                })
                    self.ownedPlants += badgePlants
            }
            
            if let name = UserDefaults.standard.string(forKey: K.defaults.name) {
                self.name = name
            }
            
            if let joinDate = UserDefaults.standard.string(forKey: "joinDate") {
                self.joinDate = joinDate
            }
            if let potion = UserDefaults.standard.value(forKey: "potion") as? String {
                self.potion = potion
            }
            if let chest = UserDefaults.standard.value(forKey: "chest") as? String {
                self.chest = chest
            }
            if let completedMeditations = UserDefaults.standard.value(forKey: K.defaults.completedMeditations) as? [String] {
                self.completedMeditations = completedMeditations
            }
            
            if let level = UserDefaults.standard.value(forKey: K.defaults.userCoinCollectedLevel) as? Int {
                self.userCoinCollectedLevel = level
            }
            
            self.streakFreeze = UserDefaults.standard.integer(forKey: "streakFreeze")
            
            self.coins = UserDefaults.standard.integer(forKey: "coins")
            self.updateTimeRemaining()
        }

        //set selected plant
        selectedPlant = Plant.allPlants.first(where: { plant in
            return plant.title == UserDefaults.standard.string(forKey: K.defaults.selectedPlant)
        })
    }

    
    func finishedMeditation(id:String){
        self.completedMeditations.append(id)
        if let email = Auth.auth().currentUser?.email {
            self.db.collection(K.userPreferences).document(email).updateData([
                K.defaults.completedMeditations: self.completedMeditations])
        }
        UserDefaults.standard.setValue(self.completedMeditations, forKey: K.defaults.completedMeditations)
    }
    
    
    func getCourseCounter(title:String) -> Int {
        return Meditation.allMeditations.filter { $0.belongsTo == title }.filter { self.completedMeditations.contains("\($0.id)") }.count
    }

    private func buyBonsai() {
        if !UserDefaults.standard.bool(forKey: "bonsai") {
            userWentPro = true
            if !ownedPlants.contains(Plant.badgePlants.first(where: { plant in plant.title == "Bonsai Tree" })!) {
                willBuyPlant = Plant.badgePlants.first(where: { plant in plant.title == "Bonsai Tree" })
                buyPlant(unlockedStrawberry: true)
            }
            UserDefaults.standard.setValue(true, forKey: "bonsai")
        }

    }
    
     func modTitle() -> String {
        let title = selectedPlant?.title ?? "s"
        let endIdx = title.count
        if title[endIdx - 1] == "s" {
            return title
        } else {
            return "a " + title
        }
    }

    func checkIfPro() {
        Purchases.shared.purchaserInfo { [self] (purchaserInfo, error) in
            if purchaserInfo?.entitlements.all["isPro"]?.isActive == true {
                buyBonsai()
                UserDefaults.standard.setValue(true, forKey: "isPro")
                UserDefaults(suiteName: "group.io.bytehouse.mindgarden.widget")?.setValue(true, forKey: "isPro")
                WidgetCenter.shared.reloadAllTimelines()
            } else {
                if UserDefaults.standard.bool(forKey: "freeTrial") && !UserDefaults.standard.bool(forKey: "freeTrialTo50"){
                    // cancelled free trial
                    show50Off = true
                }
                
                if !UserDefaults.standard.bool(forKey: "promoCode") {
                    UserDefaults.standard.setValue(false, forKey: "isPro")
                    if referredStack != "" {
                        let plusIndex = referredStack.indexInt(of: "+") ?? 0
                        if dateFormatter.date(from: referredStack.substring(to: plusIndex)) ?? Date() > Date() {
                            UserDefaults.standard.setValue(true, forKey: "isPro")
                        } else {
                            UserDefaults.standard.setValue(false, forKey: "isPro")
                        }
                    }
                    UserDefaults(suiteName: "group.io.bytehouse.mindgarden.widget")?.setValue(true, forKey: "isPro")
                    WidgetCenter.shared.reloadAllTimelines()
//                    if let email = Auth.auth().currentUser?.email {
//                        Firestore.firestore().collection(K.userPreferences).document(email).updateData([
//                            "isPro": isPro,
//                        ]) { (error) in
//                            if let e = error {
//                                print("There was a issue saving data to firestore \(e) ")
//                            } else {
//                                print("Succesfully saved user is pro")
//                            }
//                        }
//                    }
                } else {
                    buyBonsai()
                }
            }
        }
    }


    func getGreeting() {
        let hour = Calendar.current.component( .hour, from:Date() )

        if hour < 11 {
            greeting = "Good Morning"
        }
        else if hour < 16 {
            greeting = "Good Afternoon"
        }
        else {
            greeting = "Good Evening"
        }
    }

    func buyPlant(isUnlocked: Bool = false, unlockedStrawberry: Bool = false, realTree: Bool = false) {
        if let plant = willBuyPlant {
            if !unlockedStrawberry {
                self.coins -= willBuyPlant?.price ?? 0
                selectedPlant = willBuyPlant
            }
            
            if unlockedStrawberry {
                triggerAnimation = true
            }
            
            ownedPlants.append(plant)
            
            if realTree {
                Analytics.shared.log(event: .store_bought_real_tree)
                self.plantedTrees.append(dateFormatter.string(from: Date()))
            }

            var finalPlants: [String] = [String]()
            if let email = Auth.auth().currentUser?.email {
                let docRef = db.collection(K.userPreferences).document(email)
                docRef.getDocument { (snapshot, error) in
                    if let document = snapshot, document.exists {
                        if let plants = document[K.defaults.plants] as? [String] {
                            finalPlants = plants
                        }
                        finalPlants.append(plant.title)
                    }
                    
                    let uniquePlants = Array<String>(Set(finalPlants))
                    self.db.collection(K.userPreferences).document(email).updateData([
                        K.defaults.plants: uniquePlants,
                        K.defaults.coins: self.coins,
                        "plantedTrees": self.plantedTrees
                    ]) { (error) in
                        if let e = error {
                            print("There was a issue saving data to firestore \(e) ")
                        } else {
                            print("Succesfully saved user model")
                        }
                    }
                }
            } else {
                if let plants = UserDefaults.standard.value(forKey: K.defaults.plants) as? [String] {
                    var newPlants = plants
                    newPlants.append(plant.title)
                    UserDefaults.standard.setValue(newPlants, forKey: K.defaults.plants)
                } else {
                    var newPlants = ["White Daisy"]
                    newPlants.append(plant.title)
                    UserDefaults.standard.setValue(newPlants, forKey: K.defaults.plants)
                }
                UserDefaults.standard.setValue(self.coins, forKey: K.defaults.coins)
            }
        }
    }
    
    func getRefered(){
        if let email = Auth.auth().currentUser?.email, referredCoins > 0 {
            self.db.collection(K.userPreferences).document(email).updateData([
                "lastReferred": 0
            ]) { (error) in
                if let e = error {
                    print("There was a issue saving data to firestore \(e) ")
                } else {
                    print("Succesfully saved user model")
                }
            }
        }
    }
    
    func updateCoins(plusCoins: Int) {
        coins += plusCoins
        userCoinCollectedLevel += 1
        UserDefaults.standard.setValue(coins, forKey: K.defaults.coins)
        UserDefaults.standard.setValue(userCoinCollectedLevel, forKey: K.defaults.userCoinCollectedLevel)
        if let email = Auth.auth().currentUser?.email {
            self.db.collection(K.userPreferences).document(email).updateData([
                K.defaults.coins:coins,
                K.defaults.userCoinCollectedLevel:userCoinCollectedLevel
            ]) { (error) in
                if let e = error {
                    print("There was a issue saving data to firestore \(e) ")
                } else {
                    print("Succesfully saved coin")
                }
            }
        }
    }
}
