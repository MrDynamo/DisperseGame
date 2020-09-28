//
//  ViewController.swift
//  Disperse
//
//  Created by Tim Gegg-Harrison, Nicole Anderson on 12/20/13.
//  Copyright © 2013 TiNi Apps. All rights reserved.
//
//  Modified by Walker Morgan on 9/1/20.
//

import UIKit

class ViewController: UIViewController {

    private let MAXCARDS: Int = 10
    private let CARDS: [String] = ["AC", "AD", "AH", "AS"]
    private let BLUE: UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.609375, alpha: 1.0)
    private let RED: UIColor = UIColor(red: 0.733333, green: 0.0, blue: 0.0, alpha: 1.0)
    private let game: GameState = GameState()
    
    private var SUITSIZE: CGFloat = 0.0
    private var SUITOFFSET: CGFloat = 0.0
    
    private var SUITS: [UIImageView] = [
        UIImageView(),
        UIImageView(),
        UIImageView(),
        UIImageView()]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Lab 1 code goes here
        
        // Initialize variables
        SUITSIZE = view.frame.width/9       // Height and width of images are 1/9th of root view
        SUITOFFSET = view.frame.width/5     // Offset to create even spacing between suit images
        
        // Create an image view for each suit in the array
        SUITS[0] = UIImageView(frame: CGRect(x: SUITOFFSET * 1 - SUITSIZE/2, y: 80, width: SUITSIZE, height: SUITSIZE))
        SUITS[1] = UIImageView(frame: CGRect(x: SUITOFFSET * 2 - SUITSIZE/2, y: 80, width: SUITSIZE, height: SUITSIZE))
        SUITS[2] = UIImageView(frame: CGRect(x: SUITOFFSET * 3 - SUITSIZE/2, y: 80, width: SUITSIZE, height: SUITSIZE))
        SUITS[3] = UIImageView(frame: CGRect(x: SUITOFFSET * 4 - SUITSIZE/2, y: 80, width: SUITSIZE, height: SUITSIZE))
        
        // Assign suit assets to image properties
        SUITS[0].image = UIImage(named: "club")
        SUITS[1].image = UIImage(named: "diamond")
        SUITS[2].image = UIImage(named: "heart")
        SUITS[3].image = UIImage(named: "spade")
        
        // Add each club view to root subview
        for UIImageView in SUITS {
            view.addSubview(UIImageView)
        }
        
        // Create play button image view
        let playButton: UIImageView = UIImageView(frame: CGRect(x: view.center.x - view.frame.width/14, y: view.frame.height - (40 + view.frame.width/7), width: view.frame.width/7, height: view.frame.width/7))
        
        // Assign image properties to button assets
        playButton.image = UIImage(named: "play")
        playButton.highlightedImage = UIImage(named: "playH")
        
        playButton.isHighlighted = false
        
        view.addSubview(playButton)
        
    }
    
    // The following 3 methods were "borrowed" from http://stackoverflow.com/questions/15710853/objective-c-check-if-subviews-of-rotated-uiviews-intersect and converted to Swift
    private func projectionOfPolygon(poly: [CGPoint], onto: CGPoint) ->  (min: CGFloat, max: CGFloat) {
        var minproj: CGFloat = CGFloat.greatestFiniteMagnitude
        var maxproj: CGFloat = -CGFloat.greatestFiniteMagnitude
        for point in poly {
            let proj: CGFloat = point.x * onto.x + point.y * onto.y
            if proj > maxproj {
                maxproj = proj
            }
            if proj < minproj {
                minproj = proj
            }
        }
        return (minproj, maxproj)
    }
    
    private func convexPolygon(poly1: [CGPoint], poly2: [CGPoint]) -> Bool {
        for i in 0 ..< poly1.count {
            // Perpendicular vector for one edge of poly1:
            let p1: CGPoint = poly1[i];
            let p2: CGPoint = poly1[(i+1) % poly1.count];
            let perp: CGPoint = CGPoint(x: p1.y - p2.y, y: p2.x - p1.x)
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            let (minp1,maxp1): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly1, onto: perp)
            let (minp2,maxp2): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly2, onto: perp)
            // If projections do not overlap then we have a "separating axis" which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        // And now the other way around with edges from poly2:
        for i in 0 ..< poly2.count {
            // Perpendicular vector for one edge of poly2:
            let p1: CGPoint = poly2[i];
            let p2: CGPoint = poly2[(i+1) % poly2.count];
            let perp: CGPoint = CGPoint(x: p1.y - p2.y, y:
                p2.x - p1.x)
            // Projection intervals of poly1, poly2 onto perpendicular vector:
            let (minp1,maxp1): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly1, onto: perp)
            let (minp2,maxp2): (CGFloat,CGFloat) = projectionOfPolygon(poly: poly2, onto: perp)
            // If projections do not overlap then we have a "separating axis" which means that the polygons do not intersect:
            if maxp1 < minp2 || maxp2 < minp1 {
                return false
            }
        }
        return true
    }

    private func viewsIntersect(view1: UIView, view2: UIView) -> Bool {
        return convexPolygon(poly1: [view1.convert(view1.bounds.origin, to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x + view1.bounds.size.width, y: view1.bounds.origin.y), to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x + view1.bounds.size.width, y: view1.bounds.origin.y + view1.bounds.height), to: nil), view1.convert(CGPoint(x: view1.bounds.origin.x, y: view1.bounds.origin.y + view1.bounds.height), to: nil)], poly2: [view2.convert(view1.bounds.origin, to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x + view2.bounds.size.width, y: view2.bounds.origin.y), to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x + view2.bounds.size.width, y: view2.bounds.origin.y + view2.bounds.height), to: nil), view2.convert(CGPoint(x: view2.bounds.origin.x, y: view2.bounds.origin.y + view2.bounds.height), to: nil)])
    }
    
    private func cardIsOpenAtIndex(i: Int) -> Bool {
        for k in i+1 ..< game.board.count {
            if viewsIntersect(view1: game.board[i], view2: game.board[k]) {
                return false
            }
        }
        return true
    }
    
    private func highlightOpenCards() {
        for i in 0 ..< game.board.count {
            let open: Bool = cardIsOpenAtIndex(i: i)
            game.board[i].isHighlighted = open
            game.board[i].isUserInteractionEnabled = open
        }
    }
    
    private func createCards() {
        let w = 0.25*view.frame.width
        let h = (351.0/230.0)*w
        var cardSuit: Int = 0
        game.board = [UIImageView]()
        game.cardsRemaining = MAXCARDS + Int.random(in: 0...MAXCARDS/2)
        for i in 0 ..< game.cardsRemaining {
            let card: UIImageView = UIImageView(image: UIImage(named: CARDS[cardSuit]), highlightedImage: UIImage(named: "\(CARDS[cardSuit])H"))
            card.isHighlighted = false
            card.tag = i
            card.frame = CGRect(x: CGFloat.random(in: 0.35...0.85)*view.frame.width - w, y: CGFloat.random(in: 0.40...0.80)*view.frame.height - h, width: w, height: h)
            card.transform = CGAffineTransform(rotationAngle: CGFloat.random(in: 0.0...45.0)*CGFloat.pi/180.0)
            view.addSubview(card)
            game.board.append(card)
            cardSuit = (cardSuit + 1) % 4
        }
    }
    
    private func nextTurn() {
        game.blueTurn = !game.blueTurn
        view.backgroundColor = game.blueTurn ? BLUE : RED
        highlightOpenCards()
    }
 
    func enterNewGame() {
        createCards()
        nextTurn()
    }
    
}
