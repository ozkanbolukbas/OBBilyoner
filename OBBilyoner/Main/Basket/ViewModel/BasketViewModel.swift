//
//  BasketViewModel.swift
//  OBBilyoner
//
//  Created by Özkan Bölükbaş on 9.02.2025.
//

import RxSwift
import RxCocoa

class BasketViewModel: ViewModelType {

	// MARK: - Input / Output Types
	struct Input {
		let quickBetAmount: AnyObserver<Double>
		let numberInput: AnyObserver<String>
		let placeBet: AnyObserver<Void>
		let removeEvent: AnyObserver<Int>
	}

	struct Output {
		let events: Driver<[BasketModel]>
		let totalAmount: Driver<String>
		let betAmount: Driver<String>
		let totalOdds: Driver<String>
		let maxWin: Driver<String>
	}

	// MARK: - Public Properties
	var input: Input
	var output: Output

	// MARK: - Private Properties
	private let disposeBag = DisposeBag()

	// Subjects for input actions.
	private let quickBetAmountSubject = PublishSubject<Double>()
	private let numberInputSubject = PublishSubject<String>()
	private let placeBetSubject = PublishSubject<Void>()
	private let removeEventSubject = PublishSubject<Int>()

	// Relays to hold state.
	private let basketEvents = BehaviorRelay<[BasketModel]>(value: [])
	private let totalAmountRelay = BehaviorRelay<String>(value: "0.00")
	private let betAmountRelay = BehaviorRelay<Double>(value: 0)
	private let totalOddsRelay = BehaviorRelay<String>(value: "0.00")
	private let maxWinRelay = BehaviorRelay<String>(value: "0.00")

	// MARK: - Singleton
	static let shared = BasketViewModel()

	// MARK: - Initialization
	private init() {
		// Setup Input.
		self.input = Input(
			quickBetAmount: quickBetAmountSubject.asObserver(),
			numberInput: numberInputSubject.asObserver(),
			placeBet: placeBetSubject.asObserver(),
			removeEvent: removeEventSubject.asObserver()
		)

		// Setup Output.
		self.output = Output(
			events: basketEvents.asDriver(),
			totalAmount: totalAmountRelay.asDriver(),
			betAmount: betAmountRelay.map { String(format: "%.2f", $0) }
				.asDriver(onErrorJustReturn: "0.00"),
			totalOdds: totalOddsRelay.asDriver(),
			maxWin: maxWinRelay.asDriver()
		)

		setupBindings()
	}

	// MARK: - Bindings Setup
	private func setupBindings() {
		// Update bet amount from quick bet values.
		quickBetAmountSubject
			.bind(to: betAmountRelay)
			.disposed(by: disposeBag)

		// Update bet amount from number input.
		numberInputSubject
			.map { Double($0) ?? 0.0 }
			.bind(to: betAmountRelay)
			.disposed(by: disposeBag)

		// When a remove event action is received, remove the event at that index.
		removeEventSubject
			.subscribe(onNext: { [weak self] index in
				self?.removeEvent(at: index)
			})
			.disposed(by: disposeBag)

		// Calculate total odds by multiplying together the odds for each basket event.
		basketEvents
			.map { events -> String in
				let total = events.compactMap { event -> Double? in
					guard let firstBookmaker = event.odd.bookmakers?.first,
						  let firstMarket = firstBookmaker.markets?.first,
						  let outcomes = firstMarket.outcomes else {
						return nil
					}
					// Determine the price based on the selected index:
					let price: Double? = {
						switch event.index {
						case 0:
							return outcomes.first(where: { $0.name == event.odd.homeTeam })?.price
						case 1:
							return outcomes.first(where: { $0.name == event.odd.awayTeam })?.price
						case 2:
							return outcomes.first(where: { $0.name == "Draw" })?.price
						default:
							return nil
						}
					}()
					return price
				}.reduce(1, *)
				return String(format: "%.2f", total)
			}
			.bind(to: totalOddsRelay)
			.disposed(by: disposeBag)

		// Calculate maximum win as bet amount multiplied by total odds.
		Observable.combineLatest(betAmountRelay, totalOddsRelay.map { Double($0) ?? 0 })
			.map { bet, odds in
				String(format: "%.2f", bet * odds)
			}
			.bind(to: maxWinRelay)
			.disposed(by: disposeBag)

		// For this example, total amount is simply the bet amount.
		betAmountRelay
			.map { String(format: "%.2f", $0) }
			.bind(to: totalAmountRelay)
			.disposed(by: disposeBag)
	}

	// MARK: - Basket Operations
	/// Processes a tapped basket event. If the event is already present with the same selection,
	/// it is removed; if it is present with a different selection, it is updated; otherwise, it is added.
	func checkAndProcessEvent(event: BasketModel) {
		if basketEvents.value.contains(where: { $0.id == event.id && $0.index == event.index }) {
			removeEvent(event)
		} else if basketEvents.value.contains(where: { $0.id == event.id }) {
			updateEvent(event)
		} else {
			addEvent(event)
		}
	}

	private func addEvent(_ event: BasketModel) {
		var currentEvents = basketEvents.value
		currentEvents.append(event)
		basketEvents.accept(currentEvents)
	}

	private func removeEvent(at index: Int) {
		var currentEvents = basketEvents.value
		guard currentEvents.indices.contains(index) else { return }
		currentEvents.remove(at: index)
		basketEvents.accept(currentEvents)
	}

	private func updateEvent(_ event: BasketModel) {
		var currentEvents = basketEvents.value
		currentEvents.removeAll { $0.id == event.id }
		currentEvents.append(event)
		basketEvents.accept(currentEvents)
	}

	private func removeEvent(_ event: BasketModel) {
		var currentEvents = basketEvents.value
		currentEvents.removeAll { $0.id == event.id }
		basketEvents.accept(currentEvents)
	}
}
