//
//  SelectedEventsViewModel.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 8.02.2025.
//

import RxSwift
import RxCocoa
import Foundation

class SelectedEventsViewModel: ViewModelType {

	// MARK: - Input / Output Types
	struct Input {
		let selectRow: AnyObserver<IndexPath>
		let oddSelected: AnyObserver<(oddIndex: Int, event: OddsResponse)>
		let refresh: AnyObserver<Void>
		let viewDidLoad: AnyObserver<Void>
	}

	struct Output {
		let categories: Driver<[EventCategory]>
		let events: Driver<[OddsResponse]>
		let basketUpdates: Driver<Set<String>>
		let isLoading: Driver<Bool>
		let error: Driver<APIError?>
		let selectedCategoryIndex: Driver<Int>
	}

	// MARK: - Public Properties
	var input: Input
	var output: Output

	// MARK: - Private Properties
	private let disposeBag = DisposeBag()

	// Subjects for input actions.
	private let selectedRowSubject = PublishSubject<IndexPath>()
	private let oddSelectedSubject = PublishSubject<(oddIndex: Int, event: OddsResponse)>()
	private let refreshSubject = PublishSubject<Void>()
	private let viewDidLoadSubject = PublishSubject<Void>()

	// Relays to hold state.
	private let eventsRelay = BehaviorRelay<[OddsResponse]>(value: [])
	private let categoriesRelay = BehaviorRelay<[EventCategory]>(value: EventCategory.categories)
	private let loadingRelay = BehaviorRelay<Bool>(value: false)
	private let errorRelay = BehaviorRelay<APIError?>(value: nil)
	private let selectedCategoryIndexRelay = BehaviorRelay<Int>(value: 0)

	// MARK: - Initialization
	init() {
		// Setup inputs.
		self.input = Input(
			selectRow: selectedRowSubject.asObserver(),
			oddSelected: oddSelectedSubject.asObserver(),
			refresh: refreshSubject.asObserver(),
			viewDidLoad: viewDidLoadSubject.asObserver()
		)

		// Setup outputs.
		self.output = Output(
			categories: categoriesRelay.asDriver(),
			events: eventsRelay.asDriver(),
			basketUpdates: BasketViewModel.shared.output.events.map { events in
				Set(events.map { "\($0.id)-\($0.index)" })
			}.asDriver(onErrorJustReturn: []),
			isLoading: loadingRelay.asDriver(),
			error: errorRelay.asDriver(),
			selectedCategoryIndex: selectedCategoryIndexRelay.asDriver()
		)

		setupBindings()
	}

	// MARK: - Bindings Setup
	private func setupBindings() {
		// When the view loads, fetch the initial events.
		viewDidLoadSubject
			.subscribe(onNext: { [weak self] in
				self?.fetchInitialEvents()
			})
			.disposed(by: disposeBag)

		// When a category is selected, update the selected index and fetch events for that category.
		selectedRowSubject
			.do(onNext: { [weak self] indexPath in
				self?.selectedCategoryIndexRelay.accept(indexPath.row)
			})
			.withLatestFrom(categoriesRelay) { ($0, $1) }
			.subscribe(onNext: { [weak self] (indexPath, categories) in
				let category = categories[indexPath.row]
				self?.fetchEvents(for: category.key)
			})
			.disposed(by: disposeBag)

		// When an odd is selected, process it.
		oddSelectedSubject
			.subscribe(onNext: { [weak self] data in
				self?.handleOddSelection(index: data.oddIndex, event: data.event)
			})
			.disposed(by: disposeBag)

		// When a refresh occurs, fetch events for the currently selected category.
		refreshSubject
			.withLatestFrom(Observable.combineLatest(selectedCategoryIndexRelay, categoriesRelay))
			.subscribe(onNext: { [weak self] (index, categories) in
				let category = categories[index]
				self?.fetchEvents(for: category.key)
			})
			.disposed(by: disposeBag)
	}

	// Fetch data after initialized.
	private func fetchInitialEvents() {
		guard let firstCategory = EventCategory.categories.first else { return }
		fetchEvents(for: firstCategory.key)
	}

	private func fetchEvents(for sportKey: String) {
		loadingRelay.accept(true)
		APIClient.request(route: APIRouter.getOdds(type: sportKey, params: OddsRequest(markets: "h2h", regions: "eu")))
			.subscribe(onSuccess: { [weak self] (oddsResponse: [OddsResponse]) in
				guard let self = self else { return }
				self.loadingRelay.accept(false)
				let filteredOdds = oddsResponse.filter { !($0.bookmakers?.isEmpty ?? true) }
				self.eventsRelay.accept(filteredOdds)
			}, onFailure: { [weak self] error in
				guard let self = self else { return }
				self.loadingRelay.accept(false)
				self.errorRelay.accept((error as? APIError))
				debugPrint("Error fetching odds:", error)
			})
			.disposed(by: disposeBag)
	}

	// Helper for add selected odd to basket
	private func handleOddSelection(index: Int, event: OddsResponse) {
		let basketModel = BasketModel(id: event.id ?? "", odd: event, index: index)
		BasketViewModel.shared.checkAndProcessEvent(event: basketModel)
	}
}
