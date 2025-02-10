//
//  SelectedEventsViewController.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import UIKit
import RxSwift
import RxCocoa

class SelectedEventsViewController: BaseViewController {

	@IBOutlet weak var eventsCollectionView: UICollectionView!
	@IBOutlet weak var oddsTableView: UITableView!

	let viewModel: SelectedEventsViewModel
	let disposeBag = DisposeBag()
	private let refreshControl = UIRefreshControl()

	init(viewModel: SelectedEventsViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()

	}

	private func setupUI() {
		self.navigationController?.isNavigationBarHidden = true
		eventsCollectionView.register(cellType: EventsCollectionViewCell.self)
		oddsTableView.register(cellType: OddTableViewCell.self)
		oddsTableView.refreshControl = refreshControl
		bindViewModel()
		viewModel.input.viewDidLoad.onNext(())
	}

	// MARK: - Bind ViewModel
	private func bindViewModel() {
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
		
		viewModel.output.selectedCategoryIndex
			.drive(onNext: { [weak self] index in
				guard let self = self else { return }
				DispatchQueue.main.async {
					self.updateSelectedCategory(at: index)
				}
			})
			.disposed(by: disposeBag)
	}

	private func updateSelectedCategory(at index: Int) {
		eventsCollectionView.visibleCells.forEach { cell in
			guard let eventCell = cell as? EventsCollectionViewCell,
				  let cellIndex = eventsCollectionView.indexPath(for: cell) else { return }
			eventCell.updateSelection(isSelected: cellIndex.row == index)
		}
	}


}


extension SelectedEventsViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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

extension SelectedEventsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 100
	}
}


#Preview {
	SelectedEventsViewController(viewModel: SelectedEventsViewModel())
}
