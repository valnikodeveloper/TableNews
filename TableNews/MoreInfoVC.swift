//
//  MoreInfoVC.swift
//  TableNews
//
//  This clase is for expanding info what was got
//  Created by Valeriy on 08/12/2018.
//  Copyright © 2018 Valeriy Nikolaev. All rights reserved.
//

import UIKit

class MoreInfoVC: UIViewController,ImageTransmitDelegate {

    private var vertStackView:UIStackView = {
        let vertStack = UIStackView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        vertStack.translatesAutoresizingMaskIntoConstraints = false
        vertStack.axis = .vertical
        vertStack.alignment = .fill
        vertStack.distribution = .fill
        vertStack.spacing = 5
        return vertStack
    }()
    
    var pictureView:UIImageView = UIImageView()
    var authorLabel = UILabel()
    var moreInfoLabel = UILabel()
    private var scrollView = UIScrollView()
    private var waitingSpinner:UIActivityIndicatorView = UIActivityIndicatorView(style: .white)
    
    private func setupConstraints() {
        //scrollView constraints
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        //Author
        authorLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 252), for: .vertical)
        //pictureView constraints
        pictureView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        pictureView.heightAnchor.constraint(equalTo: pictureView.widthAnchor).isActive = true
        waitingSpinner.centerXAnchor.constraint(equalTo: pictureView.centerXAnchor).isActive = true
        waitingSpinner.centerYAnchor.constraint(equalTo: pictureView.centerYAnchor).isActive = true
        vertStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        vertStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        vertStackView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        vertStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        scrollView.updateConstraintsIfNeeded()
    }
    
    //In case if user tapped on row but image was not ready
    func imageTransmitDelegateMethod(image: UIImage?) {
        waitingSpinner.stopAnimating()
        pictureView.image = nil
        DispatchQueue.main.async {
            self.pictureView.image = image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {        
        if pictureView.image != nil {
            waitingSpinner.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        moreInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        waitingSpinner.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        authorLabel.numberOfLines = 3
        authorLabel.minimumScaleFactor = 0.5
        authorLabel.font =  authorLabel.font.withSize(authorLabel.font.calcSizeFont() + 3)
        moreInfoLabel.font = moreInfoLabel.font.withSize(moreInfoLabel.font.calcSizeFont() + 1)
        moreInfoLabel.numberOfLines = 0
        moreInfoLabel.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
        moreInfoLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        pictureView.addSubview(waitingSpinner)
        vertStackView.addArrangedSubview(pictureView)
        vertStackView.addArrangedSubview(authorLabel)
        vertStackView.addArrangedSubview(moreInfoLabel)
        scrollView.addSubview(vertStackView)
        view.addSubview(scrollView)
        pictureView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        pictureView.contentMode = .scaleToFill
        pictureView.translatesAutoresizingMaskIntoConstraints = false
        setupConstraints()
        waitingSpinner.startAnimating()
    }
}

