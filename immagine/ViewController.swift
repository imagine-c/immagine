//
//  ViewController.swift
//  immagine
//
//  Created by Sanjeev Chavan on 27/12/20.
//

import UIKit

class ViewController: UIViewController {
	
	private let cellId = "movieItemCell"
	private var tableview = UITableView()
	private let refreshControl = UIRefreshControl()
	
	private var tableList: [MovieItem] = [] {
		didSet {
			DispatchQueue.main.async {
				self.tableview.reloadData()
			}
		}
	}
	
	private var responseList: [Int: [MovieItem]] = [:] {
		didSet {
			DispatchQueue.main.async {
				self.refreshControl.endRefreshing()
				self.tableList = self.responseList
					.sorted(by: { (first, second) -> Bool in first.key < second.key })
					.flatMap({ $0.value })
//					.filter({ $0.adult == false })//hide all nonsense while testing
			}
		}
	}
	
	var isFetchInProgress = false
	var scrollDownPageNo = 10
	var scrollUpPageNo: UInt = 10
	var pagesFetched:[Int] = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		view.backgroundColor = .white
		navigationItem.title = "Movie Catalog"
		
		setupTableView()
		getPopularMoviesList(for: scrollDownPageNo)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let selectedRow = tableview.indexPathForSelectedRow {
			tableview.deselectRow(at: selectedRow, animated: true)
		}
	}
	
	var tableFooterView: (String) -> UIView = { footerText in
		let footer = UIButton(type: .system)
		footer.frame = CGRect(x: 0, y: 20, width: 200, height: 100)
		footer.setTitle(footerText, for: .normal)
		return footer
	}
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tableList.count
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableview.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MovieItemCell
		cell.movieItem = tableList[indexPath.row]
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		self.getMovieDetails(movieId: tableList[indexPath.row].id) {
			movieDetail in
			if let movieDetail = movieDetail {
				DispatchQueue.main.async { [weak self] in
					let detailController = DetailViewController(movie: movieDetail)
					self?.navigationController?.pushViewController(detailController, animated: true)
				}
			} else {
				DispatchQueue.main.async {
					Utility.shared.showToast(self, message: .nodata)
				}
			}
		}
	}
}

//This is loading too much data which is not required
//extension ViewController: UITableViewDataSourcePrefetching {
//	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//		DispatchQueue.main.async {
//			if !self.isFetchInProgress {
//				self.isFetchInProgress = true
//				self.pageNo += 1
//				self.getPopularMoviesList(for: (Int(self.pageNo)))
//			}
//		}
//	}
//
//	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {}
//}

extension ViewController: UIScrollViewDelegate {
	func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
		if ((tableview.contentOffset.y + tableview.frame.size.height) < tableview.contentSize.height) {
			if !isFetchInProgress, scrollUpPageNo > 1 {
				isFetchInProgress = true
				scrollUpPageNo -= 1
				getPopularMoviesList(for: Int(scrollUpPageNo))
			}
			
			if tableview.contentOffset.y <= 0.0 && scrollUpPageNo == 1 {
				Utility.shared.showToast(self, message: .message("You have reached the topmost page"))
			}
		}
		
		if ((tableview.contentOffset.y + tableview.frame.size.height) >= tableview.contentSize.height) {
			if !isFetchInProgress {
				isFetchInProgress = true
				scrollDownPageNo += 1
				getPopularMoviesList(for: scrollDownPageNo)
			}
		}
	}
	
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.refreshControl.endRefreshing()
		self.isFetchInProgress = false
	}
}

extension ViewController {
	fileprivate func setupTableView() {
		view.addSubview(tableview)
		tableview.translatesAutoresizingMaskIntoConstraints = false
		tableview.delegate = self
		tableview.dataSource = self
		//		tableview.prefetchDataSource = self
		tableview.estimatedRowHeight = 120
		tableview.rowHeight = UITableView.automaticDimension
		tableview.register(MovieItemCell.self, forCellReuseIdentifier: cellId)
		tableview.addSubview(refreshControl)
		
		tableview.tableFooterView = tableFooterView("Loading more movies...")
		
		let tableViewConstraints = [
			tableview.topAnchor.constraint(equalTo: view.topAnchor),
			tableview.leftAnchor.constraint(equalTo: view.leftAnchor),
			tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			tableview.rightAnchor.constraint(equalTo: view.rightAnchor)
		]
		
		NSLayoutConstraint.activate(tableViewConstraints)
	}
	
	func getPopularMoviesList(for pageNo: Int) {
		guard !pagesFetched.contains(pageNo),
			  responseList.keys.contains(pageNo) == false else {
			Utility.shared.showToast(self, message: .nodata)
			return
		}
		
		pagesFetched.append(pageNo)
		Utility.shared.showActivity(self.view, show: true)
		APIManager.shared.performRequest(for: .popular(pageNo)) { (data, error) in
			DispatchQueue.main.async {
				Utility.shared.showActivity(self.view, show: false)
			}
			guard error == nil, let movies = data else {
				self.pagesFetched.removeLast()
				print(error!.localizedDescription)
				return
			}
			
			if let movies: PopularMovies = movies.decode() {
				if movies.results.isEmpty {
					DispatchQueue.main.async {
						Utility.shared.showToast(self, message: .nodata)
					}
				} else {
					if self.responseList.keys.contains(pageNo) == false {
						self.responseList.updateValue(movies.results, forKey: pageNo)
					}
				}
			} else {
				DispatchQueue.main.async {
					Utility.shared.showToast(self, message: .nodata)
				}
			}
		}
	}
	
	func getMovieDetails(movieId: Int, completion: @escaping((MovieDetailModel?)->Void)) {
		Utility.shared.showActivity(self.view, show: true)
		APIManager.shared.performRequest(for: .movieId(movieId)) { (data, error) in
			DispatchQueue.main.async {
				Utility.shared.showActivity(self.view, show: false)
			}
			guard error == nil, let movie = data else {
				print(error!.localizedDescription)
				return
			}
			//String(data: movie, encoding: .utf8)! as NSString
			if let movieDetail: MovieDetailModel = movie.decode() {
				completion(movieDetail)
			} else {
				completion(nil)
			}
		}
	}
}
