//
//  EventsDetailViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

import UIKit
import RxSwift
import RxCocoa

class EventsDetailViewController: BaseViewController {

	private let viewModel: EventDetailViewModel
	private let disposeBag = DisposeBag()

	// MARK: UI Elements
	private let tableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .globe
		table.separatorStyle = .none
		table.register(cellType: OddTableViewCell.self)
		return table
	}()


	// MARK: - Initialization
	init(eventKey: String) {
		self.viewModel = EventDetailViewModel(eventKey: eventKey)
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		setupUI()
		bindViewModel()
		viewModel.input.viewDidLoad.onNext(())
	}

	// MARK: Setup UI
	private func setupUI() {
		let titleLabel = UILabel()
		titleLabel.text = "Odds"
		titleLabel.backgroundColor = .clear
		titleLabel.textColor = .textWhite
		titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
		titleLabel.textAlignment = .center

		self.navigationItem.titleView = titleLabel

		view.addSubview(tableView)
		view.backgroundColor = .globe

		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.bottom.equalToSuperview()
		}

	}

	// MARK: - Bind ViewModel
	private func bindViewModel() {
		tableView.rx.setDelegate(self)
			.disposed(by: disposeBag)

		viewModel.output.odds
			.drive(tableView.rx.items(
				cellIdentifier: OddTableViewCell.reuseId,
				cellType: OddTableViewCell.self)
			) { [weak self] row, item, cell in
				guard let self = self else { return }
				cell.configure(
					with: item,
					basketUpdates: self.viewModel.output.basketUpdates
				)
				cell.selectionStyle = .none
				cell.rx.tap
					.compactMap { [weak cell] tappedIndex -> (oddIndex: Int, event: OddsResponse)? in
						guard let cell = cell, let event = cell.currentEvent else { return nil }
						return (oddIndex: tappedIndex, event: event)
					}
					.bind(to: self.viewModel.input.oddSelected)
					.disposed(by: cell.disposeBag)
			}
			.disposed(by: disposeBag)

		viewModel.output.isLoading
			.drive(onNext: { [weak self] loading in
				guard let self = self else { return }
				if loading {
					self.isLoading = true
				} else {
					self.isLoading = false
				}
			})
			.disposed(by: disposeBag)

		viewModel.output.error
			.drive(onNext: { [weak self] error in
				guard let error = error else { return }
				guard let self = self else { return }
				self.showErrorAlert(message: error.localizedDescription)
			})
			.disposed(by: disposeBag)
	}
}

extension EventsDetailViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
}
