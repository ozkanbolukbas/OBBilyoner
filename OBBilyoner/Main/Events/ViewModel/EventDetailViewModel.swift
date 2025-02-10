//
//  EventDetailViewModel.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//
import RxSwift
import RxCocoa
import Foundation

class EventDetailViewModel: ViewModelType {

	// MARK: - Input / Output Types
	struct Input {
		let oddSelected: AnyObserver<(oddIndex: Int, event: OddsResponse)>
		let refresh: AnyObserver<Void>
		let viewDidLoad: AnyObserver<Void>
	}

	struct Output {
		let odds: Driver<[OddsResponse]>
		let basketUpdates: Driver<Set<String>>
		let isLoading: Driver<Bool>
		let error: Driver<APIError?>
		let hideEmptyState: Driver<Bool>
	}

	// MARK: - Public Properties
	var input: Input
	var output: Output

	// MARK: - Private Properties
	private let disposeBag = DisposeBag()

	// Subjects for input actions.
	private let oddSelectedSubject = PublishSubject<(oddIndex: Int, event: OddsResponse)>()
	private let refreshSubject = PublishSubject<Void>()
	private let viewDidLoadSubject = PublishSubject<Void>()

	// Relays to hold state.
	private let oddsRelay = BehaviorRelay<[OddsResponse]>(value: [])
	private let loadingRelay = BehaviorRelay<Bool>(value: false)
	private let errorRelay = BehaviorRelay<APIError?>(value: nil)
	private let hideEmptyStateRelay = BehaviorRelay<Bool>(value: true)

	// Event Key.
	private let eventKey: String

	// MARK: - Initialization
	init(eventKey: String) {
		self.eventKey = eventKey
		// Setup inputs.
		self.input = Input(
			oddSelected: oddSelectedSubject.asObserver(),
			refresh: refreshSubject.asObserver(),
			viewDidLoad: viewDidLoadSubject.asObserver()
		)

		// Setup outputs.
		self.output = Output(
			odds: oddsRelay.asDriver(),
			basketUpdates: BasketViewModel.shared.output.events.map { events in
				Set(events.map { "\($0.id)-\($0.index)" })
			}.asDriver(onErrorJustReturn: []),
			isLoading: loadingRelay.asDriver(),
			error: errorRelay.asDriver(),
			hideEmptyState: hideEmptyStateRelay.asDriver()
		)

		setupBindings()
	}

	// MARK: - Bindings Setup
	private func setupBindings() {
		// When the view loads, fetch the initial events.
		viewDidLoadSubject
			.subscribe(onNext: { [weak self] in
				guard let self = self else { return }
				self.fetchEvents(for: eventKey)
			})
			.disposed(by: disposeBag)

		// When an odd is selected, process it.
		oddSelectedSubject
			.subscribe(onNext: { [weak self] data in
				self?.handleOddSelection(index: data.oddIndex, event: data.event)
			})
			.disposed(by: disposeBag)
	}

	private func fetchEvents(for sportKey: String) {
		loadingRelay.accept(true)
		APIClient.request(route: APIRouter.getOdds(type: sportKey, params: OddsRequest(markets: "h2h", regions: "eu,us,us2,uk,au")))
			.subscribe(onSuccess: { [weak self] (oddsResponse: [OddsResponse]) in
				guard let self = self else { return }
				self.loadingRelay.accept(false)
				let filteredOdds = oddsResponse.filter { !($0.bookmakers?.isEmpty ?? true) }
				self.oddsRelay.accept(filteredOdds)
				if filteredOdds.isEmpty {
					self.hideEmptyStateRelay.accept(false)
				}
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
