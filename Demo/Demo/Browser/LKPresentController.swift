//
//  LKBrowerController.swift
//  TransitionDemo
//
//  Created by xxx on 2019/4/16.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class LKPresentController: UIPresentationController {
    override func containerViewWillLayoutSubviews() {
        containerView?.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        
        let ges = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        containerView?.addGestureRecognizer(ges)
    }
}


extension LKPresentController {
    @objc func tapAction() {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
