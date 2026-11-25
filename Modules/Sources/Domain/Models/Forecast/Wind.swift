import Foundation

public struct Wind: Equatable, Sendable {
    public let speed: Measurement<UnitSpeed>
    public let gusts: Measurement<UnitSpeed>
    public let direction: Measurement<UnitAngle>

    public init(
        speed: Measurement<UnitSpeed>,
        gusts: Measurement<UnitSpeed>,
        direction: Measurement<UnitAngle>
    ) {
        self.speed = speed
        self.gusts = gusts
        self.direction = direction
    }
}
