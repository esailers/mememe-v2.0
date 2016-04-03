//
//  MemeTableViewController.swift
//  MemeMe
//
//  Created by Eric Sailers on 4/1/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MemeEditorViewControllerDelegate {

    // MARK: - Properties
    
    let cellIdentifier = "memeTableViewCell"
    
    var memes = [Meme]()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.sharedApplication().statusBarHidden = false
        
        memes = (UIApplication.sharedApplication().delegate as! AppDelegate).memes
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MemeTableViewCell
        let meme = memes[indexPath.row]
        cell.memeLabel.text = "\(meme.topText) \(meme.bottomText)"
        cell.memeImageView.image = meme.memedImage
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let button = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) in
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.removeAtIndex(indexPath.row)
            self.memes.removeAtIndex(indexPath.row)
            tableView.reloadData()
        }
        return [button]
    }
    
    // MARK: - MemeEditorViewControllerDelegate
    
    func dismissMemeEditorViewController() {
        dismissViewControllerAnimated(true) {
            self.tableView.reloadData()
        }
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
            if let destination = segue.destinationViewController as? MemeDetailViewController, indexPath = tableView.indexPathForSelectedRow {
                let selectedCell = memes[indexPath.row]
                destination.meme = selectedCell
            }
        }
    }
    
}
