// Created by Cal Stephens on 12/13/21.
// Copyright © 2021 Airbnb Inc. All rights reserved.

// MARK: - LottieConfiguration

/// Global configuration options for Lottie animations
public struct LottieConfiguration: Hashable {
    public init(
        renderingEngine: RenderingEngineOption = .mainThread,
        decodingStrategy: DecodingStrategy = .codable
    ) {
        self.renderingEngine = renderingEngine
        self.decodingStrategy = decodingStrategy
    }

    /// The global configuration of Lottie,
    /// which applies to all `LottieAnimationView`s by default.
    public static var shared = LottieConfiguration()

    /// The rendering engine implementation to use when displaying an animation
    public var renderingEngine: RenderingEngineOption

    /// The decoding implementation to use when parsing an animation JSON file
    public var decodingStrategy: DecodingStrategy
}

// MARK: - RenderingEngineOption

public enum RenderingEngineOption: Hashable {
    /// Uses the Core Animation engine for supported animations, and falls back to using
    /// the Main Thread engine for animations that use features not supported by the
    /// Core Animation engine.
    case automatic

    /// Uses the specified rendering engine
    case specific(RenderingEngine)

    /// The Main Thread rendering engine, which supports all Lottie features
    /// but runs on the main thread, which comes with some CPU overhead and
    /// can cause the animation to play at a low framerate when the CPU is busy.
    public static var mainThread: RenderingEngineOption { .specific(.mainThread) }

    /// The Core Animation rendering engine, that animates using Core Animation
    /// and has better performance characteristics than the Main Thread engine,
    /// but doesn't support all Lottie features.
    public static var coreAnimation: RenderingEngineOption { .specific(.coreAnimation) }
}

// MARK: - RenderingEngine

/// The rendering engine implementation to use when displaying an animation
public enum RenderingEngine: Hashable {
    /// The Main Thread rendering engine, which supports all Lottie features
    /// but runs on the main thread, which comes with some CPU overhead and
    /// can cause the animation to play at a low framerate when the CPU is busy.
    case mainThread

    /// The Core Animation rendering engine, that animates using Core Animation
    /// and has better performance characteristics than the Main Thread engine,
    /// but doesn't support all Lottie features.
    case coreAnimation
}

// MARK: - RenderingEngineOption + RawRepresentable, CustomStringConvertible

extension RenderingEngineOption: RawRepresentable, CustomStringConvertible {
    // MARK: Lifecycle

    public init?(rawValue: String) {
        if rawValue == "Automatic" {
            self = .automatic
        } else if let engine = RenderingEngine(rawValue: rawValue) {
            self = .specific(engine)
        } else {
            return nil
        }
    }

    // MARK: Public

    public var rawValue: String {
        switch self {
        case .automatic:
            return "Automatic"
        case let .specific(engine):
            return engine.rawValue
        }
    }

    public var description: String {
        rawValue
    }
}

// MARK: - RenderingEngine + RawRepresentable, CustomStringConvertible

extension RenderingEngine: RawRepresentable, CustomStringConvertible {
    // MARK: Lifecycle

    public init?(rawValue: String) {
        switch rawValue {
        case "Main Thread":
            self = .mainThread
        case "Core Animation":
            self = .coreAnimation
        default:
            return nil
        }
    }

    // MARK: Public

    public var rawValue: String {
        switch self {
        case .mainThread:
            return "Main Thread"
        case .coreAnimation:
            return "Core Animation"
        }
    }

    public var description: String {
        rawValue
    }
}

// MARK: - DecodingStrategy

/// How animation files should be decoded
public enum DecodingStrategy: Hashable {
    /// Use Codable. This is the default strategy introduced on Lottie 3.
    case codable

    /// Manually deserialize a dictionary into an Animation.
    /// This should be at least 2-3x faster than using Codable,
    /// but since it's manually implemented, there might be issues while it's experimental.
    case dictionaryBased
}
