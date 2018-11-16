//
//  AlertViewController.swift
//  Coins Capitalization
//
//  Created by Artem Kirillov on 20.07.2018.
//  Copyright © 2018 ASK LLC. All rights reserved.
//

import UIKit

final class AlertViewController: UIViewController {
    
    // MARK: - Public Nested
    
    enum Orientation {
        case vertical
        case horizontal
    }
    
    class ActionButton: UIButton {
        
        // MARK: - Constructors
        
        init(title: String, action: (() -> Void)?) {
            self.action = action
            super.init(frame: .zero)
            
            setTitle(title, for: .normal)
            setupUI()
            addTarget(self, action: #selector(ActionButton.tapped), for: .touchUpInside)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Public Methods
        
        func setupUI() {
            backgroundColor = Colors.actionButtonBackground
            setTitleColor(.white, for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 16.0, weight: .medium)
            heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        }
        
        @objc func tapped() {
            action?()
        }
        
        // MARK: - Private Properties
        
        private let action: (() -> Void)?
    }
    
    // MARK: - Public Properties
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var header: String?
    var message: String?
    var image: UIImage?
    var orientation: Orientation = .vertical
    
    // MARK: - Public Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertView.layer.cornerRadius = 10.0
        titleLabel.text = header
        descriptionLabel.text = message
        imageView.image = image
        
        switch orientation {
        case .vertical:   buttonsStackView.axis = .vertical
        case .horizontal: buttonsStackView.axis = .horizontal
        }
        
        buttons.forEach { buttonsStackView.addArrangedSubview($0) }
    }
    
    func addAction(title: String, handler: (() -> Void)?) {
        buttons.append(ActionButton(title: title, action: handler))
    }
    
    // MARK: - Private Properties
    
    @IBOutlet private weak var alertView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    @IBOutlet private weak var buttonsStackView: UIStackView!
    
    private var buttons: [ActionButton] = []
    
}

extension UIViewController {
    
    // MARK: - Public Nested
    
    class Action {
        var title: String
        var handler: (() -> Void)?
        
        init(title: String, handler: (() -> Void)?) {
            self.title = title
            self.handler = handler
        }
    }
    
    func showAlert(title: String?, message: String?, image: UIImage?, actions: [Action], orientation: AlertViewController.Orientation = .vertical) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = title
                controller.message = message
                controller.image = image
                actions.forEach { controller.addAction(title: $0.title, handler: $0.handler) }
                
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func showAlert(title: String?, message: String?, image: UIImage?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            if let controller = self?.storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as? AlertViewController {
                controller.header = title
                controller.message = message
                controller.image = image
                controller.addAction(title: NSLocalizedString("Ok", comment: ""),
                                     handler: { [weak controller] in controller?.dismiss(animated: true, completion: nil) })
                self?.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    func showErrorAlert(title: String?, message: String?) {
        showAlert(title: title, message: message, image: #imageLiteral(resourceName: "warning"))
    }
    
    func showErrorAlert(_ error: Error) {
        showErrorAlert(title: NSLocalizedString("Something has gone wrong", comment: ""),
                  message: error.localizedDescription)
    }
    
}
