//
//  ShowImageViewController.swift
//  Quick Share
//
//  Created by Giorgi Chachanidze on 5/16/21.
//

import UIKit
import Photos
import Social

class ShowImageViewController: UIViewController,UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!

    var asset:PHAsset?
    var image: UIImage?
    
    var docController = UIDocumentInteractionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let myAsset = asset {
            PHImageManager.default().requestImage(for: myAsset, targetSize: CGSize(width: self.view.frame.width, height: self.view.frame.width * 0.5625), contentMode: .aspectFill, options: nil,resultHandler:  { (result, info) in
                if let image = result{
                    self .imageView.image = image
                }
            })
        } else if (image != nil) {
            self.imageView.image = image
        }else {
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func shareButtonClicked(_ sender: UIButton){
        switch sender.tag{
        case 0:
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook){
                let alertController = UIAlertController(title: "Action Sheet", message: "What do you like to do", preferredStyle: .alert)

                let okButton = UIAlertAction(title: "Share", style: .default, handler: { [self] (action) -> Void in
                            ShareFacebookTwitter(vc: vc);
                        })

                        let cancelButton = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) -> Void in
                            
                        })

                present(alertController, animated: true, completion: nil)

                    alertController.addAction(okButton)
                    alertController.addAction(cancelButton)

            }
          
        case 1:
            let alertController = UIAlertController(title: "Action Sheet", message: "What do you like to do", preferredStyle: .alert)

            let okButton = UIAlertAction(title: "Share", style: .default, handler: { [self] (action) -> Void in
                
                      ShareInstagram()
                
                    })

                    let cancelButton = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) -> Void in
                        
                    })

            present(alertController, animated: true, completion: nil)

                alertController.addAction(okButton)
                alertController.addAction(cancelButton)
            
        case 2:
            if let vc = SLComposeViewController(forServiceType: SLServiceTypeTwitter){
                
                let alertController = UIAlertController(title: "Action Sheet", message: "What do you like to do", preferredStyle: .alert)

                let okButton = UIAlertAction(title: "Share", style: .default, handler: { [self] (action) -> Void in
                    
                        ShareFacebookTwitter(vc: vc);
                    
                        })

                        let cancelButton = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) -> Void in
                            
                        })

                present(alertController, animated: true, completion: nil)

                    alertController.addAction(okButton)
                    alertController.addAction(cancelButton)
                
            }else {
                showAlert(with: "Warning", message: "You dont have this application")
            }
        case 3:
            let alertController = UIAlertController(title: "Action Sheet", message: "What do you like to do", preferredStyle: .alert)

            let okButton = UIAlertAction(title: "Share", style: .default, handler: { [self] (action) -> Void in
                
                ShareWhatsApp()
                
                    })

                    let cancelButton = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) -> Void in
                        
                    })

            present(alertController, animated: true, completion: nil)

                alertController.addAction(okButton)
                alertController.addAction(cancelButton)
            
        default:
            print("nouth")
        }
    }
    func ShareFacebookTwitter (vc: SLComposeViewController){
//        vc.setInitialText("Look at this great picture!")
        vc.add(imageView.image)
//        vc.add(URL(string: "https://www.facebook.com/profile.php?id=100008245172200"))
        present(vc, animated: true, completion: nil)
    }
    
    func ShareInstagram(){
        let instagramUrl = URL(string: "instagram://app")
        
        if (UIApplication.shared.canOpenURL(instagramUrl!)) {
            let imageData = imageView.image!.jpegData(compressionQuality: 85)
            let captionString = "Default text"
            
            let writePath = (NSTemporaryDirectory() as NSString).appending("instagram.igo")
            
            do {
                try imageData?.write(to: URL(fileURLWithPath: writePath), options: [.atomicWrite])
                let fileURL = URL(fileURLWithPath: writePath)
                
                self.docController = UIDocumentInteractionController(url: fileURL)
                
                self.docController.delegate = self
                
                self.docController.uti = "com.instagram.exclusivegram"
                
                self.docController.annotation = NSDictionary(object: captionString, forKey: "InstagramCaption" as NSCopying)
                self.docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                
            }catch _ {
                print("error instagram")
            }
        } else {
            showAlert(with: "Warning", message: "You dont have this application")
        }
    }
    
    func ShareWhatsApp () {
        let urlWhats = "whatsapp://app"
        
        if let whatsappURL = URL(string: urlWhats) {
            
            if UIApplication.shared.canOpenURL(whatsappURL) {
                if let image = imageView.image {
                    if let imageData = image.jpegData(compressionQuality: 85) {
                        do {
                            let tempFile = try URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Documents/whatsAppTmp.wai")
                            try imageData.write(to: tempFile, options: .atomicWrite)
                            self.docController = UIDocumentInteractionController(url: tempFile)
                            self.docController.uti = "net.whatsapp.image"
                            self.docController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
                            
                        }
                        catch _ {
                            print("whatsapp error")
                        }
                    }
                }
            }
            else {
                showAlert(with: "Warning", message: "You dont have this application")
            }
        }
        
      
    }

    func showAlert(with title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alert, animated: true)
    }
}
