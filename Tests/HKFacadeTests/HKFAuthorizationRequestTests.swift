import Testing
@testable import HKFacade

@Suite("HKFAuthorizationRequest")
struct HKFAuthorizationRequestTests {

    @Test("read-only request has empty write set")
    func readOnly() {
        let request = HKFAuthorizationRequest(read: [.steps, .distance], write: [])
        #expect(request.read == [.steps, .distance])
        #expect(request.write.isEmpty)
    }

    @Test("write-only request has empty read set")
    func writeOnly() {
        let request = HKFAuthorizationRequest(read: [], write: [.steps])
        #expect(request.read.isEmpty)
        #expect(request.write == [.steps])
    }

    @Test("from(read:write:) flattens domains")
    func fromDomains() {
        let request = HKFAuthorizationRequest.from(read: [.pedometer], write: [.pedometer])
        #expect(request.read.contains(.steps))
        #expect(request.read.contains(.distance))
        #expect(request.write.contains(.steps))
        #expect(request.write.contains(.distance))
    }

    @Test("HKFDomain.pedometer contains only steps and distance")
    func pedometerDomain() {
        #expect(HKFDomain.pedometer.associatedTypes == [.steps, .distance])
    }
}
