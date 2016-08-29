//
//  ViewController.swift
//  DIGapp
//
//  Created by yoshikik on 2016/08/05.
//  Copyright © 2016年 Yoshiki Kawakita. All rights reserved.
//

import UIKit


class homeViewController: UIViewController {
    
    

    init() {
        super.init(nibName: nil, bundle: nil);
    }
    
    required init(coder aDecoder: NSCoder) {
        // FIXME: Why do we have to implement this?
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        let image = UIImage.gifWithName("sample.gif")
//        imageGIFView.image = image
        let homeImage = UIImage.gifWithName("sample")
        let imageView = UIImageView(image: homeImage)
        imageView.frame = CGRect(x: 2.5, y: 200.0, width: 370.0, height: 220.0)
        imageView.alpha = 0.5
        
        view.addSubview(imageView)
        self.view.backgroundColor = UIColor.whiteColor()
        
        //ラベル生成
        let hiLabel: UILabel = UILabel(frame:CGRectMake(5, 40, 370, 50))
        hiLabel.text = "Hi, Yuka!"
        hiLabel.font = hiLabel.font.fontWithSize(28.0)
        hiLabel.textColor = UIColor.blackColor()
        self.view.addSubview(hiLabel)
        
        //ラベル生成
        let welcomeLabel: UILabel = UILabel(frame:CGRectMake(5, 140, 370, 50))
        welcomeLabel.text = "予約中のプラン"
        welcomeLabel.font = welcomeLabel.font.fontWithSize(28.0)
        welcomeLabel.textColor = UIColor.blackColor()
        self.view.addSubview(welcomeLabel)
        
        
        let bookingLabel: UILabel = UILabel(frame:CGRectMake(5, 210, 370, 50))
        bookingLabel.text = "さぁ、指宿釣りツアーに出発！"
        bookingLabel.textColor = UIColor.whiteColor()
        self.view.addSubview(bookingLabel)
        
        //ラベル生成
        let exploreLabel: UILabel = UILabel(frame:CGRectMake(5, 440, 200, 50))
        exploreLabel.text = "次は何しよう？"
        exploreLabel.font = exploreLabel.font.fontWithSize(28.0)
        exploreLabel.textColor = UIColor.blackColor()
        self.view.addSubview(exploreLabel)
        
        
        let imageView2 = UIImageView(image: homeImage)
        imageView2.frame = CGRect(x: 2.5, y: 500.0, width: 370.0, height: 220.0)
        imageView2.alpha = 0.5
        view.addSubview(imageView2)

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

