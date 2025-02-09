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

	override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationController?.isNavigationBarHidden = true
		eventsCollectionView.register(cellType: EventsCollectionViewCell.self)
		oddsTableView.register(cellType: OddsTableViewCell.self)
		bindViewModel()
    }

	func bindViewModel() {
		eventsCollectionView.rx.setDelegate(self)
			.disposed(by: disposeBag)

		oddsTableView.rx.setDelegate(self)
			.disposed(by: disposeBag)

		eventsCollectionView.rx.itemSelected
			.bind(to: viewModel.input.selectRow)
			.disposed(by: disposeBag)

		viewModel.output.sports
			.drive(eventsCollectionView.rx.items(cellIdentifier: EventsCollectionViewCell.reuseId, cellType: EventsCollectionViewCell.self)) { (_, event, cell) in
				cell.configure(with: event)
			}
			.disposed(by: disposeBag)

		viewModel.output.events.drive(oddsTableView.rx.items(cellIdentifier: OddsTableViewCell.reuseId, cellType: OddsTableViewCell.self)) { (_, item, cell) in
			cell.configure(with: item)
			cell.delegate = self
			cell.selectionStyle = .none
		}
		.disposed(by: disposeBag)
	}


}

extension HomeViewController: OddsTableViewCellDelegate {
	func didSelectOddsItem(at index: Int, for cell: OddsTableViewCell) {
		guard let cellIndex = oddsTableView.indexPath(for: cell) else { return }
		print(index)
		print(cellIndex)
	}
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: 80, height: 80)
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
