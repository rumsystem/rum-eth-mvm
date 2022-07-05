## mvm 流程

调用 mvm 的合约需要部署到 mixin mvm 的 eth poa 链上，地址：https://scan.mvm.dev/

- 正常部署 eth 合约到 mixin mvm 的 eth poa 链上 (需要 xin 作 gas 费）
- 通过 mvm registry 合约调用自己部署的合约 （不需要 gas 费）
  + 只有 write 才需要通过 mvm registry 调用
  + read 操作直接通过 web3 api 调用

### 通过 mvm registry 调用自己的合约

基本信息：

- 部署到链上的 registry、storage 合约地址、部署 registry 时的 PID等： https://bridge.mvm.dev/
- registry 合约源码：https://github.com/MixinNetwork/trusted-group/blob/master/mvm/quorum/registry/contracts/Registry.sol
- storage 合约源码：https://github.com/MixinNetwork/trusted-group/blob/master/mvm/quorum/registry/contracts/Storage.sol
- js 调用 mvm：https://github.com/MixinNetwork/bot-api-nodejs-client/tree/main/src/mvm  （可以先看这个，有疑问的地方再看看下面的 go 代码）

#### extra 没有超长

生成 extra，支持一次调用多个合约的多个方法。mixin js sdk 中有现成的方法，不需要自己封装，下面 go 写的仅作参考。

```
type (
	ExtraParam struct {
		ContractAbi     *abi.ABI
		ContractAddress string
		MethodName      string
		MethodArgs      []interface{}
	}
	ExtraParamList []ExtraParam
)

func ContractAddrForExtra(hexStr string) string {
	hexStr = strings.ToLower(hexStr)
	if strings.HasPrefix(hexStr, "0x") {
		return hexStr[2:]
	}

	return hexStr
}

func _generateExtra(contractABI *abi.ABI, contractAddress string, methodName string, params ...interface{}) (string, error) {
	// 需要执行合约的地址去掉 0x 后全部小写
	contractAddress = ContractAddrForExtra(contractAddress)
	sign, err := contractABI.Pack(methodName, params...)
	if err != nil {
		return "", err
	}

	lenSignStr := fmt.Sprintf("%04x", len(sign))
	extra := contractAddress + lenSignStr + hex.EncodeToString(sign)
	return extra, nil
}

func GenerateExtra(params ExtraParamList) ([]byte, error) {
	if params == nil || len(params) == 0 {
		return nil, errors.New("empty params")
	}

	extras := []string{}
	for _, x := range params {
		_extra, err := _generateExtra(x.ContractAbi, x.ContractAddress, x.MethodName, x.MethodArgs...)
		if err != nil {
			return nil, err
		}
		extras = append(extras, _extra)
	}

	res := fmt.Sprintf("%04x", len(extras))
	for _, item := range extras {
		res += item
	}

	return hex.DecodeString(res)
}
```

注：

- js 中用 https://docs.ethers.io/v5/api/utils/abi/coder/#AbiCoder-encode 替代 `contractABI.Pack`

通过 mixin payment 调用 mvm

mixin js sdk 中有现成的方法，不需要自己封装，下面 go 写的仅作参考。

```
func GetMemo(extra []byte) string {
	op := &encoding.Operation{
		Purpose: encoding.OperationPurposeGroupEvent,
		Process: config.RegistryProcess(),
		Extra:   extra,
	}
	return base64.RawURLEncoding.EncodeToString(op.Encode())
}

func generateTransferInput(assetId string, amount decimal.Decimal, extra []byte) (*mixin.TransferInput, error) {
	trace, err := uuid.NewV4()
	if err != nil {
		return nil, err
	}
	input := mixin.TransferInput{
		AssetID: assetId,
		Amount:  amount,
		TraceID: trace.String(),
		Memo:    GetMemo(extra),
	}
	input.OpponentMultisig.Receivers = config.RegistryReceivers()
	input.OpponentMultisig.Threshold = config.RegistryThreshold()
	return &input, nil
}

func CallContractFromMixin(client *mixin.Client, pin string, assetId string, amount decimal.Decimal, extra []byte) (*mixin.RawTransaction, error) {
	input, err := generateTransferInput(assetId, amount, extra)
	if err != nil {
		return nil, err
	}
	return client.Transaction(context.Background(), input, pin)
}

func GeneratePaymentUrl(client *mixin.Client, assetId string, amount decimal.Decimal, extra []byte) (string, error) {
	input, err := generateTransferInput(assetId, amount, extra)
	if err != nil {
		return "", err
	}
	pay, err := client.VerifyPayment(context.Background(), *input)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("mixin://codes/" + pay.CodeID), nil
}
```

#### extra 超长

先将上面生成的 extra 写入 storage 合约，write 方法申明：`function write(uint256 _key, bytes memory raw)`，`key` 的值：`keccak256(raw)`

mvm invoke 时用的 extra： `registry pid` + `storage address` + `key`

### debug

- 在区块链浏览器上打开 registry 合约
- 找到自己调用的记录，点开，选择 `Logs` ，然后搜索 `ProcessCalled`
