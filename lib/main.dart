import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutterchain/flutterchain_lib/constants/core/supported_blockchains.dart';
import 'package:flutterchain/flutterchain_lib/models/core/wallet.dart';
import 'package:flutterchain/flutterchain_lib/services/chains/near_blockchain_service.dart';
import 'package:flutterchain/flutterchain_lib/services/core/lib_initialization_service.dart';
import 'package:flutterchain/flutterchain_lib/services/crypto_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFlutterChainLib();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Wallet? currentWallet;

  final FlutterChainService flutterChainService =
      FlutterChainService.defaultInstance();

  String? nearApiJsPrivateKeyFormat;

  final TextEditingController importedSecretKeyTextEditingController =
      TextEditingController();

  String? importedPrivateKeyFromNearApiJs;
  String? importedPublicKeyFromNearApiJs;

  @override
  void initState() {
    super.initState();
    //Generate new wallet
    flutterChainService
        .generateNewWallet(walletName: "New Wallet ${DateTime.now()}")
        .then((value) {
      setState(() {
        currentWallet = value;
        log("New Wallet created with data ${currentWallet?.toJson().toString()}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              height: 50,
            ),
            SelectableText(
              "Your mnemonic ${currentWallet?.mnemonic ?? 'no generated Wallet detected '}",
            ),
            const SizedBox(
              height: 50,
            ),
            const Text("Create BlockchainData for the Near Blockchain"),
            IconButton(
              onPressed: () async {
                //This method create blockchain data for all Supported Blockchains
                //Standard approach
                final blockChainData = await flutterChainService
                    .createBlockchainsDataFromTheMnemonic(
                  mnemonic: currentWallet?.mnemonic ?? '',
                  passphrase: '',
                );
                currentWallet?.blockchainsData?.addAll(blockChainData);

                // //This variant for dev's who wanna create blockchainData just for specific blockchain
                // //1. get Blockchain Service
                // final nearService =
                //     flutterChainService.blockchainServices[BlockChains.near]!;
                // //2. get Blockchain data
                // final blockChainData =
                //     await nearService.getBlockChainDataFromMnemonic(
                //   currentWallet?.mnemonic ?? '',
                //   '',
                // );

                // //3. add it to the wallet
                // currentWallet?.blockchainsData?[BlockChains.near] = {};
                // currentWallet?.blockchainsData?[BlockChains.near]
                //     ?.add(blockChainData);

                setState(() {});
              },
              icon: const Icon(
                Icons.add_circle_sharp,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SelectableText(
              "Your Near blockchain data ${currentWallet?.blockchainsData?[BlockChains.near] ?? 'no blockchain Data detected '}",
            ),
            const SizedBox(
              height: 50,
            ),
            const Text("Export it to the near api js"),
            IconButton(
              onPressed: () async {
                final nearService =
                    flutterChainService.blockchainServices[BlockChains.near]!
                        as NearBlockChainService;
                final exportedKey =
                    await nearService.exportPrivateKeyToTheNearApiJsFormat(
                  currentBlockchainData:
                      currentWallet?.blockchainsData?[BlockChains.near]?.first,
                );
                setState(() {
                  nearApiJsPrivateKeyFormat = exportedKey;
                });
              },
              icon: const Icon(
                Icons.add_circle_sharp,
                size: 40,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SelectableText(
              'nearApiJsPrivateKeyFormat $nearApiJsPrivateKeyFormat',
            ),
            const SizedBox(
              height: 50,
            ),
            const SelectableText(
              'Import near api js type secret key',
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 50,
              child: TextField(
                controller: importedSecretKeyTextEditingController,
                onSubmitted: (secretKey) async {
                  final nearService =
                      flutterChainService.blockchainServices[BlockChains.near]!
                          as NearBlockChainService;

                  final secretKeyWithoutPrefix = secretKey.split(":").last;

                  final importedPrivateKey = await nearService
                      .getPrivateKeyFromSecretKeyFromNearApiJSFormat(
                    secretKeyWithoutPrefix,
                  );
                  final importedPublicKey = await nearService
                      .getPublicKeyFromSecretKeyFromNearApiJSFormat(
                    secretKeyWithoutPrefix,
                  );

                  setState(() {
                    importedPrivateKeyFromNearApiJs = importedPrivateKey;
                    importedPublicKeyFromNearApiJs = importedPublicKey;
                  });
                },
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SelectableText(
              'Imported Private key from secret key(near api js type) -> $importedPrivateKeyFromNearApiJs',
            ),
            SelectableText(
              'Imported  Public key  from secret key (near api js type) -> $importedPublicKeyFromNearApiJs',
            ),
          ],
        ),
      ),
    );
  }
}
