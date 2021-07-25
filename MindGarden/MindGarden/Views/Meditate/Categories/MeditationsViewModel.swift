//
//  MeditationsViewModel.swift
//  MindGarden
//
//  Created by Dante Kim on 7/15/21.
//

import SwiftUI
import Combine
import Firebase

struct Meditation: Hashable {
    let title: String
    let description: String
    let belongsTo: String
    let category: Category
    let img: Image
    let type: MeditationType
    let id: Int
    let duration: Float
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    static func == (lhs: Meditation, rhs: Meditation) -> Bool {
        return lhs.title == rhs.title
    }
}

enum MeditationType {
    case single
    case lesson
    case course
}

class MeditationViewModel: ObservableObject {
    @Published var selectedMeditations: [Meditation] = []
    @Published var favoritedMeditations: [Meditation] = [Meditation(title: "Open-Ended Meditation", description: "description", belongsTo: "none", category: .unguided, img: Img.daisy, type: .course, id: 1, duration: 0), Meditation(title: "Timed Meditation", description: "Timed unguided (no talking) meditation, with the option to turn on background noises such as rain. A bell will signal the end of your session.", belongsTo: "none", category: .unguided, img: Img.daisy, type: .course, id: 2, duration: 0)]
    @Published var recentMeditations: [Meditation] = []
    @Published var selectedMeditation: Meditation? = Meditation(title: "Timed Meditation", description: "Timed unguided (no talking) meditation, with the option to turn on background noises such as rain. A bell will signal the end of your session.", belongsTo: "none", category: .unguided, img: Img.daisy, type: .course, id: 0, duration: 0)
    @Published var courseMeditations: [Meditation] = []
    @Published var allMeditations = [Meditation(title: "Open-Ended Meditation", description: "description", belongsTo: "none", category: .unguided, img: Img.daisy, type: .course, id: 1, duration: 0), Meditation(title: "Timed Meditation", description: "Timed unguided (no talking) meditation, with the option to turn on background noises such as rain. A bell will signal the end of your session.", belongsTo: "none", category: .unguided, img: Img.daisy, type: .course, id: 2, duration: 0),  Meditation(title: "1 Minute Meditation", description: "Timed unguided (no talking) meditation for a fixed period, with the option to turn on background noises such as rain. A bell will signal the end of your session.",  belongsTo: "Timed Meditation", category: .unguided, img: Img.daisy, type: .lesson, id: 3, duration: 5), Meditation(title: "2 Minute Meditation", description: "Timed unguided (no talking) meditation for a fixed period, with the option to turn on background noises such as rain. A bell will signal the end of your session.",  belongsTo: "Timed Meditation", category: .unguided, img: Img.daisy, type: .lesson, id: 4, duration: 120), Meditation(title: "5 Minute Meditation", description: "Timed unguided (no talking) meditation for a fixed period, with the option to turn on background noises such as rain. A bell will signal the end of your session.",  belongsTo: "Timed Meditation", category: .unguided, img: Img.daisy, type: .lesson, id: 5, duration: 300)]
    @Published var selectedCategory: Category? = .focus
    var totalTime: Float = 0
    //user needs to meditate at least 5 mins for plant
    var isOpenEnded = false
    @Published var secondsRemaining: Float = 150
    @Published var secondsCounted: Float = 0
    @Published var finishedMeditation: Bool = false
    var timer: Timer = Timer()
    private var validationCancellables: Set<AnyCancellable> = []

    let db = Firestore.firestore()

    var isFavorited: Bool {
        return favoritedMeditations.contains(selectedMeditation!)
    }

    init() {
        print("initing2")
        $selectedCategory
            .sink { [unowned self] value in
                self.selectedMeditations = allMeditations.filter { med in
                    med.category == value
                }
            }
            .store(in: &validationCancellables)

        $selectedMeditation
            .sink { [unowned self] value in 
                if value?.type == .course {
                    selectedMeditations = allMeditations.filter { med in
                        med.belongsTo == value?.title
                    }
                }
                secondsRemaining = value?.duration ?? 0
                totalTime = secondsRemaining
            }
            .store(in: &validationCancellables)
    }

    func favorite() {
        if let email = Auth.auth().currentUser?.email {
            let docRef = db.collection(K.userPreferences).document(email)
            //Read Data from firebase, for syncing
            var favorites: [Int] = []
            docRef.getDocument { (snapshot, error) in
                if let document = snapshot, document.exists {
                    if let favorited = document[K.defaults.favorites] {
                        favorites = favorited as! [Int]
                    }
                    if favorites.contains(where: { id in
                        id == self.selectedMeditation?.id
                    }) {
                        favorites.removeAll { id in
                            id == self.selectedMeditation?.id
                        }
                    } else {
                        favorites.append(self.selectedMeditation?.id ?? -1)
                    }
                }
                self.db.collection(K.userPreferences).document(email).updateData([
                    "favorited": favorites,
                ]) { (error) in
                    if let e = error {
                        print("There was a issue saving data to firestore \(e) ")
                    } else {
                        print("Succesfully saved")
                    }
                }
            }
        }
    }


    //MARK: - timer
    func startCountdown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] _ in
            self.secondsRemaining -= 1
            if secondsRemaining <= 0 {
                stop()
                finishedMeditation = true
                return
            }
        }
        timer.fire()
    }

    func stop() {
        timer.invalidate()
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in self.secondsCounted += 1 }
        timer.fire()
    }


    func secondsToMinutesSeconds (totalSeconds: Float) -> String {
        let minutes = Int(totalSeconds / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return String(format:"%02d:%02d", minutes, seconds)
    }
}
