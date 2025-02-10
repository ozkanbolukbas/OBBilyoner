//
//  EventsViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//


import UIKit
import RxSwift
import RxCocoa

class EventsViewController: BaseViewController {
	private let viewModel: EventsViewModel
	private let disposeBag = DisposeBag()

	// MARK: UI Elements
	private let tableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .globe
		table.separatorStyle = .none
		table.register(cellType: EventTableViewCell.self)
		return table
	}()

	// MARK: - Initialization
	init(viewModel: EventsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
		viewModel.input.viewDidLoad.onNext(())
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.navigationBar.isHidden = true
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.navigationController?.navigationBar.isHidden = false
	}

	// MARK: Setup UI
	private func setupUI() {
		view.addSubview(tableView)
		view.backgroundColor = .globe


		tableView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
			make.leading.trailing.bottom.equalToSuperview()
		}

	}

	// MARK: - Bind ViewModel
	private func bindViewModel() {
		viewModel.output.events
			.drive(tableView.rx.items(cellIdentifier: EventTableViewCell.reuseIdentifier, cellType: EventTableViewCell.self)) { row, event, cell in
				cell.selectionStyle = .none
				cell.configure(with: event)
			}
			.disposed(by: disposeBag)

		tableView.rx.itemSelected
			.bind(to: viewModel.input.selectRow)
			.disposed(by: disposeBag)

		viewModel.output.selectedEventKey
			.drive(onNext: { [weak self] eventKey in
				guard !eventKey.isEmpty else { return }
				let detailVC = EventsDetailViewController(eventKey: eventKey)
				self?.navigationController?.pushViewController(detailVC, animated: true)
			})
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

