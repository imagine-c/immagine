//
//  MovieItemCell.swift
//  immagine
//
//  Created by Sanjeev Chavan on 27/12/20.
//

import UIKit

class MovieItemCell: UITableViewCell {
	
	var movieItem: MovieItem? {
		didSet {
			guard let movieItem = movieItem else { return }
			DispatchQueue.main.async {
				self.movieNameLabel.text = movieItem.originalTitle
				self.descriptionLabel.text = "Votes: \(movieItem.voteCount), Released On: \(movieItem.releaseDate)"
				self.artworkImageView.getLocalImage(imageName: movieItem.posterPath)
			}
		}
	}
	
	let artworkImageView: UIImageView = {
		let imageview = UIImageView()
		imageview.translatesAutoresizingMaskIntoConstraints = false
		imageview.contentMode = .scaleAspectFill
		imageview.clipsToBounds = true
		
		return imageview
	}()
	
	let movieNameLabel: UILabel = {
		let shopItemLabel = UILabel()
		shopItemLabel.font = .boldSystemFont(ofSize: 20)//.preferredFont(forTextStyle: .headline)
		shopItemLabel.numberOfLines = 0
		shopItemLabel.translatesAutoresizingMaskIntoConstraints = false
		return shopItemLabel
	}()
	
	let descriptionLabel: UILabel = {
		let priceLabel = UILabel()
		priceLabel.font = .preferredFont(forTextStyle: .footnote)
		priceLabel.translatesAutoresizingMaskIntoConstraints = false
		return priceLabel
	}()
	
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		
		//MARK: Artwork Image View
		contentView.addSubview(artworkImageView)
		let artworkImageViewConstraints = [
			artworkImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
			artworkImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
			artworkImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
			artworkImageView.widthAnchor.constraint(equalToConstant: 100)
		]
		
		NSLayoutConstraint.activate(artworkImageViewConstraints)
		
		//MARK: Movie Name Label
		addSubview(movieNameLabel)
		
		let movieNameLabelConstraints = [
			movieNameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
			movieNameLabel.leftAnchor.constraint(equalTo: artworkImageView.rightAnchor, constant: 10),
			movieNameLabel.heightAnchor.constraint(equalToConstant: 60),
			movieNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		]
		
		NSLayoutConstraint.activate(movieNameLabelConstraints)
		
		
		//MARK: Description Label
		addSubview(descriptionLabel)
		let descriptionLabelConstraints = [
			descriptionLabel.topAnchor.constraint(equalTo: movieNameLabel.bottomAnchor),
			descriptionLabel.leftAnchor.constraint(equalTo: artworkImageView.rightAnchor, constant: 10),
			descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
			descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		]
		
		NSLayoutConstraint.activate(descriptionLabelConstraints)
		
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
