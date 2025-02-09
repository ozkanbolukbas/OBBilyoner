//
//  BasketViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//
import UIKit
import RxSwift
import RxCocoa
import SnapKit

class BasketViewController: UIViewController {
	private let disposeBag = DisposeBag()
	private let viewModel = BasketViewModel.shared

	// MARK: UI Elements
	private let tableView: UITableView = {
		let table = UITableView()
		table.backgroundColor = .clear
		table.separatorStyle = .none
		table.register(BasketEventCell.self, forCellReuseIdentifier: BasketEventCell.reuseIdentifier)
		return table
	}()

	private let totalView: UIView = {
		let view = UIView()
		view.backgroundColor = .systemBackground
		view.layer.shadowColor = UIColor.black.cgColor
		view.layer.shadowOffset = CGSize(width: 0, height: -2)
		view.layer.shadowOpacity = 0.1
		view.layer.shadowRadius = 4
		return view
	}()

	private let totalLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.text = "Total:"
		return label
	}()

	private let totalAmountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 20, weight: .bold)
		label.textColor = .systemBlue
		return label
	}()

	private let placeBetButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("HEMEN OYNA", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
		button.backgroundColor = .systemBlue
		button.setTitleColor(.white, for: .normal)
		button.layer.cornerRadius = 8
		return button
	}()

	private let quickBetStackView: UIStackView = {
		let stack = UIStackView()
		stack.axis = .horizontal
		stack.distribution = .fillEqually
		stack.spacing = 8
		return stack
	}()

	private let betAmountLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.text = "Kupon Bedeli:"
		return label
	}()

	private let betAmountValueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.text = "0.00 TL"
		return label
	}()

	private let totalOddsLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.text = "Toplam Oran:"
		return label
	}()

	private let totalOddsValueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.text = "0.00"
		return label
	}()

	private let maxWinLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .medium)
		label.text = "Maks. Kazanç:"
		return label
	}()

	private let maxWinValueLabel: UILabel = {
		let label = UILabel()
		label.font = .systemFont(ofSize: 16, weight: .bold)
		label.text = "0.00 TL"
		return label
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		bindViewModel()
	}

	// MARK: Setup UI
	private func setupUI() {
		view.backgroundColor = .systemBackground
		title = "Basket"

		let quickBetAmounts = [50, 100, 500, 1000, 7500]
		quickBetAmounts.forEach { amount in
			let button = UIButton(type: .system)
			button.setTitle("+\(amount)", for: .normal)
			button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
			button.backgroundColor = .systemGray6
			button.setTitleColor(.label, for: .normal)
			button.layer.cornerRadius = 4
			quickBetStackView.addArrangedSubview(button)
		}

		view.addSubview(tableView)
		view.addSubview(quickBetStackView)
		view.addSubview(totalView)

		let infoStackView = UIStackView(arrangedSubviews: [
			makeHorizontalStack(label: betAmountLabel, valueLabel: betAmountValueLabel),
			makeHorizontalStack(label: totalOddsLabel, valueLabel: totalOddsValueLabel),
			makeHorizontalStack(label: maxWinLabel, valueLabel: maxWinValueLabel),
			makeHorizontalStack(label: totalLabel, valueLabel: totalAmountLabel)
		])
		infoStackView.axis = .vertical
		infoStackView.spacing = 8

		totalView.addSubview(infoStackView)
		totalView.addSubview(placeBetButton)

		tableView.snp.makeConstraints { make in
			make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
			make.bottom.equalTo(quickBetStackView.snp.top).offset(-16)
		}

		quickBetStackView.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalTo(totalView.snp.top).offset(-16)
			make.height.equalTo(40)
		}

		totalView.snp.makeConstraints { make in
			make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
			make.height.equalTo(160)
		}

		infoStackView.snp.makeConstraints { make in
			make.top.leading.trailing.equalToSuperview().inset(16)
		}

		placeBetButton.snp.makeConstraints { make in
			make.leading.trailing.equalToSuperview().inset(16)
			make.bottom.equalToSuperview().inset(16)
			make.height.equalTo(44)
		}
	}

	/// Helper method to create a horizontal stack for a label pair.
	private func makeHorizontalStack(label: UILabel, valueLabel: UILabel) -> UIStackView {
		let stack = UIStackView(arrangedSubviews: [label, valueLabel])
		stack.axis = .horizontal
		stack.distribution = .equalSpacing
		return stack
	}

	// MARK: - Bind ViewModel

	private func bindViewModel() {
		// Bind basket events to the table view.
		viewModel.output.events
			.drive(tableView.rx
				.items(cellIdentifier: BasketEventCell.reuseIdentifier,
					   cellType: BasketEventCell.self)) { [weak self] row, event, cell in
				guard let self = self else { return }
				cell.configure(with: event)
				cell.removeButton.rx.tap
					.map { row }
					.bind(to: self.viewModel.input.removeEvent)
					.disposed(by: cell.disposeBag)
			}
					   .disposed(by: disposeBag)

		viewModel.output.totalAmount
			.drive(totalAmountLabel.rx.text)
			.disposed(by: disposeBag)

		viewModel.output.betAmount
			.drive(betAmountValueLabel.rx.text)
			.disposed(by: disposeBag)

		viewModel.output.totalOdds
			.drive(totalOddsValueLabel.rx.text)
			.disposed(by: disposeBag)

		viewModel.output.maxWin
			.drive(maxWinValueLabel.rx.text)
			.disposed(by: disposeBag)

		placeBetButton.rx.tap
			.bind(to: viewModel.input.placeBet)
			.disposed(by: disposeBag)

		quickBetStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach { button in
			button.rx.tap
				.map { Double(button.title(for: .normal)?.replacingOccurrences(of: "+", with: "") ?? "0") ?? 0 }
				.bind(to: viewModel.input.quickBetAmount)
				.disposed(by: disposeBag)
		}
	}
}

#Preview {
	BasketViewController()
}
