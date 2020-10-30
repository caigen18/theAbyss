#/%::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%%
#/%:::::$²²²²²²²²²²²²²$::::::::::::::::::::$²²²²²²²²²²²²²²²²²²²²²²²²²²²²²S:::::%%
#/%:::::$   [enter]   $::::::::::::::::::::$                             $:::::%%
#/%:::::$sssssssssssss$::::::::::::::::::::$     -x-  ABY/v0 -x-         $:::::%%
#/%:::::::::   ::::::::::::::::::::::::::::$                             $:::::%%
#/%:::::::: .' ::::   _  ::::::::::::::::::$  :/ solidity : m4ss, VAC    $:::::%%
#/%:::::: .$ :: _.x%$$$%x. ::::::::::::::::$  :/ design   : VAC, m4ss    $:::::%%
#/%:the: x$': .x$$$$²²'   `sSSs :::::::::::$  :/ IO :     : 1unacy       $:::::%%
#/%:::: ,$²  x$$$$²'     : `²²'       :::::$  :/ stack    : m4ss         $:::::%%
#/%:::: $$  x$$$$'  s$$$s  s$$s s$$$$s. :::$  :/ counsel  : 7dlm         $:::::%%
#/%::: :$$.x$$$$'  $$² ²$$ $$$$ ss   $$. ::$  :/ math     : 1unacy, 7dlm $:::::%%
#/%::: :$$$$$$$$ : $$   $$ $$$$ $$ : $$: ::$  :/ stratagem: 1unacy, VAC  $:::::%%
#/%:::: $$$$$$$' : $$s s$$ $$$$ $$   $$' ::$                             $:::::%%
#/%:::: `$$$$$' ::: ²$$$²  ²$$² ²$$$$$² :::$                             $:::::%%
#/%::::: `²²² ::::::     ::    :       ::::$sssssssssssssssssssssssssssss$:::::%%
#/%fz::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::%%


from web3 import Web3
import settings
import config
import json
from setupWeb3 import w3

swapAbi = config.swapAbi
abi = json.loads(swapAbi)
swapAddress = config.swapAddress

swap = w3.eth.contract(address=swapAddress, abi=abi)

voidUserAdress = config.voidUserAddress
voidUserPk = config.voidUserPk

fromAddr = config.fromAddr
fromPk = config.fromPk

INFURA_API_KEY_MAIN = config.INFURA_API_KEY_MAIN
w3 = Web3(Web3.HTTPProvider("https://mainnet.infura.io/v3/" + INFURA_API_KEY_MAIN))

balance = 0
def mainLoop():
    global balance
    try:
        balance = w3.fromWei(w3.eth.getBalance(address), 'ether')
    except:
        print('ERROR reading balance')
    if balance > 0:
        # we have eth
        signed_txn = w3.eth.account.signTransaction(dict(
            nonce=w3.eth.getTransactionCount(fromAddr),
            gasPrice = w3.eth.gasPrice,
            gas = 100000,
            to=swapAddress,
            value=web3.toWei(balance,'ether')
          ),
          fromPk)

        w3.eth.sendRawTransaction(signed_txn.rawTransaction)
        bidPrice = swap.bidPrice({'type': 'market', 'amtEth': balance})
        transaction = swap.functions.short(voidUserAddress, 'market', balance).buildTransaction({'chainId': 1, 'gas':70000, 'nonce': w3.eth.getTransactionCount(voidUserAddress)})
        signed_txn = w3.eth.account.signTransaction(transaction, voidUserPk)
