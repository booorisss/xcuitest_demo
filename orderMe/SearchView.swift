//
//  Search.swift
//  orderMe
//
//  Created by Bohdan Koshyrets on 2/6/18.
//  Copyright © 2018 Boris Gurtovoy. All rights reserved.
//

import UIKit

protocol SearchViewDelegate: class {
    func updateSearchResults(for searchField: UITextField, text: String)
    func userDidPressQRButton()
}

class SearchView: UIView {
    
    var searchField: UITextField!
    var qrCodeButton: UIButton!
    private var stackView: UIStackView!
    
    weak var searchResultsUpdater: SearchViewDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.searchField = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        self.searchField.borderStyle = .none
        self.searchField.font = UIFont.systemFont(ofSize: 18)
        self.searchField.backgroundColor = UIColor.white
        self.searchField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        self.searchField.layer.sublayerTransform = CATransform3DMakeTranslation(12, 0, 0)
        
        self.qrCodeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
//        self.qrCodeButton.setImage(#imageLiteral(resourceName: "bt_qr_code"), for: .normal)
        self.qrCodeButton.backgroundColor = .white
        self.qrCodeButton.imageView?.contentMode = .scaleAspectFit
        self.qrCodeButton.layer.shadowRadius = 5.0
        self.qrCodeButton.layer.shadowOpacity = 0.2
        self.qrCodeButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.qrCodeButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.qrCodeButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        self.layer.insertSublayer(self.themeGradient(), at: 0)
        self.stackView = UIStackView(arrangedSubviews: [searchField, qrCodeButton])
        self.stackView.frame = frame
        self.stackView.alignment = UIStackView.Alignment.center
        self.stackView.spacing = 15
        self.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 18.0, bottom: 0, right: 18.0)
        self.stackView.isLayoutMarginsRelativeArrangement = true
        
        self.addSubview(stackView)
        self.qrCodeButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        
        searchField.delegate = self
        searchField.accessibilityIdentifier = "SearchField"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIView().endEditing(true)
        searchField.resignFirstResponder()
        return false
    }
    
    override func layoutSubviews() {
        self.stackView.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        self.searchField.layer.cornerRadius = searchField.bounds.height / 2
        self.qrCodeButton.layer.cornerRadius = qrCodeButton.bounds.height / 2

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonPressed() {
        searchResultsUpdater?.userDidPressQRButton()
    }
}

extension SearchView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchResultsUpdater?.updateSearchResults(for: textField, text: textField.text ?? "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let textFieldText = (textField.text ?? "") as NSString
        let textAfterUpdate = textFieldText.replacingCharacters(in: range, with: string)
        
        searchResultsUpdater?.updateSearchResults(for: textField, text: textAfterUpdate)
        return true
    }
}
