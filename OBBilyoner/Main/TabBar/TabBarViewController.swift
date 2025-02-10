//
//  TabBarViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//
import UIKit
import RxSwift
import RxCocoa

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

	private let disposeBag = DisposeBag()
	private var matchCountLabel: UILabel!
	private var totalOddsLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
		bindBasketViewModel()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

	func setupViews() {
		// Create view controllers for each tab
		let homeVM = HomeViewModel()
		let homeVC = HomeViewController(viewModel: homeVM)
		let basketVC = HomeViewController(viewModel: homeVM)
		let basketVM = BasketViewModel.shared
		let eventsVC = BasketViewController(viewModel: basketVM)

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
		matchCountLabel = UILabel(frame: CGRect(x: 0, y: 12, width: 64, height: 20))
		matchCountLabel.textAlignment = .center
		matchCountLabel.font = .systemFont(ofSize: 14, weight: .bold)
		matchCountLabel.textColor = .white
		matchCountLabel.text = "0"

		totalOddsLabel = UILabel(frame: CGRect(x: 0, y: 32, width: 64, height: 20))
		totalOddsLabel.textAlignment = .center
		totalOddsLabel.font = .systemFont(ofSize: 12, weight: .medium)
		totalOddsLabel.textColor = .white
		totalOddsLabel.text = "0.00"

		basketButton.addSubview(matchCountLabel)
		basketButton.addSubview(totalOddsLabel)

		//Add basket button to tab bar
		self.tabBar.addSubview(basketButton)

	}

	func bindBasketViewModel() {
		// Bind the count of basket events to matchCountLabel.
		// The BasketViewModel.shared.output.events is a Driver<[BasketModel]>.
		// We map the array to its count and convert it to a String.
		BasketViewModel.shared.output.events
			.map { "\($0.count)" }
			.drive(matchCountLabel.rx.text)
			.disposed(by: disposeBag)

		// Bind total odds to the totalOddsLabel.
		// totalOdds is already a Driver<String> formatted to two decimals.
		BasketViewModel.shared.output.totalOdds
			.drive(totalOddsLabel.rx.text)
			.disposed(by: disposeBag)
	}
}
