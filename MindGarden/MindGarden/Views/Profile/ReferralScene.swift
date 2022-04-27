//
//  ReferralScene.swift
//  MindGarden
//
//  Created by Vishal Davara on 27/04/22.
//

import SwiftUI

struct ReferralScene: View {
    @State private var currentPage = 0
    let inviteContactTitle = "Invite Contacts"
    let shareLinkTitle = "Share Link"
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                Capsule()
                    .fill(Clr.darkWhite)
                    .padding(.horizontal)
                    .overlay(
                        HStack {
                            Img.wateringPot
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40, alignment: .center)
                            Text("0 Referrals sent")
                                .foregroundColor(Clr.superBlack)
                                .font(Font.mada(.semiBold, size: 22))
                        }
                    )
                    .frame(width: UIScreen.screenWidth * 0.7, height: 50)
                    .padding(30)
                    .neoShadow()

                Img.bonfire
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100, alignment: .center)
                
                TabView {
                    ForEach(referralList) { item in
                        Rectangle()
                            .fill(Clr.superWhite)
                            .cornerRadius(25)
                            .padding(20)
                            .shadow(radius: 5)
                            .overlay(
                                VStack {
                                    item.image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 100, height: 100, alignment: .center)
                                        .padding()
                                    Text(item.title)
                                        .padding()
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .foregroundColor(Clr.superBlack)
                                        .font(Font.mada(.semiBold, size: 22))
                                    Text(item.subTitle)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Clr.superBlack)
                                        .font(Font.mada(.regular, size: 16))
                                        .padding()
                                }.padding()
                            )
                            
                            
                    }
                }.frame(height:UIScreen.screenHeight*0.4)
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                                
                Button {
                } label: {
                    HStack {
                        Text(inviteContactTitle)
                            .foregroundColor(Clr.superWhite)
                            .font(Font.mada(.semiBold, size: 16))
                            .padding(.trailing)
                            .lineLimit(1)
                            .minimumScaleFactor(0.05)
                    }
                    .frame(width: UIScreen.screenWidth * 0.7, height:50)
                    .background(Clr.darkgreen)
                        .cornerRadius(25)
                        .onTapGesture {
                            
                        }
                }
                .buttonStyle(BonusPress())
                
                Button {
                } label: {
                    HStack {
                        Text(shareLinkTitle)
                            .foregroundColor(.black)
                            .font(Font.mada(.semiBold, size: 16))
                            .padding(.trailing)
                            .lineLimit(1)
                            .minimumScaleFactor(0.05)
                    }
                    .frame(width: UIScreen.screenWidth * 0.7, height:50)
                    .background(Clr.yellow)
                        .cornerRadius(25)
                        .onTapGesture {
                            
                        }
                }
                .buttonStyle(BonusPress())
                .padding()
                
                Spacer()
            }
            
        }
    }
}
