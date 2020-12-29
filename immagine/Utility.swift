//
//  Utility.swift
//  immagine
//
//  Created by Sanjeev Chavan on 29/12/20.
//

import UIKit

struct UtilityTag {
	static let kActivityTag = 123123
}

class Utility {
	static var shared = Utility()
	private init() {}
	
	func displayAlert(with message: AlertMessage, action: ((UIAlertAction) -> Void)? = nil, controller: UIViewController) {
		let alert = UIAlertController(title: "immagine", message: message.description, preferredStyle: .alert)
		let okAction = UIAlertAction(title: "OK", style: .cancel, handler: action)
		alert.addAction(okAction)
		controller.navigationController?.present(alert, animated: true, completion: nil)
	}
	
	func showActivity(_ view: UIView, show: Bool) {
		UIApplication.shared.isNetworkActivityIndicatorVisible = show
		let activity = UIActivityIndicatorView(style: .gray)
		activity.backgroundColor = UIColor.white.withAlphaComponent(0.8)
		activity.tag = UtilityTag.kActivityTag
		activity.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
		
		let activityview = view.viewWithTag(UtilityTag.kActivityTag)
		if show, activityview == nil {
			view.addSubview(activity)
			activity.startAnimating()
		} else {
			if activityview != nil {
				activityview!.removeFromSuperview()
			}
			activity.stopAnimating()
		}
	}
	
	func showToast(_ controller: UIViewController, message: AlertMessage) {
		let toastLabel = UILabel()
		controller.view.addSubview(toastLabel)
		let frame = controller.view.frame
		toastLabel.frame = CGRect(x: frame.origin.x + 20, y: frame.size.height - 100, width: frame.size.width - 40, height: 80)
		
		toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.9)
		toastLabel.textColor = .white
		toastLabel.font = .systemFont(ofSize: 14)
		toastLabel.textAlignment = .center
		toastLabel.text = message.description
		toastLabel.alpha = 1.0
		toastLabel.layer.cornerRadius = 10
		toastLabel.clipsToBounds = true
		toastLabel.numberOfLines = 0
//		toastLabel.sizeToFit()
		
		UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
			toastLabel.alpha = 0.0
		}, completion: {(completed) in
			toastLabel.removeFromSuperview()
		})
		
		return
	}
	
}

enum AlertMessage {
	case message(String)
	case nodata
	case errorOccured
	
	var description: String {
		switch self {
		case .message(let message):
			return message
		case .nodata: return "No data recieved"
		case .errorOccured: return "An error occured please try again, later."
		}
	}
}
