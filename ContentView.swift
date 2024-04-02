import SwiftUI
import Combine

struct TaskCancelBagPractice: View {
    
    fileprivate let viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Button("Start Count Three") {
                viewModel.countThree()
            }
            Button("Cancel Count Task") {
                viewModel.cancelTask()
            }
        }
    }
}

fileprivate class ViewModel {
    
    private let cancelBag = TaskCancelBag<TaskID>()
    
    enum TaskID {
        case countThree
    }
    
    func countThree() {
        Task {
            print("Count 1")
            try await Task.sleep(for: .seconds(1))
            print("Count 2")
            try await Task.sleep(for: .seconds(1))
            print("Count 3")
            try await Task.sleep(for: .seconds(1))
            print("Task Complete")
        }.store(in: cancelBag, id: .countThree)
    }
    
    func cancelTask() {
        cancelBag.cancel(id: .countThree)
    }
}

fileprivate class TaskCancelBag<ID: Hashable> {
    
    private var bag: [ID: AnyCancellable] = [:]
    
    public func cancel(id: ID) {
        bag[id]?.cancel()
        bag.removeValue(forKey: id)
    }
    
    public func cancelAll() {
        bag.values.forEach { $0.cancel() }
        bag.removeAll()
    }
    
    public func add(id: ID, cancellable: AnyCancellable) {
        bag[id]?.cancel()
        bag[id] = cancellable
    }
}

fileprivate extension Task {
    
    func store<ID: Hashable>(in bag: TaskCancelBag<ID>, id: ID) {
        bag.add(id: id, cancellable: AnyCancellable(cancel))
    }
}
