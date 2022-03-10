import Foundation
import Capacitor
import AudioToolbox

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */

/// Sound completion proc - this is the real magic, we simply calculate how long it took for the sound to finish playing
/// In silent mode, playback will end very fast (but not in zero time)
func SoundMuteNotificationCompletionProc(_ ssID: SystemSoundID, _ clientData: UnsafeMutableRawPointer?) {
    let plugin = unsafeBitCast(clientData, to: MuteSwitchPlugin.self)
    let elapsed = Date.timeIntervalSinceReferenceDate - plugin.interval
    let isMute = elapsed < 0.1 // Should have been 0.5 sec, but it seems to return much faster (0.3something)
    plugin.isPlaying = false
    if (plugin.isMute != isMute){
        plugin.isMute = isMute
        plugin.notifyListeners("onChange", data: ["isMute": isMute])
    }
    plugin.scheduleCall()
}

@objc(MuteSwitchPlugin)
public class MuteSwitchPlugin: CAPPlugin {
    /// Find out how fast the completion call is called
    public var interval: TimeInterval = 0.0
        
    /// Our silent sound (0.5 sec)
    public var soundId: SystemSoundID = 0
        
    /// Is paused?
    public var isPaused = false
    
    /// Currently playing? used when returning from the background (if went to background and foreground really quickly)
    public var isPlaying = false
    
    /// Is mute?
    public var isMute = false

    public override func load() {
        let url = Bundle(for: Self.self).url(forResource: "mute", withExtension: "caf")
        if let anUrl = url as CFURL? {
            let data = unsafeBitCast(self, to: UnsafeMutablePointer<Void>.self)
            let status = AudioServicesCreateSystemSoundID(anUrl, &soundId);
            if status == kAudioServicesNoError {
                var yes: UInt32 = 1
                AudioServicesAddSystemSoundCompletion(soundId, nil, nil, SoundMuteNotificationCompletionProc, data)
                AudioServicesSetProperty(kAudioServicesPropertyIsUISound, UInt32(MemoryLayout.size(ofValue: soundId)), UnsafeRawPointer(&soundId), UInt32(MemoryLayout.size(ofValue: yes)), UnsafeRawPointer(&yes))
            }

            // Start the verification looping
            loopCheck()

            NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(willReturnToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }

    @objc func isMute(_ call: CAPPluginCall) {
        call.resolve(["value": isMute])
    }

    /// Pause while in the background, if your app supports playing audio in the background, you want this.
    /// Otherwise your app will be rejected.
    @objc func didEnterBackground() {
        isPaused = true
    }

    /// Resume when entering foreground
    @objc func willReturnToForeground() {
        isPaused = false
        if !isPlaying {
            self.loopCheck()
        }
    }

    /// Schedule a next check
    @objc func scheduleCall() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.loopCheck()
        }
    }

    /// Our loop checks sound switch
    @objc func loopCheck() {
        if !isPaused {
            interval = Date.timeIntervalSinceReferenceDate
            isPlaying = true
            AudioServicesPlaySystemSound(soundId)
        }
    }

}
