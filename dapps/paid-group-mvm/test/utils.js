const crypto = require('crypto');
const { BigNumber } = require('ethers');

function newUUID() {
  return crypto.randomUUID();
}

function newGroupID() {
  const uuid = newUUID();
  const str = "0x" + uuid.replace(/-/g, "");
  return BigNumber.from(str);
}

function newPrice() {
  const price = (Math.random() / 10).toFixed(4);
  return ethers.utils.parseEther(price);
}

// return 0 ~ 10 year seconds
function newDuration() {
  const oneYearSecond = 60 * 60 * 24 * 365;
  return parseInt(Math.random() * 10 * oneYearSecond);
}

function unixTimestamp() {
  return parseInt(Date.now() / 1000);
}

function newETHKey() {
  const id = crypto.randomBytes(32).toString('hex');
  const privateKey = "0x"+id;
  const wallet = new ethers.Wallet(privateKey);
  return privateKey, wallet.address;
}

module.exports = {
  newGroupID,
  newPrice,
  newDuration,
  unixTimestamp,
  newETHKey,
};
