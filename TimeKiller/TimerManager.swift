//
//  TimerManager.swift
//  TimeKiller
//
//  Created by Ivanov Developer on 11/12/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

protocol TimerManagerDelegate {
    func updatedTotalKilledSeconds(_ totalKilledSeconds: Double)
}

class TimerManager: NSObject {

    static let shared = TimerManager.init()
    
    var delegate: TimerManagerDelegate? = nil
    
    var timer: Timer? = nil
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.saveTotalKilledSeconds), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    let keyKilledSeconds = "keyKilledSeconds"
    
    @objc func saveTotalKilledSeconds() {
        var killedSeconds = totalKilledSeconds
        killedSeconds += 1
        
        totalKilledSeconds = killedSeconds
        
        delegate?.updatedTotalKilledSeconds(killedSeconds)
        
        print("Total Killed Seconds: \(killedSeconds)")
    }

    
    var totalKilledSeconds: Double {
        get {
            return UserDefaults.standard.double(forKey: keyKilledSeconds)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: keyKilledSeconds)
        }
    }
}
