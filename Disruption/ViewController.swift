//
//  ViewController.swift
//  Disruption
//
//  Created by Lucy Tan on 9/21/17.
//  Copyright © 2017 Lucy Tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    @IBOutlet weak var imagePicked: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        let image =  imagePicked.image as! UIImage
        var imageData: NSData = UIImagePNGRepresentation(image) as! NSData
        if (imageData.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imageData = resizeImage(newSize, image:image) as! NSData
        }
        let encordedImage = imageData.base64EncodedString(options: .lineLength64Characters)
        apiCall(data: encordedImage)
    }
    
    func apiCall(data: String){
        var request = URLRequest(url: URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyDciyAbXQIb0brgRAWoNMzPQ5fv44ERHo4")!)
        request.httpMethod = "POST"
        let json = ["requests":[["image":["content": "\(data)" ],"features":[["type":"LABEL_DETECTION","maxResults":10]]]]]
        var err: NSError?
        request.httpBody = try? JSONSerialization.data(withJSONObject: json)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("error=\(error)")
                return
            }
            do {
                // Try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
                if let jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                    if let results = jsonResult["responses"] as? NSArray {
                        for keywords in results {
                            print(keywords)
                            // cast to dictionary for data extraction
//                            let personDict = person as! NSDictionary
//                            self.people.append(personDict["name"] as! String)
                        }
                    }
                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
                    }
                }
            } catch {
                print("Something went wrong")
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openCameraButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openPhotoLibraryButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let imageData = UIImageJPEGRepresentation(imagePicked.image!, 0.6)
        let compressedJPGImage = UIImage(data: imageData!)
        UIImageWriteToSavedPhotosAlbum(compressedJPGImage!, nil, nil, nil)
        
        let alert = UIAlertController(title: "Wow", message: "Your image has been saved to Photo Library!", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
     
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        imagePicked.image = image
        dismiss(animated:true, completion: nil)
    }
    
    
    
}

