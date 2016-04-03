//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Eric Sailers on 4/2/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

    // MARK: - Properties
    
    var meme: Meme?
    
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Meme Detail"

        imageView.image = meme?.memedImage
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        tabBarController?.tabBar.hidden = true
    }

}
