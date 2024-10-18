//
//  RetainViewController.swift
//  Example
//
//  Created by Hoàng Hiệp on 16/9/24.
//

import UIKit
import RxSwift
import RxCocoa

class RetainViewController: UIViewController {
    
    let bag = DisposeBag()
    let group = DispatchGroup()
    let queue = DispatchQueue.global()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let btn = UIButton()
        btn.frame = .init(origin: .zero, size: .init(width: 100, height: 100))
        btn.center = self.view.center
        btn.setTitle("demo", for: .normal)
        self.view.backgroundColor = .blue
        self.view.addSubview(btn)
    
        btn.rx.tap.subscribe(onNext: { [self]_ in
            self.test()
            self.dismiss(animated: true)
        }).disposed(by: bag)
    }
    
    func test () {
        print("queue.async")
    }
    
    deinit {
        print("on deinit")
    }
    
}
