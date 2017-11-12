//
//  GameOverViewController.swift
//  TimeKiller
//
//  Created by Oknesta Developer on 11/12/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
  
  var timeSession:Double!

  @IBOutlet weak var timeSpended: UILabel!
  @IBOutlet weak var adviceLabel: UILabel!
  @IBOutlet weak var titleResultLabel: UILabel!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        timeSession = 20
        configureInfo()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func configureInfo() {
    self.titleResultLabel.text = "Game over".uppercased()
    self.timeSpended.text = "\(Int(timeSession)) seconds"
    self.adviceLabel.text = "Cходи за хлебом!".uppercased()
  }
  
  @IBAction func menuAction(_ sender: Any) {
    
    
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
