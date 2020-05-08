//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: gateways_waves_api.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation
import GRPC
import NIO
import NIOHTTP1
import SwiftProtobuf


/// Usage: instantiate Gateways_WavesApiClient, then call methods of this protocol to make API calls.
public protocol Gateways_WavesApiClientProtocol {
  func getWavesAssetBindings(_ request: Gateways_GetWavesAssetBindingsRequest, callOptions: CallOptions?) -> UnaryCall<Gateways_GetWavesAssetBindingsRequest, Gateways_AssetBindingsResponse>
  func getDepositTransferBinding(_ request: Gateways_GetDepositTransferBindingRequest, callOptions: CallOptions?) -> UnaryCall<Gateways_GetDepositTransferBindingRequest, Gateways_GetTransferBindingResponse>
  func getWithdrawalTransferBinding(_ request: Gateways_GetWithdrawalTransferBindingRequest, callOptions: CallOptions?) -> UnaryCall<Gateways_GetWithdrawalTransferBindingRequest, Gateways_GetTransferBindingResponse>
  func createDepositTransferBinding(_ request: Gateways_CreateDepositTransferBindingRequest, callOptions: CallOptions?) -> UnaryCall<Gateways_CreateDepositTransferBindingRequest, Gateways_CreateTransferBindingResponse>
  func createWithdrawalTransferBinding(_ request: Gateways_CreateWithdrawalTransferBindingRequest, callOptions: CallOptions?) -> UnaryCall<Gateways_CreateWithdrawalTransferBindingRequest, Gateways_CreateTransferBindingResponse>
}

public final class Gateways_WavesApiClient: GRPCClient, Gateways_WavesApiClientProtocol {
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions

  /// Creates a client for the gateways.WavesApi service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(channel: GRPCChannel, defaultCallOptions: CallOptions = CallOptions()) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
  }

  /// --- Asset Bindings:
  ///
  /// - Parameters:
  ///   - request: Request to send to GetWavesAssetBindings.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getWavesAssetBindings(_ request: Gateways_GetWavesAssetBindingsRequest, callOptions: CallOptions? = nil) -> UnaryCall<Gateways_GetWavesAssetBindingsRequest, Gateways_AssetBindingsResponse> {
    return self.makeUnaryCall(path: "/gateways.WavesApi/GetWavesAssetBindings",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// --- Transfer Bindings:
  ///
  /// - Parameters:
  ///   - request: Request to send to GetDepositTransferBinding.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getDepositTransferBinding(_ request: Gateways_GetDepositTransferBindingRequest, callOptions: CallOptions? = nil) -> UnaryCall<Gateways_GetDepositTransferBindingRequest, Gateways_GetTransferBindingResponse> {
    return self.makeUnaryCall(path: "/gateways.WavesApi/GetDepositTransferBinding",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Unary call to GetWithdrawalTransferBinding
  ///
  /// - Parameters:
  ///   - request: Request to send to GetWithdrawalTransferBinding.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getWithdrawalTransferBinding(_ request: Gateways_GetWithdrawalTransferBindingRequest, callOptions: CallOptions? = nil) -> UnaryCall<Gateways_GetWithdrawalTransferBindingRequest, Gateways_GetTransferBindingResponse> {
    return self.makeUnaryCall(path: "/gateways.WavesApi/GetWithdrawalTransferBinding",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Unary call to CreateDepositTransferBinding
  ///
  /// - Parameters:
  ///   - request: Request to send to CreateDepositTransferBinding.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func createDepositTransferBinding(_ request: Gateways_CreateDepositTransferBindingRequest, callOptions: CallOptions? = nil) -> UnaryCall<Gateways_CreateDepositTransferBindingRequest, Gateways_CreateTransferBindingResponse> {
    return self.makeUnaryCall(path: "/gateways.WavesApi/CreateDepositTransferBinding",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

  /// Unary call to CreateWithdrawalTransferBinding
  ///
  /// - Parameters:
  ///   - request: Request to send to CreateWithdrawalTransferBinding.
  ///   - callOptions: Call options; `self.defaultCallOptions` is used if `nil`.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func createWithdrawalTransferBinding(_ request: Gateways_CreateWithdrawalTransferBindingRequest, callOptions: CallOptions? = nil) -> UnaryCall<Gateways_CreateWithdrawalTransferBindingRequest, Gateways_CreateTransferBindingResponse> {
    return self.makeUnaryCall(path: "/gateways.WavesApi/CreateWithdrawalTransferBinding",
                              request: request,
                              callOptions: callOptions ?? self.defaultCallOptions)
  }

}


// Provides conformance to `GRPCPayload` for request and response messages
extension Gateways_GetWavesAssetBindingsRequest: GRPCProtobufPayload {}
extension Gateways_AssetBindingsResponse: GRPCProtobufPayload {}
extension Gateways_GetDepositTransferBindingRequest: GRPCProtobufPayload {}
extension Gateways_GetTransferBindingResponse: GRPCProtobufPayload {}
extension Gateways_GetWithdrawalTransferBindingRequest: GRPCProtobufPayload {}
extension Gateways_CreateDepositTransferBindingRequest: GRPCProtobufPayload {}
extension Gateways_CreateTransferBindingResponse: GRPCProtobufPayload {}
extension Gateways_CreateWithdrawalTransferBindingRequest: GRPCProtobufPayload {}

