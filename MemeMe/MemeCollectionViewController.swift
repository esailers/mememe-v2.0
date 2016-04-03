//
//  MemeCollectionViewController.swift
//  MemeMe
//
//  Created by Eric Sailers on 4/1/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class MemeCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MemeEditorViewControllerDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    let cellIdentifier = "memeCollectionViewCell"
    
    var memes = [Meme]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = false
        
        configureFlowLayout(3.0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        
        collectionView.reloadData()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.item]
        cell.memeImageView.image = meme.memedImage
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - MemeEditorViewControllerDelegate
    
    func dismissMemeEditorViewController() {
        dismissViewControllerAnimated(true) {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Helpers
    
    func configureFlowLayout(space: CGFloat) {
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = (view.frame.size.height - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    // MARK: - Segues
    
    private struct StoryboardSegue {
        static let kSegueToMemeEditor = "segueToMemeEditor"
        static let kSegueToMemeDetail = "segueToMemeDetail"
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == StoryboardSegue.kSegueToMemeEditor {
            if let destination = segue.destinationViewController as? UINavigationController, memeEditorVC = destination.topViewController as? MemeEditorViewController {
                memeEditorVC.delegate = self
            }
        } else if segue.identifier == StoryboardSegue.kSegueToMemeDetail {
            if let destination = segue.destinationViewController as? MemeDetailViewController, arrayOfIndexPaths = collectionView.indexPathsForSelectedItems(), indexPath = arrayOfIndexPaths.first {
                let selectedCell = memes[indexPath.item]
                destination.meme = selectedCell
            }
        }
    }
    
}
