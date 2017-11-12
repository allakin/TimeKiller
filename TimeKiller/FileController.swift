//
//  File.swift
//  TimeKiller
//
//  Created by VAndrJ on 11/11/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

class FileController: UIViewController, GameStateable {
    var subscriberId: String {
        return String(describing: self)
    }
    
    func stateChanged(to newValue: GameState.State) {
        switch newValue {
        case .paused:
            resumeButton.isHidden = false
        default:
            resumeButton.isHidden = true
        }
    }
    
    
    lazy var button = UIButton(type: .system)
    lazy var resumeButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(button)
        view.addSubview(resumeButton)
        
        button.setTitle("start", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        resumeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([button.centerXAnchor.constraint(equalTo: view.centerXAnchor), button.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
        
        resumeButton.setTitle("resume", for: .normal)
        NSLayoutConstraint.activate([resumeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor), resumeButton.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20)])
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        resumeButton.addTarget(self, action: #selector(pauseAction), for: .touchUpInside)
        
        GameState.subscribe(self)
    }
    
    @objc func buttonAction() {
        let controller = ViewController.getController(gameComplexity: .hell, mode: .classic)
        present(controller, animated: true, completion: nil)
    }
    
    
    @objc func pauseAction() {
        let controller = ViewController.getController(gameComplexity: .resume, mode: .classic)
        present(controller, animated: true, completion: nil)
    }
}
