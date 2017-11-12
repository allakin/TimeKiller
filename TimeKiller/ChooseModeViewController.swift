//
//  ChooseModeViewController.swift
//  TimeKiller
//
//  Created by Ivanov Developer on 11/12/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

class ChooseModeViewController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgView.layer.masksToBounds = true
        bgView.layer.borderWidth = 3
        bgView.layer.borderColor = UIColor.black.cgColor
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onClassicMode(_ sender: Any) {
        showChooseDifficulteController(mode: GameState.Mode.classic)
    }
    
    @IBAction func onTimeMode(_ sender: Any) {
        showChooseDifficulteController(mode: GameState.Mode.time)
    }
    
    func showChooseDifficulteController(mode: GameState.Mode) {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: String.init(describing: ChooseDifficultyViewController.self)) as! ChooseDifficultyViewController
        controller.mode = mode
        navigationController?.show(controller, sender: self)
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

}
