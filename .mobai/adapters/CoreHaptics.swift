// Generated from MobAI normalized Apple SDK IR.
// Module: CoreHaptics
// Extracted SDK modules: CoreHaptics, CoreHaptics.CHHapticDeviceCapability, CoreHaptics.CHHapticEngine, CoreHaptics.CHHapticErrors, CoreHaptics.CHHapticEvent, CoreHaptics.CHHapticParameter, CoreHaptics.CHHapticPattern, CoreHaptics.CHHapticPatternPlayer
// This project copy is editable; catalog expansion only appends missing declarations.

import Foundation




// mobai-ir-declaration: CHHapticDeviceCapability
public protocol CHHapticDeviceCapability {
    var supportsHaptics: Bool { get }
    var supportsAudio: Bool { get }
}

private final class _MobAICHHapticDeviceCapability: CHHapticDeviceCapability {
    // The preview has no haptics hardware, so the app takes its no-haptics path.
    var supportsHaptics: Bool { false }
    var supportsAudio: Bool { false }
    init() {}
}

// mobai-ir-declaration: CHHapticEngine
public class CHHapticEngine {
    @discardableResult
    public static func capabilitiesForHardware() -> any CHHapticDeviceCapability { _MobAICHHapticDeviceCapability() }

    public init() throws {}
}
