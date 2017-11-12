//
//  ChooseDufuculteViewController.swift
//  TimeKiller
//
//  Created by Ivanov Developer on 11/12/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

class ChooseDifficultyViewController: UIViewController {

    var mode: GameState.Mode!

     @IBOutlet weak var bgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        bgView.layer.masksToBounds = true
        bgView.layer.borderWidth = 3
        bgView.layer.borderColor = UIColor.black.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onEasy(_ sender: Any) {
        showGameController(complexity: GameState.Complexity.normal)
    }
    
    @IBAction func onNormal(_ sender: Any) {
   showGameController(complexity: GameState.Complexity.hard)
    }
    
    @IBAction func onHell(_ sender: Any) {
        showGameController(complexity: GameState.Complexity.hell)
    }
    
    func showGameController(complexity: GameState.Complexity) {
        
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
