import 'dart:developer';
import 'dart:html' as html;

import 'package:blockchain_week4_ex1/abi.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_web3/flutter_web3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const NeumorphicApp(
      themeMode: ThemeMode.light,
      title: 'LotteryApp',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void setupEth() async {
    // From RPC
    final web3provider = Web3Provider(ethereum!);

    // Use `Provider` for Read-only contract, i.e. Can't call state-changing method
    busd = Contract(
      contractAddress,
      Interface(abi),
      web3provider.getSigner(),
    );

    try {
      // Prompt user to connect to the provider, i.e. confirm the connection modal
      final accs =
          await ethereum!.requestAccount(); // Get all accounts in node disposal
      accs; // [foo,bar]
    } on EthereumUserRejected {
      log('User rejected the modal');
    }
  }

  late Contract busd;

  @override
  void initState() {
    setupEth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            NeumorphicText('LotteryApp',
                style: const NeumorphicStyle(color: Colors.black),
                textStyle: NeumorphicTextStyle(fontSize: 30)),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final response = await busd.send(
                  'enter',
                  [],
                  TransactionOverride(
                      value: BigInt.parse('10000000000000001' /*10^16 + 1*/)),
                );
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(
                            child: Neumorphic(
                                child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator.adaptive(),
                        ))));
                final receipt = await response.wait(1);
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content:
                        Text('Open transaction: ${receipt.transactionHash}'),
                    action: SnackBarAction(
                      label: 'Open',
                      onPressed: () {
                        html.window.open(
                            'https://goerli.etherscan.io/tx/${receipt.transactionHash}',
                            'new tab');
                      },
                    ),
                  ),
                );

                log(receipt.transactionHash);
              },
              child: const Text('Enter'),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () async {
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final response = await busd.send(
                  'pickWinner',
                  [],
                );
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Center(
                            child: Neumorphic(
                                child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator.adaptive(),
                        ))));
                final receipt = await response.wait(1);
                navigator.pop();
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content:
                        Text('Open transaction: ${receipt.transactionHash}'),
                    action: SnackBarAction(
                      label: 'Open',
                      onPressed: () {
                        html.window.open(
                            'https://goerli.etherscan.io/tx/${receipt.transactionHash}',
                            'new tab');
                      },
                    ),
                  ),
                );

                log(receipt.transactionHash);
              },
              child: const Text('pickWinner'),
            ),
            const SizedBox(height: 20),
            NeumorphicButton(
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                List<dynamic> res = await busd.call('getPlayers');
                scaffoldMessenger.hideCurrentMaterialBanner();
                scaffoldMessenger.showMaterialBanner(MaterialBanner(
                  content: Text(
                      'Players: ${res.map((e) => e.toString()).join('\n')}'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        scaffoldMessenger.hideCurrentMaterialBanner();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ));
              },
              child: const Text('getPlayers'),
            ),
          ],
        ),
      ),
    );
  }
}
