//
//  ViewController.swift
//  NGPopoverForceResizeTest
//
//  Created by Noah Gilmore on 8/15/19.
//  Copyright © 2019 Noah Gilmore. All rights reserved.
//

import UIKit

class LargeViewControllerWithNavBar: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()
    var heightConstraint: NSLayoutConstraint! = nil
    var isExpanded: Bool = false {
        didSet {
            if self.isExpanded {
                self.heightConstraint.constant = 600
            } else {
                self.heightConstraint.constant = 400
            }
            self.setPreferredContentSizeFromAutolayout()
        }
    }

    override func viewDidLoad() {
        self.view.backgroundColor = .green
        self.title = "This is a title"

        let label = UILabel()
        label.text = "This controller starts at 600x400"

        let button = UIButton()
        button.setTitle("Tap to expand/contract", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        let widthConstraint = self.view.widthAnchor.constraint(equalToConstant: 600)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true
        heightConstraint = self.view.heightAnchor.constraint(equalToConstant: 400)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }

    func setPreferredContentSizeFromAutolayout() {
        let contentSize = self.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
        self.preferredContentSize = contentSize
        self.popoverPresentationController?
            .presentedViewController
            .preferredContentSize = contentSize
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.setPreferredContentSizeFromAutolayout()
    }

    @objc private func didTap() {
        self.isExpanded = !self.isExpanded
    }
}


class SmallViewControllerNoNavBar: UIViewController {
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 10
        return view
    }()

    override func viewDidLoad() {
        self.view.backgroundColor = .red

        let label = UILabel()
        label.text = "This controller is 300x300"

        let button = UIButton()
        button.setTitle("Push another controller", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)

        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(button)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true

        let widthConstraint = self.view.widthAnchor.constraint(equalToConstant: 300)
        widthConstraint.priority = .defaultHigh
        widthConstraint.isActive = true
        let heightConstraint = self.view.heightAnchor.constraint(equalToConstant: 300)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.preferredContentSize = self.view.systemLayoutSizeFitting(
            UIView.layoutFittingCompressedSize
        )
    }

    @objc private func didTap() {
        self.navigationController?.pushViewController(LargeViewControllerWithNavBar(), animated: true)
    }
}

final class PopoverPushController: UIViewController {
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
}

extension PopoverPushController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        // Set our preferred content size so that UIKit knows to animate down to the new view controller's
        // preferred content size
        self.preferredContentSize = viewController.preferredContentSize
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
//        let containerController = UINavigationController(rootViewController: firstVC)
        let containerController = PopoverPushController(rootViewController: firstVC)
        containerController.modalPresentationStyle = .popover
        containerController.popoverPresentationController?.sourceRect = button.frame
        containerController.popoverPresentationController?.sourceView = self.view
        containerController.popoverPresentationController?.permittedArrowDirections = .up
        self.present(containerController, animated: true)
    }
}

