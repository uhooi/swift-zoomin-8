import Foundation

struct WithdrawError: Error { }

actor BankAccount {
    var balance = 0
    func deposit(_ amount: Int) -> Int {
        balance += amount
        Thread.sleep(forTimeInterval: 1.0)
        return balance
    }
    
    func getInterest(with rate: Double) -> Int {
        deposit(Int(Double(balance) * rate))
    }
    
    func withdraw(_ amount: Int) throws -> Int {
        precondition(amount > 0)
        guard balance - amount >= 0 else {
            throw WithdrawError()
        }
        balance -= amount
        Thread.sleep(forTimeInterval: 1.0)
        return balance
    }
    
    func transfer(_ amount: Int, to account: BankAccount) async throws {
        _ = try withdraw(amount)
        _ = await account.deposit(amount)
    }
}

func bankAccountMain() {
    let accountA = BankAccount()
    let accountB = BankAccount()
    Task.detached {
        print(Thread.current)
        print("Task1 A: \(await accountA.deposit(100))")
        print("Task1 A: \(await accountA.getInterest(with: 0.5))")
        print("Task1 A: \(try await accountA.withdraw(100))")
        try await accountA.transfer(50, to: accountB)
        print("Task1 A:\(await accountA.balance) B: \(await accountB.balance)")
    }
    Task {
        print(Thread.current)
        print("Task2 A: \(await accountA.deposit(100))")
        print("Task2 A: \(await accountA.getInterest(with: 0.5))")
        print("Task2 A: \(try await accountA.withdraw(100))")
        try await accountA.transfer(50, to: accountB)
        print("Task2 A:\(await accountA.balance) B: \(await accountB.balance)")
    }
}
