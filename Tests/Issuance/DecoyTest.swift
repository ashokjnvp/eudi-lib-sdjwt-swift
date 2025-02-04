/*
 * Copyright (c) 2023 European Commission
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import XCTest

@testable import eudi_lib_sdjwt_swift

final class DecoyTest: XCTestCase {

  func testDisclosedObjects_AdingDecoys_ThenExpectedDigestsMatchesTheProducedDigestsAndDecoys() {
    let decoysLimit = 10

    @SDJWTBuilder
    var sdObject: SdElement {
      PlainClaim("name", "Edmun")
      ArrayClaim("Nationalites", array: [.flat(value: "DE"), .flat(value: 123)])
      ObjectClaim("adress") {
        PlainClaim("locality", "gr")
        FlatDisclosedClaim("adress", "Al. Mich")
      }
    }

    @SDJWTBuilder
    var alrtSdObject: SdElement {
      PlainClaim("name", "Edmun")
      ArrayClaim("Nationalites", array: [.flat(value: "DE"), .flat(value: 123)])
      ObjectClaim("adress") {
        PlainClaim("locality", "gr")
        FlatDisclosedClaim("adress", "Al. Mich")
        ObjectClaim("embedded_adress") {
          PlainClaim("embedded_locality", "gr")
          FlatDisclosedClaim("embedded_adress", "Al. Mich")
        }
      }
    }

    let jwtFactory = SDJWTFactory(decoysLimit: decoysLimit)
    let unsignedJwt = jwtFactory.createSDJWTPayload(sdJwtObject: sdObject.asObject)

    validateObjectResults(factoryResult: unsignedJwt, expectedDigests: sdObject.expectedDigests, numberOfDecoys: jwtFactory.decoyCounter, decoysLimit: decoysLimit)
  }

  func testA() {
    @SDJWTBuilder
    var sdObject: SdElement {
      PlainClaim("name", "Edmun")
      ArrayClaim("Nationalites", array: [.flat(value: "DE"), .flat(value: 123)])
      RecursiveObject("recursice_adress") {
        FlatDisclosedClaim("recursice_adress", "Al. Mich")
      }
      ObjectClaim("adress") {
        PlainClaim("locality", "gr")
        FlatDisclosedClaim("adress", "Al. Mich")
      }
    }

    let asJSON = sdObject.asObject

    let jwtFactory = SDJWTFactory()
    let payload = try! jwtFactory.createSDJWTPayload(sdJwtObject: sdObject.asObject).get()

    let digestsCount = payload.value.findDigestCount()
  }
}
