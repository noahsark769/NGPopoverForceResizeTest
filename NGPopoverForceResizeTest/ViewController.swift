//
//  ViewController.swift
//  NGPopoverForceResizeTest
//
//  Created by Noah Gilmore on 8/15/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

class LargeViewControllerWithNavBar: UIViewController {
    var button: UIButton! = nil
    var heightConstraint: NSLayoutConstraint! = nil

    override func viewDidLoad() {
        self.view.backgroundColor = .green
        self.title = "Title Here"

        button = UIButton()
        button.setTitle("Tap to expand", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.view.widthAnchor.constraint(equalToConstant: 600).isActive = true
        heightConstraint = self.view.heightAnchor.constraint(equalToConstant: 400)
        heightConstraint.isActive = true
    }

    func setPreferredContentSizeFromAutolayout() {
        let size = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentSize = CGSize(
            width: max(
                size.width,
                100
            ),
            height: size.height
        )
        self.preferredContentSize = contentSize
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.setPreferredContentSizeFromAutolayout()
    }

    @objc private func didTap() {
        heightConstraint.constant = 500
        setPreferredContentSizeFromAutolayout()
    }
}


class SmallViewControllerNoNavBar: UIViewController {
    var button: UIButton! = nil
    override func viewDidLoad() {
        self.view.backgroundColor = .red

        button = UIButton()
        button.setTitle("This view is 300x300", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false

        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        self.view.widthAnchor.constraint(equalToConstant: 300).isActive = true
        self.view.heightAnchor.constraint(equalToConstant: 300).isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let size = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let contentSize = CGSize(
            width: max(
                size.width,
                100
            ),
            height: size.height
        )
        self.preferredContentSize = contentSize
    }

    @objc private func didTap() {
        self.navigationController?.pushViewController(LargeViewControllerWithNavBar(), animated: true)
    }
}

final class PopoverPushNavigationController: UIViewController {
    private let wrappedNavigationController: UINavigationController

    init(rootViewController: UIViewController) {
        self.wrappedNavigationController = UINavigationController(rootViewController: rootViewController)
        super.init(nibName: nil, bundle: nil)
        self.wrappedNavigationController.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        wrappedNavigationController.willMove(toParent: self)
        self.addChild(wrappedNavigationController)
        self.view.addSubview(wrappedNavigationController.view)
    }

    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        self.preferredContentSize = container.preferredContentSize
    }
}

extension PopoverPushNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Set our preferred content size so that UIKit knows to animate down to the new view controller's
        // preferred content size
        navigationController.preferredContentSize = viewController.preferredContentSize

        // If there are no toolbar items, we don't want a nav bar
        navigationController.setToolbarHidden(viewController.toolbarItems?.isEmpty ?? true, animated: animated)
    }
}

class ViewController: UIViewController {
    var button: UIButton! = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        button = UIButton()
        button.setTitle("Show popover", for: .normal)
        button.setTitleColor(.blue, for: .normal)

        self.view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

        self.view.backgroundColor = .white
    }

    @objc private func didTap() {
        let firstVC = SmallViewControllerNoNavBar()
        let containerController = PopoverPushNavigationController(rootViewController: firstVC)
        containerController.modalPresentationStyle = .popover
        containerController.popoverPresentationController?.sourceRect = button.frame
        containerController.popoverPresentationController?.sourceView = self.view
        containerController.popoverPresentationController?.permittedArrowDirections = .up
        self.present(containerController, animated: true)
    }
}

