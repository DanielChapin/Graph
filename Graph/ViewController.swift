//
//  ViewController.swift
//  Graph
//
//  Created by admin on 12/7/19.
//  Copyright © 2019 chapin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let graph = Graph(frame: view.frame)
        for _ in 0...25 {
            graph.append(.random() * view.frame.height)
        }
        view.addSubview(graph)
    }


}

