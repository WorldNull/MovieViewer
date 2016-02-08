//
//  PageViewController.swift
//  MovieViewer
//
//  Created by YouGotToFindWhatYouLove on 2/2/16.
//  Copyright © 2016 Candy. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

class PageViewController: UIPageViewController {
    
    let apiKey = "e071284ddb082754f0ccac86ce389c26"
    var playingUrl: NSURL!
    var genreUrl: NSURL!
    var movieTask: NSURLSessionDataTask!
    var movies: [NSDictionary]?
    var movieController: MoviesViewController?
    var temp = [NSDictionary]()
    var orderedViewControllers: [UIViewController]!
    let moviesPerPage = 4
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        
        // create urls for playing and genre API requests
        playingUrl = NSURL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        genreUrl = NSURL(string: "https://api.themoviedb.org/3/genre/movie/list?api_key=\(apiKey)")
        
        fetchMovies()
        movieTask.resume()
        
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
                    //self.warningView.hidden = true
                    //self.collectionView.hidden = false
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.orderedViewControllers = self.arrangeViewControllers((self.movies?.count)!)
                            //print("self.movies: \(self.movies)")
                            self.distributeMovies(self.movies!, viewController: self.orderedViewControllers)
                            
                            if let firstViewController = self.orderedViewControllers.first {
                                self.setViewControllers([firstViewController],
                                    direction: .Forward,
                                    animated: true,
                                    completion: nil)
                            }
                            
                    }
                }
        })
    }
    
    private func arrangeViewControllers(numOfMovies: Int) -> [UIViewController] {
        let numOfController = numOfMovies / moviesPerPage
        var controllerArray = [UIViewController]()
        
        for var i = 0; i < numOfController; i++ {
            controllerArray.append(UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("GreenViewController"))
        }
        //print("controllerArray: \(controllerArray)")
        return controllerArray
    }
    
    private func distributeMovies(var movies: [NSDictionary], viewController: [UIViewController]) {
        var showMovies = displayMovies()
        showMovies.numOfPages = viewController.count
        
        print(1)
        
        for var i = 0; i < viewController.count; i++ {
            for var j = 0; j < moviesPerPage; j++ {
                let currentViewController = (viewController[i] as! UINavigationController).topViewController! as? MoviesViewController
                showMovies.displayMovies.append(movies[0])
                movies.removeAtIndex(0)
                if (j == 3) {
                    currentViewController?.showMovies = showMovies
                    showMovies.displayMovies = [NSDictionary]()
                }
            }
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
           
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let previousIndex = viewControllerIndex - 1
            
            // User is on the first view controller and swiped left to loop to
            // the last view controller.
            guard previousIndex >= 0 else {
                return orderedViewControllers.last
            }
            
            guard orderedViewControllers.count > previousIndex else {
                return nil
            }
            
            return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(pageViewController: UIPageViewController,
        viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            
            guard let viewControllerIndex = orderedViewControllers.indexOf(viewController) else {
                return nil
            }
            
            let nextIndex = viewControllerIndex + 1
            
            let orderedViewControllersCount = orderedViewControllers.count
            
            // User is on the last view controller and swiped right to loop to
            // the first view controller.
            guard orderedViewControllersCount != nextIndex else {
                return orderedViewControllers.first
            }
            
            guard orderedViewControllersCount > nextIndex else {
                return nil
            }
            
            return orderedViewControllers[nextIndex]
            
    }


}


    