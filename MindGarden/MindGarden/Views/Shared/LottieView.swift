//
//  LottieView.swift
//  MindGarden
//
//  Created by Dante Kim on 9/11/21.
//

import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    typealias UIViewType = UIView
    var fileName: String
    let animationView = AnimationView()
    var loopMode: LottieLoopMode = .loop
    var play: Bool = true
    

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
 

        let view = UIView(frame: .zero)
        let animation = Animation.named(fileName)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        if play {
            animationView.play()
        }

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        if fileName == "sloth" {
            animationView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            animationView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        } else {
            view.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            view.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        }
        

        return view
    }
    
    func playAnimation() {
        animationView.play()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}


