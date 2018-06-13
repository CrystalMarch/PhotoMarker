//
//  File.swift
//  PhotoMarker
//
//  Created by 朱慧平 on 2018/6/13.
//  Copyright © 2018年 朱慧平. All rights reserved.
//

import Foundation
import MBProgressHUD
import UIKit
func showProgressHUD(text: String,view:UIView){
    DispatchQueue.main.async {
        let mbProgressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        mbProgressHUD.isSquare = false
        mbProgressHUD.label.text = text
        mbProgressHUD.label.numberOfLines = 0
        mbProgressHUD.label.textColor = UIColor.black
        mbProgressHUD.mode = .customView
        mbProgressHUD.hide(animated: true, afterDelay: 1)
    }
}
