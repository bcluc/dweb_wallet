import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

class WalletConnectCredential extends CustomTransactionSender {
  WalletConnectCredential({
    required this.signingEngine,
    required this.sessionTopic,
    required this.chainId,
    required this.credentialsAddress,
  });

  final ISignEngine signingEngine;
  final String sessionTopic;
  final String chainId;
  final EthereumAddress credentialsAddress;

  @override
  EthereumAddress get address => credentialsAddress;

  @override
  Future<String> sendTransaction(Transaction transaction) async {
    if (kDebugMode) {
      print(
          'CustomCredentialsSender: sendTransaction - transaction: ${transaction.toJson()}');
    }

    if (!signingEngine.getActiveSessions().keys.contains(sessionTopic)) {
      if (kDebugMode) {
        print(
            'sendTransaction - called with invalid sessionTopic: $sessionTopic');
      }
      return 'Internal Error - sendTransaction - called with invalid sessionTopic';
    }

    SessionRequestParams sessionRequestParams = SessionRequestParams(
      method: 'eth_sendTransaction',
      params: [
        {
          'from': transaction.from?.hex ?? credentialsAddress.hex,
          'to': transaction.to?.hex,
          'data':
              (transaction.data != null) ? bytesToHex(transaction.data!) : null,
          if (transaction.value != null)
            'value':
                '0x${transaction.value?.getInWei.toRadixString(16) ?? '0'}',
          if (transaction.maxGas != null)
            'gas': '0x${transaction.maxGas?.toRadixString(16)}',
          if (transaction.gasPrice != null)
            'gasPrice': '0x${transaction.gasPrice?.getInWei.toRadixString(16)}',
          if (transaction.nonce != null) 'nonce': transaction.nonce,
        }
      ],
    );

    if (kDebugMode) {
      print(
          'CustomCredentialsSender: sendTransaction - blockchain $chainId, sessionRequestParams: ${sessionRequestParams.toJson()}');
    }
    try {
      final hash = await signingEngine.request(
        topic: sessionTopic,
        chainId: chainId,
        request: sessionRequestParams,
      );

      return hash;
    } catch (e) {
      return 'failed';
    }
  }

  @override
  Future<EthereumAddress> extractAddress() {
    // TODO: implement extractAddress
    throw UnimplementedError();
  }

  @override
  Future<MsgSignature> signToSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToSignature
    throw UnimplementedError();
  }

  @override
  MsgSignature signToEcSignature(Uint8List payload,
      {int? chainId, bool isEIP1559 = false}) {
    // TODO: implement signToEcSignature
    throw UnimplementedError();
  }
}
