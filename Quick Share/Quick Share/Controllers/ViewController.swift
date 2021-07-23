
import UIKit
import Photos

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate{
    
    var assetCollection: PHAssetCollection?
    var photos: PHFetchResult<PHAsset>?
   
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    @IBOutlet weak var tableView: UITableView!
    
    let reuseIdentifier = "tableViewCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
 
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchImages()
        // 1. check auth status
        
        // 2. if authorized fetchImages()
        
        // 3. if not authorized request authorization
        
        // 3.1 if accepted fetchImages()
        
        // 3.2 if not accepted (optional) show alert user
    }

    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier {
            if(id == "showFullImageSegue") {
                let newVc = segue.destination as! ShowImageViewController
                let indexPath = self.tableView.indexPath(for: sender as! UITableViewCell)
                if let asset = self.photos?[(indexPath!.row)] {
                    newVc.asset = asset
                }
            }
        }
    }
    
    var imagePicker: UIImagePickerController!
    
    @IBAction func CameraButtonClicked(_ sender: Any) {
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func fetchImages() {
        let status = PHPhotoLibrary.authorizationStatus()
        
        let collection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        
        if (status == PHAuthorizationStatus.authorized) {
        
            if(collection.firstObject != nil) {
                self.assetCollection = collection.firstObject! as PHAssetCollection

                let options = PHFetchOptions()
                options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
                options.sortDescriptors = [ NSSortDescriptor(key: "creationDate", ascending: false)]

                self.photos = PHAsset.fetchAssets(in: assetCollection!, options: options)
            }
            tableView.reloadData()
        }

        else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
        }

        else if (status == PHAuthorizationStatus.notDetermined) {

            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in

                if (newStatus == PHAuthorizationStatus.authorized) {

                }

                else {

                }
            })
        }

        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)

        let newVC = self.storyboard?.instantiateViewController(identifier: "showPhotoVC") as! ShowImageViewController

        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            newVC.image = image
            show(newVC, sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyTableViewCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MyTableViewCell
        
        if let asset = self.photos?[indexPath.row] {
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: 320, height: 240), contentMode: .aspectFill, options: nil) { (result, info) in
                if let image = result {
                    cell.myImageView?.image = image
                }
            }
        }
        
        cell.myImageView.image = UIImage(named: "camera")
        return cell
        
       }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}

