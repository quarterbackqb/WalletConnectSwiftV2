import Foundation

class NotifySubscriptionsBuilder {
    private let notifyConfigProvider: NotifyConfigProvider

    init(notifyConfigProvider: NotifyConfigProvider) {
        self.notifyConfigProvider = notifyConfigProvider
    }

    func buildSubscriptions(_ notifyServerSubscriptions: [NotifyServerSubscription]) async throws -> [NotifySubscription] {
        var result = [NotifySubscription]()

        for subscription in notifyServerSubscriptions {
            do {
                let config = try await notifyConfigProvider.resolveNotifyConfig(appDomain: subscription.appDomain)
                let topic = try SymmetricKey(hex: subscription.symKey).derivedTopic()
                let scope = try await buildScope(selectedScope: subscription.scope, availableScope: config.notificationTypes)

                result.append(NotifySubscription(
                    topic: topic,
                    account: subscription.account,
                    relay: RelayProtocolOptions(protocol: "irn", data: nil),
                    metadata: config.metadata,
                    scope: scope,
                    expiry: subscription.expiry,
                    symKey: subscription.symKey
                ))
            } catch {
                continue
            }
        }

        return result
    }

    private func buildScope(selectedScope: [String], availableScope: [NotifyConfig.NotificationType]) async throws -> [String: ScopeValue] {
        return availableScope.reduce(into: [:]) {
            $0[$1.name] = ScopeValue(description: $1.description, enabled: selectedScope.contains($1.name))
        }
    }
}
