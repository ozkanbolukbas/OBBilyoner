//
//  EventViewModel.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 10.02.2025.
//

import RxSwift
import RxCocoa
import Foundation

class EventsViewModel: ViewModelType {

	// MARK: - Input / Output Types
		struct Input {
			let viewDidLoad: AnyObserver<Void>
			let selectRow: AnyObserver<IndexPath>
		}

		struct Output {
			let events: Driver<[EventResponse]>
			let selectedEventKey: Driver<String>
			let isLoading: Driver<Bool>
			let error: Driver<APIError?>  // Adjust type if you use a different error type
		}

		// MARK: - Public Properties
		var input: Input
		var output: Output

		// MARK: - Private Properties
		private let disposeBag = DisposeBag()

		// Subjects for input actions.
		private let viewDidLoadSubject = PublishSubject<Void>()
		private let selectRowSubject = PublishSubject<IndexPath>()

		// Relays to hold state.
		private let eventsRelay = BehaviorRelay<[EventResponse]>(value: [])
		private let loadingRelay = BehaviorRelay<Bool>(value: false)
		private let errorRelay = BehaviorRelay<APIError?>(value: nil)
		private let selectedEventKeyRelay = PublishRelay<String>()

		// MARK: - Initialization
		init() {
			// Setup inputs.
			self.input = Input(
				viewDidLoad: viewDidLoadSubject.asObserver(),
				selectRow: selectRowSubject.asObserver()
			)

			// Setup outputs.
			self.output = Output(
				events: eventsRelay.asDriver(),
				selectedEventKey: selectedEventKeyRelay.asDriver(onErrorJustReturn: ""),
				isLoading: loadingRelay.asDriver(),
				error: errorRelay.asDriver()
			)

			setupBindings()
		}

		// MARK: - Bindings Setup
		private func setupBindings() {
			// When the view loads, fetch the events.
			viewDidLoadSubject
				.subscribe(onNext: { [weak self] in
					self?.fetchEvents()
				})
				.disposed(by: disposeBag)

			// When a row is selected, get the event at that index.
			selectRowSubject
				.withLatestFrom(eventsRelay) { (indexPath, events) -> EventResponse? in
					guard events.indices.contains(indexPath.row) else { return nil }
					return events[indexPath.row]
				}
				.compactMap { $0 }  // Ignore nil values.
				.map { $0.key ?? "" }
				.bind(to: selectedEventKeyRelay)
				.disposed(by: disposeBag)
		}


	// MARK: - Fetching Events
	private func fetchEvents() {
		loadingRelay.accept(true)
		APIClient.request(route: APIRouter.getEvents)
			.subscribe(onSuccess: { [weak self] (eventsResponse: [EventResponse]) in
				guard let self = self else { return }
				self.loadingRelay.accept(false)
				self.eventsRelay.accept(eventsResponse)
			}, onFailure: { [weak self] error in
				guard let self = self else { return }
				self.loadingRelay.accept(false)
				self.errorRelay.accept((error as? APIError))
				debugPrint("Error fetching odds:", error)
			})
			.disposed(by: disposeBag)
	}
}
