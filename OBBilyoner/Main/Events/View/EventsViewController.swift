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
	private var isSearchActive = false

	// MARK: UI Elements
	private let tableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .globe
		table.separatorStyle = .none
		table.register(cellType: EventTableViewCell.self)
		return table
	}()

	private let headerView: UIView = {
		let view = UIView()
		return view
	}()

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Etkinlikler"
		label.textColor = .white
		label.font = .systemFont(ofSize: 24, weight: .bold)
		return label
	}()

	private let searchButton: UIButton = {
		let button = UIButton(type: .system)
		button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
		button.tintColor = .white
		return button
	}()

	private let searchBar: UISearchBar = {
		let searchBar = UISearchBar()
		searchBar.searchBarStyle = .minimal
		searchBar.searchTextField.textColor = .white
		searchBar.tintColor = .white
		let attributes: [NSAttributedString.Key: Any] = [
			.foregroundColor: UIColor.textTertiary
		]
		searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Etkinlik ara...", attributes: attributes)
		return searchBar
	}()

	private lazy var keyboardToolbar: UIToolbar = {
		let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
		toolbar.backgroundColor = .systemBackground

		let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
		let doneButton = UIBarButtonItem(title: "Tamam", style: .done, target: self, action: #selector(closeKeyboard))
		toolbar.items = [flexSpace, doneButton]
		return toolbar
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
		view.addSubview(headerView)
		headerView.addSubview(titleLabel)
		headerView.addSubview(searchButton)
		headerView.addSubview(searchBar)
		view.backgroundColor = .globe

		searchBar.searchTextField.inputAccessoryView = keyboardToolbar
		searchBar.alpha = 0

		headerView.snp.makeConstraints { make in
			make.top.equalTo(view.safeAreaLayoutGuide)
			make.leading.equalToSuperview().offset(16)
			make.trailing.equalToSuperview().offset(-16)
			make.height.equalTo(50)
		}

		titleLabel.snp.makeConstraints { make in
			make.leading.equalToSuperview().offset(16)
			make.centerY.equalToSuperview()
		}

		searchButton.snp.makeConstraints { make in
			make.trailing.equalToSuperview()
			make.centerY.equalToSuperview()
			make.size.equalTo(CGSize(width: 30, height: 30))
		}

		searchBar.snp.makeConstraints { make in
			make.leading.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
			make.trailing.equalTo(searchButton.snp.leading).offset(-4)
		}

		tableView.snp.makeConstraints { make in
			make.top.equalTo(headerView.snp.bottom).offset(10)
			make.leading.trailing.bottom.equalToSuperview()
		}

		setupSearchButton()

	}

	private func setupSearchButton() {
		searchButton.rx.tap
			.subscribe(onNext: { [weak self] in
				self?.toggleSearch()
			})
			.disposed(by: disposeBag)
	}

	private func toggleSearch() {
		isSearchActive.toggle()
		UIView.animate(withDuration: 0.3) { [weak self] in
			guard let self = self else { return }

			if isSearchActive {
				self.titleLabel.alpha = 0
				self.searchBar.alpha = 1
				self.searchButton.setImage(UIImage(systemName: "xmark"), for: .normal)
				self.searchButton.transform = CGAffineTransform(rotationAngle: .pi)
				self.searchBar.becomeFirstResponder()
			} else {
				self.titleLabel.alpha = 1
				self.searchBar.alpha = 0
				self.searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
				self.searchButton.transform = .identity
				self.searchBar.text = ""
				self.viewModel.input.searchText.onNext("")
				self.searchBar.resignFirstResponder()
			}
		}

	}

	@objc private func closeKeyboard() {
		searchBar.resignFirstResponder()
	}

	// MARK: - Bind ViewModel
	private func bindViewModel() {
		viewModel.output.filteredEvents
			.drive(tableView.rx.items(cellIdentifier: EventTableViewCell.reuseIdentifier, cellType: EventTableViewCell.self)) { row, event, cell in
				cell.selectionStyle = .none
				cell.configure(with: event)
			}
			.disposed(by: disposeBag)

		searchBar.rx.text.orEmpty
			.debounce(.milliseconds(300), scheduler: MainScheduler.instance)
			.distinctUntilChanged()
			.bind(to: viewModel.input.searchText)
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
