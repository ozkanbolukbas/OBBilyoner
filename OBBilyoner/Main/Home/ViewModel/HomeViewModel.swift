//
//  HomeViewModel.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import RxSwift
import RxCocoa
import Foundation

class HomeViewModel: ViewModelType {
	var output: Output!
	var input: Input!

	private let disposeBag = DisposeBag()

	struct Input {
		let refresh: PublishRelay<Void>
		//let searchText: Driver<String>
		let selectRow: PublishRelay<IndexPath>
	}

	struct Output {
		let sports: Driver<[EventCategory]>
		let events: Driver<[OddsResponse]>
		//let error: Observable<Error>
	}

	private let _error = PublishSubject<Error>()
	private let sports = BehaviorRelay<[EventCategory]>(value: EventCategory.categories)
	private var selectedSport = BehaviorRelay<EventCategory>(value: EventCategory.categories.first!)
	private var oddList = BehaviorRelay<[OddsResponse]>(value: [])

	init() {
		fetchEvents()
		let reload = PublishRelay<Void>()
		_ = reload.subscribe(onNext: { [weak self] _ in
			guard let self = self else { return }
			self.fetchEvents()
		})
		let selectedRow = PublishRelay<IndexPath>()
		_ = selectedRow .subscribe(onNext: { [weak self] indexPath in
			guard let self = self else { return }
			selectedSport.accept(sports.value[indexPath.row])
			fetchEvents()
		})

		self.input = Input(refresh: reload, selectRow: selectedRow)

		let events = oddList.asDriver(onErrorJustReturn: [])
		let sportList = sports.asDriver()
		output = Output(sports: sportList, events: events)

	}

	func fetchEvents() {
		APIClient.request(route: APIRouter.getOdds(type: selectedSport.value.key, params: OddsRequest(markets: "h2h", regions: "eu")))
			.subscribe(
				onSuccess: { (oddsResponse: [OddsResponse])  in
					let filteredOdds = oddsResponse.filter { !($0.bookmakers?.isEmpty ?? true) }
					self.oddList.accept(filteredOdds)
				},
				onFailure: { error in
					// Handle failure
					print("Failed with error:", error)
				}
			)
			.disposed(by: disposeBag)
	}

}
