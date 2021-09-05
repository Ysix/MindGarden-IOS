//
//  ExperienceScene.swift
//  MindGarden
//
//  Created by Dante Kim on 9/5/21.
//

import SwiftUI

struct ExperienceScene: View {
    @State var selected: String = ""


    init() {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
    }

    var body: some View {
        NavigationView {
            GeometryReader { g in
                let width = g.size.width
                let height = g.size.height
                ZStack {
                    Clr.darkWhite.edgesIgnoringSafeArea(.all).animation(nil)
                    VStack {
                        Text("What is your experience with meditation?")
                            .font(Font.mada(.bold, size: 24))
                            .foregroundColor(Clr.darkgreen)
                            .multilineTextAlignment(.center)
                            .padding(.top, 50)
                        SelectionRow(width: width, height: height, title: "Meditate often", img: Img.redTulips3, selected: $selected)
                        SelectionRow(width: width, height: height, title: "Have tried to meditate", img: Img.redTulips2, selected: $selected)
                        SelectionRow(width: width, height: height, title: "Have never meditated", img: Img.redTulips1, selected: $selected)
                        Button {

                        } label: {
                            Capsule()
                                .fill(Clr.darkWhite)
                                .overlay(
                                    Text("Continue")
                                        .foregroundColor(Clr.darkgreen)
                                        .font(Font.mada(.bold, size: 20))
                                )
                        }.frame(height: 50)
                        .padding()
                        .buttonStyle(NeumorphicPress())
                        Spacer()
                    }
                }
                .navigationBarItems(
                    leading: Img.topBranch.padding(.leading, -20))
                .navigationBarTitle("", displayMode: .inline)

            }
        }
    }

    struct SelectionRow: View {
        var width, height: CGFloat
        var title: String
        var img: Image
        @Binding var selected: String

        var body: some View {
            Button {
                withAnimation {
                    selected = title
                }
            } label: {
                ZStack {
                    Rectangle()
                        .fill(selected == title ? Clr.yellow : Clr.darkWhite)
                        .cornerRadius(15)
                        .frame(height: height * 0.15)
                        .overlay(RoundedRectangle(cornerRadius: 15)
                                    .stroke(Clr.darkgreen, lineWidth: selected == title ? 3 : 0))
                        .padding(.horizontal)
                        .padding(.vertical, 8)

                    HStack(spacing: 50) {
                        Text(title)
                            .font(Font.mada(.bold, size: 24))
                            .foregroundColor(Clr.black1)
                            .padding()
                            .frame(width: width * 0.5, alignment: .leading)
                        img
                    }
                }
            }.buttonStyle(NeumorphicPress())
        }
    }
}

struct ExperienceScene_Previews: PreviewProvider {
    static var previews: some View {
        ExperienceScene()
    }
}
