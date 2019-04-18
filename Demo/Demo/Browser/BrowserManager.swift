//
//  BrowserManager.swift
//  TransitionDemo
//
//  Created by xxx on 2019/4/16.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

protocol BrowserManagerDelegate: NSObjectProtocol {
    func BrowserManagerGetOriginalImageView(brower :BrowserManager) -> UIImage
    func BrowserManagerGetOriginalFrames(brower :BrowserManager) -> [NSValue]
    func BrowserManagerGetSelectIndex(brower :BrowserManager) -> NSInteger
    func BrowserManagerGetOriginalScale(brower :BrowserManager) -> CGFloat
}

class BrowserManager: NSObject {
    
    let width = UIApplication.shared.keyWindow?.frame.size.width
    let height = UIApplication.shared.keyWindow?.frame.size.height
    var origImage = UIImage()
    var orgiframe = CGRect.zero
    var imageView = UIImageView()
    var scale :CGFloat?
    var index :NSInteger?
    var rectArray :[NSValue]?
    
    
    private var isShow = false
    weak var delegate:BrowserManagerDelegate?
}

/*
 通过代理来处理
 1.获取图片和图片的frame
 */
extension BrowserManager :UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        isShow ? handlePresentAnimate(using: transitionContext) : handleDismissedAnimate(using: transitionContext)
    }

}

///自定义处理动画
extension BrowserManager {
    
    ///自定义处理present
    
    func handlePresentAnimate(using transitionContext: UIViewControllerContextTransitioning) {
        
        imageView = createImageView()
        transitionContext.containerView.addSubview(imageView)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            self.imageView.bounds = CGRect(x: 0, y: 0, width: self.width!, height: self.width! * self.scale!)
            self.imageView.center = CGPoint(x: self.width! * 0.5, y: self.height! * 0.5)
        }) { (_) in
            self.imageView.removeFromSuperview()
            
            let presentView = transitionContext.view(forKey: .to)
            let containerView = transitionContext.containerView
            
            containerView.addSubview(presentView!)
            transitionContext.completeTransition(true)
        }
    }
    
    ///自定义处理dismiss
    func handleDismissedAnimate(using transitionContext: UIViewControllerContextTransitioning) {
       let dissImgView = getDismissedImageView(using: transitionContext)


        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            dissImgView.frame = self.orgiframe
        }) { (_) in
            transitionContext.completeTransition(true)
        }
    }
}

extension BrowserManager {
    func createImageView() -> UIImageView {
        origImage =  (delegate?.BrowserManagerGetOriginalImageView(brower: self))!
        rectArray = delegate!.BrowserManagerGetOriginalFrames(brower :self)
        let selectIndex = delegate?.BrowserManagerGetSelectIndex(brower: self)
        orgiframe = rectArray![selectIndex!].cgRectValue
        
        imageView.image = origImage
        
        
        scale = delegate?.BrowserManagerGetOriginalScale(brower: self)
        
        imageView.frame = orgiframe
        
        return imageView
    }
    
    
    func getDismissedImageView(using transitionContext: UIViewControllerContextTransitioning) -> UIImageView {
        let presentView = transitionContext.view(forKey: .from)
        let containView = transitionContext.containerView
        containView.backgroundColor = UIColor.clear
        
        for view in (presentView?.subviews)! {
            if view .isKind(of: UICollectionView.self) {
                let col = (view as? UICollectionView)!
                let cell = col.visibleCells.first as? LKBrowserCell
                
                ///修改当前索引
                let indexPath = col.indexPath(for: cell!)
                self.index = (indexPath?.item)!
                let rectValue = rectArray![self.index!]
                
                orgiframe = rectValue.cgRectValue
                let rect = cell?.scrollView.convert((cell?.imgView.frame)!, to: WINDOW)
                cell?.imgView.frame = rect!
                containView.addSubview((cell?.imgView)!)
                presentView?.removeFromSuperview()
                return (cell?.imgView)!
            }
        }
        return UIImageView()
    }
}

///转场代理方法
extension BrowserManager :UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return LKPresentController(presentedViewController: presented, presenting: presenting)
    }
    
    ///设置模态出现动画代理
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isShow = true
        return self
    }
    ///设置模态消失动画代理
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isShow = false
        return self
    }
    
}
