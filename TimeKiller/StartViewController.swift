//
//  StartViewController.swift
//  TimeKiller
//
//  Created by Ivanov Developer on 11/12/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, TimerManagerDelegate {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var timeCountLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBAction func onStartButton(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        
        let seconds = TimerManager.shared.totalKilledSeconds
        let minutesString = self.secondsConvertedToMinutes(seconds)
        timeCountLabel.text = minutesString
        
        TimerManager.shared.delegate = self
        
        bgView.layer.masksToBounds = true
        bgView.layer.borderWidth = 3
        bgView.layer.borderColor = UIColor.black.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func secondsConvertedToMinutes(_ totalSeconds: Double) -> String {
        let minutes: Int = Int(totalSeconds) / 60;
        return String(minutes)
    }
    
    func updatedTotalKilledSeconds(_ totalKilledSeconds: Double) {
        let minutesString = self.secondsConvertedToMinutes(totalKilledSeconds)
        timeCountLabel.text = minutesString
    }
    

}
