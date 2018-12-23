//
//  CellTableViewCell.swift
//  TableNews
//
//  Created by Valeriy on 14/11/2018.
//
// Copyright © 2018 Valeriy Nikolaev. All rights reserved.
import UIKit

class CellOfTableView: UITableViewCell {

    var imageNews:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
    var authorLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 225, height: 20))
    var descrLabel:UILabel = UILabel(frame: CGRect(x: 0, y: 20, width: 225, height: 139))
    
    var transmitImageDelegate:ImageTransmitDelegate?
    private var waitingSpinner:UIActivityIndicatorView!
    
    //Value observer when url is assigned
    //This cell is loading image by URLSession
    var urlToImg: URL? {
        didSet {
            loadImage()
        }
    }
    
    //Creates in any case
   private  var vertStackView:UIStackView = {
        let vertStack = UIStackView(frame: CGRect(x: 0, y: 0, width: 130, height: 130))
        vertStack.translatesAutoresizingMaskIntoConstraints = false
        vertStack.axis = .vertical
        vertStack.alignment = .fill
        vertStack.distribution = .fill
        vertStack.spacing = 0
        return vertStack
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    func loadImage(){
        imageNews.image = nil
        waitingSpinner.startAnimating()
        if let url = urlToImg {
            URLSession.shared.dataTask(with: url) {(dataFromServer, response , err)
                in
                if let imageData = dataFromServer {
                    DispatchQueue.main.async {
                            if url == self.urlToImg {
                                self.imageNews.image = UIImage(data: imageData)
                                self.transmitImageDelegate?.imageTransmitDelegateMethod(image: self.imageNews.image)
                                self.waitingSpinner.stopAnimating()
                            }
                    }
                }
            }.resume()
        }
    }

    func setNeededContentDimensions() {
        imageNews.heightAnchor.constraint(equalToConstant: contentView.frame.height * 0.90).isActive = true
        imageNews.widthAnchor.constraint(equalTo: imageNews.heightAnchor,constant:25).isActive = true
        imageNews.topAnchor.constraint(equalTo: contentView.topAnchor,constant:10).isActive = true
        imageNews.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant:5).isActive = true
        vertStackView.topAnchor.constraint(equalTo: contentView.topAnchor,constant:10).isActive = true
        vertStackView.heightAnchor.constraint(equalTo: imageNews.heightAnchor).isActive = true
        vertStackView.leadingAnchor.constraint(equalTo: imageNews.trailingAnchor,constant:5).isActive = true
        vertStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant:-5).isActive = true
        waitingSpinner.centerXAnchor.constraint(equalTo: imageNews.centerXAnchor).isActive = true
        waitingSpinner.centerYAnchor.constraint(equalTo: imageNews.centerYAnchor).isActive = true
        authorLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 252), for: .vertical)
        updateConstraintsIfNeeded()
    }
    
   private func initSubViews () {
        imageNews.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        descrLabel.translatesAutoresizingMaskIntoConstraints = false
        waitingSpinner = UIActivityIndicatorView(style: .white)
        waitingSpinner.translatesAutoresizingMaskIntoConstraints = false
        imageNews.addSubview(waitingSpinner)
        imageNews.contentMode = .scaleToFill
        contentView.addSubview(imageNews)
        vertStackView.addArrangedSubview(authorLabel)
        vertStackView.addArrangedSubview(descrLabel)
        contentView.addSubview(vertStackView)
        authorLabel.font =  authorLabel.font.withSize(authorLabel.font.calcSizeFont())
        descrLabel.font =  descrLabel.font.withSize(descrLabel.font.calcSizeFont() - 2)
        authorLabel.numberOfLines = 3
        authorLabel.minimumScaleFactor = 0.5
        descrLabel.numberOfLines = 5
        descrLabel.minimumScaleFactor = 0.5
        imageNews.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        descrLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        contentView.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
        authorLabel.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        descrLabel.backgroundColor = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: reuseIdentifier)
        initSubViews()
    }
}
