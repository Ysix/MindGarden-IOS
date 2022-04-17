//
//  Stories.swift
//  MindGarden
//
//  Created by Dante Kim on 3/31/22.
//

import SwiftUI
import Storyly
import WidgetKit
var storySegments: Set<String> = ["new users"]
struct Stories: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Stories>) -> UIView {
        let view = UIView(frame: .zero)
        storylyViewProgrammatic.storylyInit = StorylyInit(storylyId: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhY2NfaWQiOjU2OTgsImFwcF9pZCI6MTA2MDcsImluc19pZCI6MTEyNTV9.zW_oJyQ7FTAXHw8MXnEeP4k4oOafFrDGKylUw81pi3I", segmentation: StorylySegmentation(segments: storySegments))
        view.addSubview(storylyViewProgrammatic)
        storylyViewProgrammatic.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            storylyViewProgrammatic.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        storylyViewProgrammatic.storyGroupIconBorderColorNotSeen = [UIColor.systemGreen, UIColor.systemYellow]
        storylyViewProgrammatic.storyGroupTextFont = UIFont(name: "Mada-Medium", size: 12)!
        storylyViewProgrammatic.storyGroupTextColor = UIColor.systemGray

        storylyViewProgrammatic.storyGroupSize = "small"
        storylyViewProgrammatic.delegate = StorylyManager.shared
        storylyViewProgrammatic.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        storylyViewProgrammatic.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        storylyViewProgrammatic.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        storylyViewProgrammatic.storyGroupListStyling = StoryGroupListStyling(edgePadding: 10, paddingBetweenItems: 0)
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        print("updating \(true)")
    }
}
