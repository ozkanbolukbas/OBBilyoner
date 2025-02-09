//
//  HomeViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {

	@IBOutlet weak var eventsCollectionView: UICollectionView!
	@IBOutlet weak var oddsTableView: UITableView!

	let viewModel = HomeViewModel()
	let disposeBag = DisposeBag()
	private let refreshControl = UIRefreshControl()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.navigationController?.isNavigationBarHidden = true
		eventsCollectionView.register(cellType: EventsCollectionViewCell.self)
		oddsTableView.register(cellType: OddTableViewCell.self)
		oddsTableView.refreshControl = refreshControl
		bindViewModel()
		viewModel.input.viewDidLoad.onNext(())
	}

	// MARK: - Bind ViewModel
	func bindViewModel() {
		refreshControl.rx.controlEvent(.valueChanged)
				   .bind(to: viewModel.input.refresh)
				   .disposed(by: disposeBag)

		eventsCollectionView.rx.setDelegate(self)
			.disposed(by: disposeBag)

		oddsTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)

		eventsCollectionView.rx.itemSelected
			.bind(to: viewModel.input.selectRow)
			.disposed(by: disposeBag)

		viewModel.output.categories
			.drive(eventsCollectionView.rx.items(
				cellIdentifier: EventsCollectionViewCell.reuseId,
				cellType: EventsCollectionViewCell.self)
			) { _, category, cell in
				cell.configure(with: category)
			}
			.disposed(by: disposeBag)

		viewModel.output.events
					.drive(oddsTableView.rx.items(
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
			.drive(onNext: { [weak self] isLoading in
				if !isLoading {
					self?.refreshControl.endRefreshing()
				}
			})
			.disposed(by: disposeBag)

		// Bind errors
		viewModel.output.error
			.drive(onNext: { [weak self] error in
				guard let error = error else { return }
				self?.showError(error)
			})
			.disposed(by: disposeBag)
		viewModel.output.selectedCategoryIndex
				 .drive(onNext: { [weak self] index in
					 self?.updateSelectedCategory(at: index)
				 })
				 .disposed(by: disposeBag)
	}

	private func showError(_ error: Error) {
		let alert = UIAlertController(
			title: "Error",
			message: error.localizedDescription,
			preferredStyle: .alert
		)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	private func updateSelectedCategory(at index: Int) {
		eventsCollectionView.visibleCells.forEach { cell in
			guard let eventCell = cell as? EventsCollectionViewCell,
				  let cellIndex = eventsCollectionView.indexPath(for: cell) else { return }
			eventCell.updateSelection(isSelected: cellIndex.row == index)
		}
	}


}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 80, height: 80)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacing: CGFloat) -> CGFloat {
		return 8
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacing: CGFloat) -> CGFloat {
		return 8
	}

}

extension HomeViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120
	}
}


#Preview {
	HomeViewController()
}
