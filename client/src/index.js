var ERC20_token_address = "0x28092De136685a45F09B5B420C0d225b9EC1E636"
var contract
var erc_contract
var accounts
var web3
var previous_player_state = null

const updateDice = async () => {
  console.log("Polling state...")
  
  /*
  pipi = await contract.methods.pipi().call()
  console.log(pipi)
  */
  player_state = await contract.methods.player_state(accounts[0]).call()
  player_matchx = await contract.methods.player_match(accounts[0]).call()
  player_attackerx = await contract.methods.attacker_characters(player_matchx, 0).call()
  player = await contract.methods.player(player_matchx).call()
  logger = await contract.methods.logger().call()

  console.log("==========")
  console.log(player_state)
  console.log(player_matchx)
  console.log(player_attackerx)
  console.log(player)
  console.log(logger)
  console.log("==========")
  //setDice(parseInt(previous_dice_result))
  if(previous_player_state != "waiting for oracle" && player_state == "waiting for oracle")
  {
    ui_msg.text = "Waiting for oracle..."
  }

  if(previous_player_state != "match generated" && player_state == "match generated")
  {
    ui_msg.text = "Match generated..."
    if(!update_lock)
    {
      update_lock = true
      player_match = await contract.methods.player_match(accounts[0]).call()
      attacks = []
      for(i=0; i<4; i++)
      {
        player_attacker = await contract.methods.attacker_characters(player_match, i).call()
        player_attacked = await contract.methods.attacked_characters(player_match, i).call()
        damage_dealt = await contract.methods.damage_dealt(player_match, i).call()
        attacks.push({
          attacker: characters[player_attacker],
          attacked: characters[player_attacked],
          damage: damage_dealt})
      }
      ui_msg.text = ""
      console.log(attacks)
      playMatch()
    }
  }

  previous_player_state = player_state
  
  
};

const roll = async () => {
  var random_seed = "1234"
  ui_msg.text = "Waiting for matic..."
  await contract.methods
    .roll(random_seed)
    .send({ from: accounts[0], gas: 400000 },
    function(err, res){
    })
  //updateDice()
}


const approve = async () => {
  var approval_value = "1000000000000000000000"
  await erc_contract.methods
    .approve(ERC20_token_address, approval_value)
    .send({ from: accounts[0], gas: 400000 })
  updateDice()
}

async function maticDiceGameApp() {
  var awaitWeb3 = async function() {
    web3 = await getWeb3();
    var awaitContract = async function() {
      contract = await getGameContract(web3)
      var awaitERCContract = async function() {
        erc_contract = await getMyERC20Contract(web3)
        var awaitAccounts = async function() {
          accounts = await web3.eth.getAccounts()
          //updateDice()
        }
        awaitAccounts()
      }
      awaitERCContract()
    }
    awaitContract()
  }
  awaitWeb3()
}
maticDiceGameApp()


var display_click_count_poller = setInterval(updateDice,5000)