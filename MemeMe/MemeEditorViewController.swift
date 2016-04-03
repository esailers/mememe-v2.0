//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Eric Sailers on 3/28/16.
//  Copyright © 2016 Expressive Solutions. All rights reserved.
//

import UIKit

protocol MemeEditorViewControllerDelegate: class {
    func dismissMemeEditorViewController()
}

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: - Properties
    
    weak var delegate: MemeEditorViewControllerDelegate?
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    var tapGesture: UITapGestureRecognizer!
    var swipeGesture: UISwipeGestureRecognizer!
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Meme Editor"
        view.backgroundColor = UIColor.darkGrayColor()
        
        // Set the font attributes for a meme
        if let fontAttributes = UIFont(name: "HelveticaNeue-CondensedBlack", size: 40) {
            let memeTextAttributes: [String: AnyObject] = [
                NSStrokeColorAttributeName : UIColor.blackColor(),
                NSForegroundColorAttributeName : UIColor.whiteColor(),
                NSFontAttributeName : fontAttributes,
                NSStrokeWidthAttributeName : -3.0
            ]
            topTextField.defaultTextAttributes = memeTextAttributes
            bottomTextField.defaultTextAttributes = memeTextAttributes
        }
        
        configureTextField(topTextField); configureTextField(bottomTextField)
        
        setDefaultTextAndImage()
        checkForImage(memeImageView)
        
        UIApplication.sharedApplication().statusBarHidden = true
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(.Camera)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func cancelMeme(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(sender: UIBarButtonItem) {
        configurePicker(cameraButton, sourceType: .Camera)
    }
    
    @IBAction func pickImageFromAlbum(sender: UIBarButtonItem) {
        configurePicker(albumButton, sourceType: .PhotoLibrary)
    }

    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if completed {
                self.saveMeme(memedImage)
                self.delegate?.dismissMemeEditorViewController()
            }
        }
        // Configure popover for iPad
        let popoverPresentationController = activityViewController.popoverPresentationController
        popoverPresentationController?.barButtonItem = actionButton
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func configureTextField(textField: UITextField) {
        textField.delegate = self
        textField.textAlignment = .Center
    }
    
    func setDefaultTextAndImage() {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        memeImageView.image = nil
    }
    
    func configurePicker(barButton: UIBarButtonItem, sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        
        // Configure popover for iPad
        imagePicker.modalPresentationStyle = .Popover
        let popoverPresentationController = imagePicker.popoverPresentationController
        popoverPresentationController?.barButtonItem = barButton
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide the navigation bar and toolbar
        navigationController?.navigationBarHidden = true
        toolbar.hidden = true
        
        // Get the image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame,
            afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show the navigation bar and toolbar
        navigationController?.navigationBarHidden = false
        toolbar.hidden = false
        
        return memedImage
    }
    
    func saveMeme(memeImage: UIImage) {
        if let topText = topTextField.text, bottomText = bottomTextField.text, image = memeImageView.image {
            let meme = Meme(topText: topText, bottomText: bottomText, originalImage: image, memedImage: memeImage)
            
            // Add meme to memes array in the AppDelegate
            (UIApplication.sharedApplication().delegate as! AppDelegate).memes.append(meme)
        }
    }
    
    func checkForImage(imageView: UIImageView) {
        // Enable the actionButton if there's an image; otherwise, the actionButton is not enabled.
        actionButton.enabled = imageView.image != nil ? true : false
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == topTextField && topTextField.text == "TOP" {
            topTextField.text = ""
        } else if textField == bottomTextField && bottomTextField.text == "BOTTOM" {
            bottomTextField.text = ""
        }
        
        // Add tapGesture to dismiss keyboard
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        // Add swipeGesture to dismiss keyboard
        swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        swipeGesture.direction = .Down
        view.addGestureRecognizer(swipeGesture)
        
        cancelButton.enabled = false
    }
    
    func dismissKeyboard() {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == topTextField && topTextField.text == "" {
            topTextField.text = "TOP"
        } else if textField == bottomTextField && bottomTextField.text == "" {
            bottomTextField.text = "BOTTOM"
        }
        
        view.removeGestureRecognizer(tapGesture)
        view.removeGestureRecognizer(swipeGesture)
        
        cancelButton.enabled = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIKeyboardWillShowNotification
    
    func keyboardWillShow(notification: NSNotification) {
        // If you begin editing the bottomTextField, the view goes up
        if bottomTextField.editing {
            view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // If you end editing the bottomTextField, the view goes back down
        if bottomTextField.editing {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        var keyboardHeight = CGFloat()
        if let userInfo = notification.userInfo {
            let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
            keyboardHeight = keyboardSize.CGRectValue().height
        }
        return keyboardHeight
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImageView.image = image
            checkForImage(memeImageView)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

}
