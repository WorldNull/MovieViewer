//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by YouGotToFindWhatYouLove on 1/28/16.
//  Copyright © 2016 Candy. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController {
    
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    var movies: [NSDictionary]?
    var showMovies: displayMovies!
    var lol = 10
    let apiKey = "e071284ddb082754f0ccac86ce389c26"
    var playingUrl: NSURL!
    var genreUrl: NSURL!
    let refreshControl = UIRefreshControl()
    var movieTask: NSURLSessionDataTask!
    var genreTask: NSURLSessionDataTask!
    var navLabel: UILabel!
    var genreDictionary = [12: "Adventure", 10749: "Romance", 878: "Science Fiction", 14: "Fantasy", 27: "Horror", 9648: "Mystery", 99: "Documentary", 16: "Animation", 10770: "TV Movie", 10402: "Music", 28: "Action", 18: "Drama", 53: "Thriller", 10769: "Foreign", 36: "History", 10751: "Family", 10752: "War", 35: "Comedy", 80: "Crime"]
    var filteredMovies: [NSDictionary]?
    var searchController: UISearchController!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove the line below
        filteredMovies = showMovies.displayMovies
                
        // Initializing with searchResultsController set to nil means that
        // searchController will use this view controller to display the search results
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        
        
        // If we are using this same view controller to present the results
        // dimming it out wouldn't make sense.  Should set probably only set
        // this to yes if using another controller to display the search results.
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.sizeToFit()
        let searchBar = searchController.searchBar
        searchBar.barStyle = UIBarStyle.Black
        
        for subView in searchBar.subviews
        {
            for subsubView in subView.subviews
            {
                if let textField = subsubView as? UITextField
                {
                    textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Search", comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.orangeColor()])
                    
                    textField.textColor = UIColor.orangeColor()
                }
            }
        }

        navItem.titleView = searchBar
        navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        
        struct Static {
            static var hideToolBar = false
            static var pageNumber = 2
        }
        if Static.hideToolBar == true {
            searchBar.setImage(UIImage(named: "searchImage"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
            
            let pageNumber = "Page " + String(Static.pageNumber)
            for subView in searchBar.subviews
            {
                for subsubView in subView.subviews
                {
                    if let textField = subsubView as? UITextField
                    {
                        textField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString(pageNumber, comment: ""), attributes: [NSForegroundColorAttributeName: UIColor.orangeColor()])
                        
                        textField.textColor = UIColor.orangeColor()
                    }
                }
            }
            searchBar.userInteractionEnabled = false
            Static.pageNumber++
        } else {
            Static.hideToolBar = true
    
        }
        

        
        // Sets this view controller as presenting view controller for the search interface
        definesPresentationContext = true
        
        // dynamically resize UICollection cells
        let width = (CGRectGetWidth(collectionView.frame) - CGFloat(24))/CGFloat(2)
        flowLayout.itemSize = CGSizeMake(width, width+CGFloat(73))
        
        
        // create urls for playing and genre API requests
        playingUrl = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        genreUrl = NSURL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        fetchMovies()
        movieTask.resume()
        
        
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.insertSubview(refreshControl, atIndex: 0)
        collectionView.alwaysBounceVertical = true
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Make a HTTP request for movie data
    func fetchMovies() {
        
        // Create the NSURLRequest (myRequest)
        let request = NSURLRequest(
            URL: playingUrl,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        movieTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                if let data = dataOrNil {
                    self.warningView.hidden = true
                    self.collectionView.hidden = false
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            // self.filteredMovies = self.movies
                            
                            // Reload the tableView now that there is new data
                            //self.collectionView.reloadData()
                            
                        
                    }
                } else {
                    self.collectionView.hidden = true
                    self.warningView.hidden = false
                }
        })
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchMovies()
        
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
        movieTask.resume()
        self.presentViewController(PageViewController() as! UIViewController, animated: false, completion: nil)
        
    }
    
    
    
    @IBAction func retryNetwork() {
        fetchMovies()
        movieTask.resume()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Implement UICollectionView Protocols
extension MoviesViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
        if var movies = filteredMovies {
            //print(filteredMovies)
            //print(movies.count)
            //print("Please: \(showMovies.displayMovies)")
            return movies.count
        } else {
            //print("omg")
            //print("self.restorationIdentifier: \(self.restorationIdentifier)")
            return 0
        }
    }
    
    // set cell's contents
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        let movie = filteredMovies![indexPath.row]
        let title = movie["title"] as! String
        let genreIds = movie["genre_ids"] as! [Int]
        var genreArray = [String]()
        var genreString = ""
        
        //let overview = movie["overview"] as! String
        let posterPath = movie["poster_path"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        let imageUrl = NSURL(string: baseUrl + posterPath)
        
        let imageRequest = NSURLRequest(URL: imageUrl!)
        
        cell.titleLabel.text = title
        
        
        for var i = 0; i < genreIds.count; i++ {
            guard let genre = genreDictionary[genreIds[i]] else {
                continue
            }
            genreArray.append(genre)
        }
        
        genreString = genreArray.joinWithSeparator("/")

        cell.genreLabel.text = genreString
        
        //cell.overviewLabel.text = overview

        // Fading in an Image Loaded from the Network
        func setCellImage() {
            cell.posterView.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    
                    // print("Image was NOT cached, fade in image")
                    cell.posterView.alpha = 0.0
                    cell.posterView.image = image
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        cell.posterView.alpha = 1.0
                    })
                } else {
                    
                    //print("Image was cached so just update the image")
                    cell.posterView.image = image
                }
            },
            failure: { (imageRequest, imageReponse, error) -> Void in
                cell.posterView.image = UIImage(named: "poster-not-available")
            })
            cell.posterView.layer.cornerRadius = 5
        }
        setCellImage()
        
        return cell
    }
}

extension MoviesViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filteredMovies = searchText.isEmpty ? movies : movies!.filter({(dataItem: NSDictionary) -> Bool in
                //If dataItem matches the searchText, return true to include it
                let title = dataItem["title"] as! String
                if title.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }
        collectionView.reloadData()

    }
}



















