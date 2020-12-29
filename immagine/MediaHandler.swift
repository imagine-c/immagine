//
//  MediaHandler.swift
//  immagine
//
//  Created by Sanjeev Chavan on 28/12/20.
//

import UIKit

class MediaHandler {
	
	static var shared = MediaHandler()
	private init() {}
	
	func saveImage(imageName: String, image: UIImage) {
		createDirectory()
		let directory = appImagesDirectoryPath()
			.appendingPathComponent(imageName)
		
		if let data = image.jpegData(compressionQuality:  1.0),
		   !FileManager.default.fileExists(atPath: directory!.path) {
			do {
				try data.write(to: directory!)
			} catch {
				print("error saving file:", error)
			}
		}
	}
	
	func appImagesDirectoryPath() -> NSURL {
		return NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
			.appendingPathComponent("ImmagineImages")! as NSURL
	}
	
	func createDirectory() {
		let dirPath = appImagesDirectoryPath()
		if let url = URL(string: dirPath.absoluteString!),
		   FileManager().fileExists(atPath: url.path) == false {
			do {
				try FileManager.default.createDirectory(atPath: dirPath.path!, withIntermediateDirectories: true, attributes: nil)
			} catch let error as NSError {
				print("error creating directory:", error)
			}
		}
	}
	
	func deleteDirectory() -> Bool {
		let dirPath = appImagesDirectoryPath()
		if let url = URL(string: dirPath.absoluteString!) {
			do {
				if FileManager().fileExists(atPath: url.path) {
					try FileManager().removeItem(at: url)
					return true
				}
			}  catch let error as NSError {
				print("error deleting directory:", error)
				return false
			}
		}
		return false
	}
}

extension UIImageView {
	
	func getLocalImage(imageName: String) {
		let directory = MediaHandler.shared.appImagesDirectoryPath()
			.appendingPathComponent(imageName)
		
		if FileManager.default.fileExists(atPath: directory!.path) {
			self.image = UIImage(contentsOfFile: directory!.path)
		} else {
			guard let url = URL(string: "\(imageBaseURL)\(imageName)") else { return }
			self.loadNetworkImage(url, imageName: imageName)
		}
	}
	
	func loadNetworkImage(_ url: URL, imageName: String) {
		let activityView = UIActivityIndicatorView(style: .gray)
		self.addSubview(activityView)
		
		URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
			guard error == nil,
				  let data = data else {
				return
			}
			DispatchQueue.main.async { [weak self] in
				activityView.removeFromSuperview()
				if let image = UIImage(data: data) {
					MediaHandler.shared.saveImage(imageName: imageName, image: image)
					self?.image = image
				}
			}
		}).resume()
	}
}
