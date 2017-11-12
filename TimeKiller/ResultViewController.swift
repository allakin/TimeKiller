//
//  GameOverViewController.swift
//  TimeKiller
//
//  Created by Oknesta Developer on 11/12/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit
import Foundation

class ResultViewController: UIViewController {
  
  enum GameResult {
    case gameOver,win
  }
  

  
  var timeSession:Double!
  var resultState:GameResult! = nil
  var advices = [
    "better, go work",
    "better, go to read book",
    "better, call mom",
    "better, go to the gym",
    "better, call father",
    "better, save the world",
    "better, go to bed"]

  @IBOutlet weak var timeSpended: UILabel!
  @IBOutlet weak var adviceLabel: UILabel!
  @IBOutlet weak var titleResultLabel: UILabel!
  @IBOutlet weak var bgView: UIView!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        configureInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func configureInfo() {
    bgView.layer.masksToBounds = true
    bgView.layer.borderWidth = 3
    bgView.layer.borderColor = UIColor.black.cgColor
    self.timeSpended.text = "You wasted \(Int(timeSession)) seconds"
    let randomNum:Int = Int(arc4random_uniform(4))
    let str = advices[randomNum]
    self.adviceLabel.text = str.uppercased()
    
    createLabels()
    
  }
  
  func createLabels () {
    switch self.resultState {
    case .gameOver:
      self.titleResultLabel.text = "Game Over".uppercased()
    default:
      self.titleResultLabel.text = "You Win".uppercased()
    }
  }
  
  @IBAction func menuAction(_ sender: Any) {
    let startViewController = self.storyboard?.instantiateViewController(withIdentifier: "StartNavigationViewController")
    self.present(startViewController!, animated: true, completion: nil)
  }
  
  @IBAction func tryAgainAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
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
