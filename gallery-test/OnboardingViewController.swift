//
//  OnboardingViewController.swift
//  gallery-test
//
//  Created by Yelyzaveta Boiarchuk on 05.07.2022.
//

import UIKit
import ARKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate, ARSCNViewDelegate {
    
    private enum Configuration {
        static let pageCount = 4
        static let titles = ["Make sure you are indoor", "Make sure lighting is good", "It works better with textured walls", "Remove extra furniture"]
    }
    
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var screenLabel: UILabel!
    @IBOutlet private weak var sceneView: ARSCNView!
    @IBOutlet weak var startButton: UIButton!
    
    
    var screenWidth: CGFloat = 0
    var swipedToTheEnd = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        pageControl.numberOfPages = Configuration.pageCount
        scrollView.contentSize = CGSize(width: transparentView.frame.width * CGFloat(Configuration.pageCount) , height: transparentView.frame.height)
        screenWidth = transparentView.frame.width
        startButton.isHidden = true
        screenLabel.text = Configuration.titles[0]
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        var page : Int = Int(round(scrollView.contentOffset.x / screenWidth))
        if page < 0 { page = 0 }
        if page > Configuration.pageCount - 1  { page = Configuration.pageCount }
        
        pageControl.currentPage = page
        configurePage(number: page)
        
    }
    
    private func configurePage(number page: Int) {
        if page >= Configuration.pageCount - 1 { swipedToTheEnd = true }
        if swipedToTheEnd {
            startButton.isHidden = false
        }
        
        screenLabel.text = Configuration.titles[page]
    }
  }
    
