//
//  LottieColor.swift
//  lottie-swift
//
//  Created by Brandon Withrow on 2/4/19.
//

import Foundation

// MARK: - ColorFormatDenominator

public enum ColorFormatDenominator: Hashable {
    case One
    case OneHundred
    case TwoFiftyFive

    var value: Double {
        switch self {
        case .One:
            return 1.0
        case .OneHundred:
            return 100.0
        case .TwoFiftyFive:
            return 255.0
        }
    }
}

// MARK: - Color

@available(*, deprecated, renamed: "LottieColor", message: """
`Lottie.Color` has been renamed to `LottieColor`, to prevent conflicts with \
the `SwiftUI.Color` type. This notice will be removed in Lottie 4.0.
""")
public typealias Color = LottieColor

// MARK: - LottieColor

public struct LottieColor: Hashable {
    public var r: Double
    public var g: Double
    public var b: Double
    public var a: Double

    public init(r: Double, g: Double, b: Double, a: Double, denominator: ColorFormatDenominator = .One) {
        self.r = r / denominator.value
        self.g = g / denominator.value
        self.b = b / denominator.value
        self.a = a / denominator.value
    }
}
