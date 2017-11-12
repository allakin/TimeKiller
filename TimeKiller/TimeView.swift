//
//  TimeView.swift
//  TimeKiller
//
//  Created by VAndrJ on 11/11/17.
//  Copyright © 2017 VAndrJ. All rights reserved.
//

import UIKit

class TimeView: UIImageView {
    var isKiller: Bool? {
        didSet {
            if isKiller ?? false {
                switch arc4random_uniform(6) {
                case 0:
                    image = #imageLiteral(resourceName: "logo-facebook")
                case 1:
                    image = #imageLiteral(resourceName: "insta")
                case 2:
                    image = #imageLiteral(resourceName: "pint")
                case 3:
                    image = #imageLiteral(resourceName: "ok")
                case 4:
                    image = #imageLiteral(resourceName: "vk")
                default:
                    image = #imageLiteral(resourceName: "twitter")
                }
            } else {
                image = #imageLiteral(resourceName: "clock")
            }
        }
    }
    var isDestroyed = false
}
