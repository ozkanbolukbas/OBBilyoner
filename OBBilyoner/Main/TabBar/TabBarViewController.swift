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
		let selectedEventsVM = SelectedEventsViewModel()
		let selectedEventsVC = SelectedEventsViewController(viewModel: selectedEventsVM)
		let basketVM = BasketViewModel.shared
		let basketVC = BasketViewController(viewModel: basketVM)
		let eventsVM = EventsViewModel()
		let eventsVC = EventsViewController(viewModel: eventsVM)

		// Set the view controllers for tab bar
		eventsVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
		selectedEventsVC.tabBarItem = UITabBarItem(title: "Events", image: UIImage(systemName: "sportscourt"), tag: 1)
		basketVC.tabBarItem = UITabBarItem(title: "Basket", image: UIImage(systemName: "cart"), tag: 2)
		self.viewControllers = [UINavigationController(rootViewController: eventsVC), UINavigationController(rootViewController: selectedEventsVC)]

		//Configure tab bar appearance
		self.tabBar.tintColor = .systemBlue
		self.tabBar.backgroundColor = .systemBackground

		// Create custom basket button.
		let basketButton = UIButton()
		basketButton.backgroundColor = .systemBlue
		basketButton.layer.cornerRadius = 40
		basketButton.layer.masksToBounds = true
		basketButton.tintColor = .white

		basketButton.addTarget(self, action: #selector(basketButtonTapped), for: .touchUpInside)

		// Create labels for match count and total odds.
		matchCountLabel = UILabel()
		matchCountLabel.textAlignment = .center
		matchCountLabel.font = .systemFont(ofSize: 14, weight: .bold)
		matchCountLabel.textColor = .white
		matchCountLabel.text = "0"

		totalOddsLabel = UILabel()
		totalOddsLabel.textAlignment = .center
		totalOddsLabel.font = .systemFont(ofSize: 12, weight: .medium)
		totalOddsLabel.minimumScaleFactor = 0.8
		totalOddsLabel.textColor = .white
		totalOddsLabel.text = "0.00"

		basketButton.addSubview(matchCountLabel)
		basketButton.addSubview(totalOddsLabel)
		self.tabBar.addSubview(basketButton)

		basketButton.snp.makeConstraints { make in
			make.centerX.equalTo(self.tabBar.snp.centerX)
			make.top.equalTo(self.tabBar.snp.top).offset(-20)
			make.width.height.equalTo(80)
		}

		matchCountLabel.snp.makeConstraints { make in
			make.top.equalToSuperview().offset(12)
			make.centerX.equalToSuperview()
			make.height.equalTo(20)
		}
		totalOddsLabel.snp.makeConstraints { make in
			make.top.equalTo(matchCountLabel.snp.bottom).offset(4)
			make.centerX.equalToSuperview()
			make.height.equalTo(20)
		}

	}

	@objc private func basketButtonTapped() {
		// Create BasketViewController and present it modally.
		let basketVM = BasketViewModel.shared
		let basketVC = BasketViewController(viewModel: basketVM)
		let navController = UINavigationController(rootViewController: basketVC)
		navController.modalPresentationStyle = .pageSheet
		self.present(navController, animated: true, completion: nil)
	}

	func bindBasketViewModel() {
		// Bind the count of basket events to matchCountLabel.
		BasketViewModel.shared.output.events
			.map { "\($0.count) Maç" }
			.drive(matchCountLabel.rx.text)
			.disposed(by: disposeBag)

		// Bind total odds to the totalOddsLabel.
		BasketViewModel.shared.output.totalOdds
			.drive(totalOddsLabel.rx.text)
			.disposed(by: disposeBag)
	}
}
