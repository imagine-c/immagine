//
//  DetailViewController.swift
//  immagine
//
//  Created by Sanjeev Chavan on 27/12/20.
//

import UIKit
import AVKit
import XCDYouTubeKit

class DetailViewController: UIViewController {
	
	private var movie: MovieDetailModel? = nil
	
	convenience init(movie: MovieDetailModel) {
		self.init()
		self.movie = movie
	}
	
	private var playerViewController: AVPlayerViewController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.title = "Movie Detail"//movie?.originalTitle
		view.backgroundColor = .white
		
		guard let movie = movie else { return }
		self.setupView(with: movie, orient: UIApplication.shared.statusBarOrientation)
	}
	
	@objc func prepareToPlayTrailer(_ button: UIButton) {
		if let movie = movie,
		   let randomTrailer =  movie.videos.results?.randomElement() {
			switch randomTrailer.site {
			case "Vimeo":
				self.playVimeoTrailer(key: randomTrailer.key)
			default:
				//let trailerUrl = "https://www.youtube.com/watch?v=\(randomTrailer.key)"
				self.playTrailerWithAVPlayer(Id: randomTrailer.key)
			}
		} else {
			Utility.shared.displayAlert(with: .message("No trailers found for this movie"), controller: self)
		}
	}
	
	func playVimeoTrailer(key: String) {
		if let trailerUrl = URL(string: "https://vimeo.com/\(key)") {
			playerViewController = AVPlayerViewController()
			playerViewController.delegate = self
			
			if #available(iOS 11.0, *) {
				playerViewController.entersFullScreenWhenPlaybackBegins = true
				playerViewController.exitsFullScreenWhenPlaybackEnds = true
			}
			
			playerViewController.player = AVPlayer(url: trailerUrl)
			
			self.present(self.playerViewController, animated: true) {
				self.playerViewController.player?.play()
			}
		}
	}
	
	func playTrailerWithAVPlayer(Id: String) {
		playerViewController = AVPlayerViewController()
		playerViewController.delegate = self
		
		if #available(iOS 11.0, *) {
			playerViewController.entersFullScreenWhenPlaybackBegins = true
			playerViewController.exitsFullScreenWhenPlaybackEnds = true
		}
		
		self.present(playerViewController, animated: true)
		
		XCDYouTubeClient.default().getVideoWithIdentifier(Id) {
			[weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
			if let streamURLs = video?.streamURLs,
			   let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming]) {
				playerViewController?.player = AVPlayer(url: streamURL)
				playerViewController?.player?.play()
			} else {
				self.dismiss(animated: true, completion: nil)
			}
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		
		coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
			guard let movie = self.movie else { return }
			self.setupView(with: movie, orient: UIApplication.shared.statusBarOrientation)
		}, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
			print("rotation complete")
		})
		super.viewWillTransition(to: size, with: coordinator)
	}
}

extension DetailViewController: AVPlayerViewControllerDelegate {
	func playerViewControllerDidStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
		playerViewController.dismiss(animated: true, completion: nil)
	}
	
	func playerViewControllerWillStopPictureInPicture(_ playerViewController: AVPlayerViewController) {
		print("check what happens here")
	}
}

extension DetailViewController {
	
	func setupView(with movieDetail: MovieDetailModel, orient: UIInterfaceOrientation) {
		//TODO: should add all these views in Scrollview
		
		if let mainview = view.viewWithTag(1000) {
			mainview.removeFromSuperview()
		}
		
		let mainview = UIView(frame: view.frame)
		mainview.tag = 1000
		view.addSubview(mainview)
		
		//MARK: artworkImageView
		let artworkImageView = UIImageView()
		if orient == .portrait {
			artworkImageView.contentMode = .scaleAspectFit
		} else {
			artworkImageView.contentMode = .scaleAspectFill
		}
		artworkImageView.clipsToBounds = true
		mainview.addSubview(artworkImageView)
		artworkImageView.translatesAutoresizingMaskIntoConstraints = false
		
		if orient == .portrait {
			var artworkImageViewConstraints = [
				artworkImageView.leftAnchor.constraint(equalTo: mainview.leftAnchor),
				artworkImageView.heightAnchor.constraint(equalToConstant: 240),
				artworkImageView.rightAnchor.constraint(equalTo: mainview.rightAnchor)
			]
			
			if #available(iOS 11.0, *) {
				artworkImageViewConstraints.insert(artworkImageView.topAnchor.constraint(equalTo: mainview.safeAreaLayoutGuide.topAnchor), at: 0)
			} else {
				artworkImageViewConstraints.insert(artworkImageView.topAnchor.constraint(equalTo: mainview.topAnchor, constant: 44), at: 0)
			}
			
			NSLayoutConstraint.activate(artworkImageViewConstraints)
		} else {
			var artworkImageViewConstraints = [
				artworkImageView.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 10),
				artworkImageView.heightAnchor.constraint(equalToConstant: 160),
				artworkImageView.widthAnchor.constraint(equalToConstant: 240)
			]
			
			if #available(iOS 11.0, *) {
				artworkImageViewConstraints.insert(artworkImageView.topAnchor.constraint(equalTo: mainview.safeAreaLayoutGuide.topAnchor), at: 0)
			} else {
				artworkImageViewConstraints.insert(artworkImageView.topAnchor.constraint(equalTo: mainview.topAnchor, constant: 44), at: 0)
			}
			
			NSLayoutConstraint.activate(artworkImageViewConstraints)
		}
		
		artworkImageView.getLocalImage(imageName: movieDetail.backdropPath)
		
		
		//MARK: movieTitleLabel
		let movieTitleLabel = UILabel()
		movieTitleLabel.textAlignment = .center
		movieTitleLabel.font = .boldSystemFont(ofSize: 22)
		mainview.addSubview(movieTitleLabel)
		movieTitleLabel.sizeToFit()
		movieTitleLabel.translatesAutoresizingMaskIntoConstraints = false
		
		if orient == .portrait {
			let movieTitleConstraints = [
				movieTitleLabel.topAnchor.constraint(equalTo: artworkImageView.bottomAnchor, constant: 10),
				movieTitleLabel.leftAnchor.constraint(equalTo: mainview.leftAnchor),
				movieTitleLabel.heightAnchor.constraint(equalToConstant: 40),
				movieTitleLabel.rightAnchor.constraint(equalTo: mainview.rightAnchor)
			]
			NSLayoutConstraint.activate(movieTitleConstraints)
		} else {
			let movieTitleConstraints = [
				movieTitleLabel.topAnchor.constraint(equalTo: artworkImageView.topAnchor, constant: 10),
				movieTitleLabel.leftAnchor.constraint(equalTo: artworkImageView.rightAnchor),
				movieTitleLabel.heightAnchor.constraint(equalToConstant: 40),
				movieTitleLabel.rightAnchor.constraint(equalTo: mainview.rightAnchor)
			]
			NSLayoutConstraint.activate(movieTitleConstraints)
		}
		
		movieTitleLabel.text = movieDetail.originalTitle
		
		//MARK: watchTrailerButton
		let watchButton = UIButton()
		watchButton.setTitle("Watch Trailer", for: .normal)
		watchButton.backgroundColor = .lightGray
		watchButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
		watchButton.setTitleColor(.black, for: .normal)
		mainview.addSubview(watchButton)
		watchButton.translatesAutoresizingMaskIntoConstraints = false
		watchButton.addTarget(self, action: #selector(prepareToPlayTrailer(_:)), for: .touchUpInside)
		if orient == .portrait {
			let watchButtonConstraints = [
				watchButton.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor, constant: 20),
				watchButton.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 20),
				watchButton.heightAnchor.constraint(equalToConstant: 40),
				watchButton.rightAnchor.constraint(equalTo: mainview.rightAnchor, constant: -20)
			]
			
			NSLayoutConstraint.activate(watchButtonConstraints)
		} else {
			let watchButtonConstraints = [
				watchButton.topAnchor.constraint(equalTo: movieTitleLabel.bottomAnchor),
				watchButton.leftAnchor.constraint(equalTo: artworkImageView.rightAnchor, constant: 20),
				watchButton.heightAnchor.constraint(equalToConstant: 50),
				watchButton.rightAnchor.constraint(equalTo: mainview.rightAnchor, constant: -20)
			]
			
			NSLayoutConstraint.activate(watchButtonConstraints)
		}
		
		//MARK: genreLabel
		let genreLabel = UILabel()
		mainview.addSubview(genreLabel)
		genreLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let genreLabelConstraints = [
			genreLabel.topAnchor.constraint(equalTo: watchButton.bottomAnchor),
			genreLabel.leftAnchor.constraint(equalTo: watchButton.leftAnchor),
			genreLabel.heightAnchor.constraint(equalToConstant: 40),
			genreLabel.rightAnchor.constraint(equalTo: watchButton.rightAnchor)
		]
		
		NSLayoutConstraint.activate(genreLabelConstraints)
		var genre = "Genre:"
		movieDetail.genres.forEach({ genre.append(" \($0.name),")})
		genre.removeLast()
		genreLabel.font = .systemFont(ofSize: 14)
		genreLabel.attributedText = "\(genre)".attributeBoldStr(14, upto: 6)
		genreLabel.textAlignment = .left
		
		
		//MARK: dateLabel
		let dateLabel = UILabel()
		mainview.addSubview(dateLabel)
		dateLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let dateLabelConstraints = [
			dateLabel.topAnchor.constraint(equalTo: genreLabel.bottomAnchor),
			dateLabel.leftAnchor.constraint(equalTo: genreLabel.leftAnchor),
			dateLabel.heightAnchor.constraint(equalToConstant: 40),
			dateLabel.rightAnchor.constraint(equalTo: watchButton.rightAnchor)
		]
		
		NSLayoutConstraint.activate(dateLabelConstraints)
		
		dateLabel.font = .systemFont(ofSize: 14)
		dateLabel.attributedText = "Date: \(movieDetail.releaseDate)".attributeBoldStr(14, upto: 6)
		dateLabel.textAlignment = .left
		
		
		
		//MARK: descriptionTextView
		let overviewTextView = UITextView()
		overviewTextView.font = .preferredFont(forTextStyle: .body)
		mainview.addSubview(overviewTextView)
		overviewTextView.translatesAutoresizingMaskIntoConstraints = false
		
		let overviewTextViewConstraints = [
			overviewTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10),
			overviewTextView.leftAnchor.constraint(equalTo: mainview.leftAnchor, constant: 20),
			overviewTextView.bottomAnchor.constraint(equalTo: mainview.bottomAnchor),
			overviewTextView.rightAnchor.constraint(equalTo: mainview.rightAnchor, constant: -20)
		]
		
		NSLayoutConstraint.activate(overviewTextViewConstraints)
		overviewTextView.attributedText = "Overview: \n\(movieDetail.overview)".attributeBoldStr(14, upto: 9)
	}
}

extension String {
	func attributeBoldStr(_ fontsize: CGFloat, from: Int = 0, upto: Int) -> NSMutableAttributedString {
		let durationAttStr = NSMutableAttributedString(string: self)
		durationAttStr.addAttributes([NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: fontsize)], range: NSRange(location: from, length: upto))
		return durationAttStr
	}
}
