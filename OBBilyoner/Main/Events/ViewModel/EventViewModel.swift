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
			let searchText: AnyObserver<String>
		}

		struct Output {
			let events: Driver<[EventResponse]>
			let filteredEvents: Driver<[EventResponse]>
			let selectedEventKey: Driver<String>
			let isLoading: Driver<Bool>
			let error: Driver<APIError?>
		}

		// MARK: - Public Properties
		var input: Input
		var output: Output

		// MARK: - Private Properties
		private let disposeBag = DisposeBag()

		// Subjects for input actions.
		private let viewDidLoadSubject = PublishSubject<Void>()
		private let selectRowSubject = PublishSubject<IndexPath>()
		private let searchTextSubject = BehaviorSubject<String>(value: "")



		// Relays to hold state.
		private let eventsRelay = BehaviorRelay<[EventResponse]>(value: [])
		private let loadingRelay = BehaviorRelay<Bool>(value: false)
		private let errorRelay = BehaviorRelay<APIError?>(value: nil)
		private let selectedEventKeyRelay = PublishRelay<String>()
		private let filteredEventsRelay = BehaviorRelay<[EventResponse]>(value: [])

		// MARK: - Initialization
		init() {
			// Setup inputs.
			self.input = Input(
				viewDidLoad: viewDidLoadSubject.asObserver(),
				selectRow: selectRowSubject.asObserver(),
				searchText: searchTextSubject.asObserver()
			)

			// Setup outputs.
			self.output = Output(
				events: eventsRelay.asDriver(),
				filteredEvents: filteredEventsRelay.asDriver(),
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

			// When user type texts, get the filtered events.
			Observable.combineLatest(
					   eventsRelay.asObservable(),
					   searchTextSubject.asObservable()
				   )
				   .map { events, searchText -> [EventResponse] in
					   guard !searchText.isEmpty else { return events }
					   return events.filter { event in
						   let title = event.title?.lowercased() ?? ""
						   let description = event.description?.lowercased() ?? ""
						   let searchLowercased = searchText.lowercased()

						   return title.contains(searchLowercased) ||
								  description.contains(searchLowercased)
					   }
				   }
				   .bind(to: filteredEventsRelay)
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
