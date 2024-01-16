
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

class EthereumUtils {
  late Web3Client web3client;
  late http.Client httpClient;
  final contractAddress = "0xBA35548eA3A28561Df23D8970Db339a4511Be69b";

  void initial() {
    httpClient = http.Client();
    String infuraApi = "https://sepolia.infura.io/v3/f2e858918fc24b2cb0e606a2df1bcec1";
    web3client = Web3Client(infuraApi, httpClient);
  }

  Future getBalance() async {
    final contract = await getDeployedContract();
    final etherFunction = contract.function("getBalance");
    final result = await web3client.call(contract: contract, function: etherFunction, params: []);
    List<dynamic> res = result;
    print(res.toString());
    return res[0];
  }

  Future<String> sendBalance(int amount) async {
    try {
      var bigAmount = BigInt.from(amount);
      EthPrivateKey privateKeyCred = EthPrivateKey.fromHex(dotenv.env['METAMASK_PRIVATE_KEY']!);
      DeployedContract contract = await getDeployedContract();
      final etherFunction = contract.function("sendBalance");
      final result = await web3client.sendTransaction(
          privateKeyCred,
          Transaction.callContract(
            contract: contract,
            function: etherFunction,
            parameters: [bigAmount],
            maxGas: 100000,
          ),
          chainId: 11155111,
          fetchChainIdFromNetworkId: false);
      return result;
    } catch (e) {
      print("Error: $e");
      return e.toString();
    }
  }

  Future<String> withDrawBalance(int amount) async {
    try {
      var bigAmount = BigInt.from(amount);
      EthPrivateKey privateKeyCred = EthPrivateKey.fromHex(dotenv.env['METAMASK_PRIVATE_KEY']!);
      DeployedContract contract = await getDeployedContract();
      final etherFunction = contract.function("withdrawBalance");
      final result = await web3client.sendTransaction(
        privateKeyCred,
        Transaction.callContract(
          contract: contract,
          function: etherFunction,
          parameters: [bigAmount],
          maxGas: 100000,
        ),
        chainId: 11155111,
        fetchChainIdFromNetworkId: false,
      );
      return result;
    } catch (e) {
      print("Error: $e");
      return e.toString();
    }

  }



  Future<DeployedContract> getDeployedContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "BasicDapp"), EthereumAddress.fromHex(contractAddress!));
    return contract;
  }
}