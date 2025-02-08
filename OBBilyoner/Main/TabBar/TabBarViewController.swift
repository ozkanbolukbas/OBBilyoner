//
//  TabBarViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//
import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func setupViews() {
		// Create view controllers for each tab
		let homeVC = HomeViewController()
		let basketVC = HomeViewController()
		let eventsVC = HomeViewController()

		// Set the view controllers for tab bar
		homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
		eventsVC.tabBarItem = UITabBarItem(title: "Events", image: UIImage(systemName: "sportscourt"), tag: 1)
		basketVC.tabBarItem = UITabBarItem(title: "Basket", image: UIImage(systemName: "cart"), tag: 2)
		self.viewControllers = [UINavigationController(rootViewController: homeVC), UINavigationController(rootViewController: eventsVC)]

		//Configure tab bar appearance
		self.tabBar.tintColor = .systemBlue
		self.tabBar.backgroundColor = .systemBackground

		// Create custom basket button
		let basketButton = UIButton(frame: CGRect(x: 0, y: 0, width: 64, height: 64))
		basketButton.backgroundColor = .systemBlue
		basketButton.layer.cornerRadius = 32
		basketButton.layer.masksToBounds = true
		basketButton.center = CGPoint(x: self.tabBar.center.x, y: 20)
		basketButton.tintColor = .white

		// Create labels for match count and total price
		let matchCountLabel = UILabel(frame: CGRect(x: 0, y: 12, width: 64, height: 20))
		matchCountLabel.textAlignment = .center
		matchCountLabel.font = .systemFont(ofSize: 14, weight: .bold)
		matchCountLabel.textColor = .white
		matchCountLabel.text = "0"

		let totalPriceLabel = UILabel(frame: CGRect(x: 0, y: 32, width: 64, height: 20))
		totalPriceLabel.textAlignment = .center
		totalPriceLabel.font = .systemFont(ofSize: 12, weight: .medium)
		totalPriceLabel.textColor = .white
		totalPriceLabel.text = "₺0.00"

		basketButton.addSubview(matchCountLabel)
		basketButton.addSubview(totalPriceLabel)

		//Add basket button to tab bar
		self.tabBar.addSubview(basketButton)

	}
}
