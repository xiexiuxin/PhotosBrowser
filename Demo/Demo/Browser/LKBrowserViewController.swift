//
//  LKBrowserViewController.swift
//  BrowserDemo
//
//  Created by xxx on 2019/4/17.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class LKBrowserViewController: UIViewController {
    var collectView :UICollectionView!

    var pictures: [UIImage] = [UIImage]()
    var index :NSIndexPath?
    
    init(pictures :[UIImage] ,indexPath :NSIndexPath) {
        self.pictures = pictures
        self.index = indexPath
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_HEIGHT)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectView.backgroundColor = UIColor.white
        collectView.delegate = self;
        collectView.dataSource = self;
        collectView.register(LKBrowserCell.self, forCellWithReuseIdentifier: "cell")
        collectView.showsHorizontalScrollIndicator = false
        collectView.isPagingEnabled = true
        collectView.bounces = false
        
        view.addSubview(collectView)
        view.clipsToBounds = true
    }
    
    override func viewDidLayoutSubviews() {
        collectView.scrollToItem(at: index! as IndexPath, at: .left, animated: false)
    }
    
}

extension LKBrowserViewController :UICollectionViewDelegate ,UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LKBrowserCell
        cell.img = pictures[(indexPath.item)]
        
        return cell
    }
}

///自定义collectionViewCell
class LKBrowserCell :UICollectionViewCell {
    
    var scrollView :UIScrollView = UIScrollView(frame: CGRect.zero)
    
    var imgView = UIImageView(frame: CGRect.zero)
    
    var img : UIImage?{
        didSet{
            scrollView.contentInset = UIEdgeInsets.zero
            scrollView.contentSize = CGSize.zero
            scrollView.contentOffset = CGPoint.zero
            imgView.transform = CGAffineTransform.identity

            imgView.image = img!
            
            ///根据图片设置scrollView的contentInset和imgView的高度
            let scale = img!.size.height / img!.size.width
            
            var offsetY = (SCREEN_HEIGHT - SCREEN_WIDTH * scale) * 0.5
            if offsetY < 0 {
                scrollView.contentSize = CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH * scale)
                offsetY = 0
            }
            
//
            imgView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: SCREEN_WIDTH, height: SCREEN_WIDTH * scale))
//
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: 0, bottom: offsetY, right: 0)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        scrollView.maximumZoomScale = 2.0
        scrollView.minimumZoomScale = 0.4
        scrollView.backgroundColor = UIColor.black
        scrollView.addSubview(imgView)
        addSubview(scrollView)
        
        ///布局scrollview
        scrollView.frame = contentView.bounds
//        imgView.frame = scrollView.bounds
        
        scrollView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}

extension LKBrowserCell :UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imgView
    }
    ///缩放时,frame会变,bounds不变;重新计算imgView的大小和scrollview的contentInset
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var offsetY = (SCREEN_HEIGHT - imgView.frame.size.height) * 0.5
        var offsetX = (SCREEN_WIDTH - imgView.frame.size.width) * 0.5
        
        offsetY = (offsetY < 0) ? 0 : offsetY
        offsetX = (offsetX < 0) ? 0 : offsetX

        scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
    }
}
