import 'package:dweb_wallet/metamask.dart';
import 'package:dweb_wallet/wallet_connect_credential.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

const _contractAddress = '0x39f13B61cEF5939A30D1ac89E1bF441a62371E7C';
const _sepRpcUrl =
    'https://sepolia.infura.io/v3/2682fb5ba7214f63ad1b4b90c9169b38';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String walletAbi = 'assets/abi/abi_wallet.json';
  late ContractEvent contractEvent;
  late String walletAddress;
  late Web3Client ethClient;
  late Client httpClient;
  late DeployedContract _contract;

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString(walletAbi);
    final contract = DeployedContract(ContractAbi.fromJson(abi, "PKWallet"),
        EthereumAddress.fromHex(_contractAddress));
    // PROCESS TO LISTENING TRANSFER EVENT
    setState(() {
      _contract = contract;
    });
    contractEvent = contract.event("transfer");
    return contract;
  }

  @override
  void initState() {
    super.initState();
    httpClient = Client();

    ethClient = Web3Client(_sepRpcUrl, httpClient);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      //Change the provider
      create: (context) => MetaMaskProvider()..init(), //create an instant
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF181818),
          body: Stack(
            children: [
              Center(
                child: Consumer<MetaMaskProvider>(
                  builder: (context, provider, child) {
                    late String text; //check the state and display it

                    if (provider.isConnected) {
                      text = provider.currentAddress; //connected
                      setState(() {
                        walletAddress = provider.currentAddress;
                      });
                    }
                    // else if (provider.isConnected &&
                    //     !provider.isInOperatingChain) {
                    //   text =
                    //       'Wrong chain. Please connect to ${MetaMaskProvider.operatingChain}'; //wrong chain, what chain it should be connected to
                    // }
                    else if (provider.isEnabled) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Click the button...'),
                          const SizedBox(height: 8),
                          CupertinoButton(
                            onPressed: () => context
                                .read<MetaMaskProvider>()
                                .connect(), //call metamask on click
                            color: Colors.white,
                            padding: const EdgeInsets.all(0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.network(
                                  'https://i0.wp.com/kindalame.com/wp-content/uploads/2021/05/metamask-fox-wordmark-horizontal.png?fit=1549%2C480&ssl=1',
                                  width: 300,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    } else {
                      text =
                          'Please use a Web3 supported browser.'; //please use web3 supported browser
                    }

                    return Column(
                      children: [
                        ShaderMask(
                          // a little bit of styling for text
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Colors.purple, Colors.blue, Colors.red],
                          ).createShader(bounds),
                          child: Text(
                            text,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextButton(
                            onPressed: () {}, child: const Text('Transfer'))
                      ],
                    );
                  },
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.network(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTicLAkhCzpJeu9OV-4GOO-BOon5aPGsj_wy9ETkR4g-BdAc8U2-TooYoiMcPcmcT48H7Y&usqp=CAU',
                    fit: BoxFit.cover,
                    opacity: const AlwaysStoppedAnimation(0.025),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // void transferEth() async {
  //   final contract = await loadContract();

  //   Credentials credentials = WalletConnectCredential(
  //       signingEngine: _w3mService.web3App!.signEngine,
  //       sessionTopic: _w3mService.session!.topic!,
  //       chainId: _w3mService.selectedChain!.namespace,
  //       credentialsAddress:
  //           EthereumAddress.fromHex(_w3mService.session!.address!));
  //   if (walletAddress != '') {
  //     final etherAmount = await convertUsdToEth(amount);
  //     final ethFunction = contract.function("sendViaTransfer");
  //     final transaction = Transaction.callContract(
  //       contract: contract,
  //       function: ethFunction,
  //       parameters: [EthereumAddress.fromHex(_endPointWallet)],
  //       value: etherAmount,
  //     );
  //     // print('Check credentials ${credentials}');
  //     // print('Check transaction ${transaction.toJson()}');
  //     _w3mService.launchConnectedWallet();
  //     setState(() {
  //       isLoading = true;
  //       transactionConfirmed = false;
  //     });
  //     final response = await ethClient.sendTransaction(
  //       credentials,
  //       transaction,
  //       chainId: int.tryParse(_w3mService.session!.chainId),
  //     );

  //     //print('Sent successfull');
  //     //print(response);
  //     // TESTING
  //     // _w3mService.addListener(() {
  //     //   response;
  //     // });
  //     // _w3mService.notifyListeners();
  //     // TESTING
  //     if (!response.isEmpty) {
  //       await _waitForConfirmation(response);
  //     }
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text(
  //           'Please connect your wallet',
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     );
  //   }
  //   return;
  // }
}
