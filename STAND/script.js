const ownerUsernameInput = document.getElementById('ownerUsername');
const standUsernameInput = document.getElementById('standUsername');
const generateButton = document.getElementById('generateButton');
const generatedCodeTextarea = document.getElementById('generatedCode');
const copyButton = document.getElementById('copyButton');
const copyMessage = document.getElementById('copyMessage');

// Initially set the generated code textarea to an empty string (optional)
generatedCodeTextarea.value = '';

generateButton.addEventListener('click', () => {
  const ownerUsername = ownerUsernameInput.value;
  const standUsername = standUsernameInput.value;

  const generatedCode = `getgenv()._=
"This script made by xk5ng | 808188341547565097 | If you pay for this script you get scammed LMAO | This script is completely free ok | Please kill yourself if you sell this script | On god skibidi rizzler meow gyat ohio sigma | https://discord.gg/msgabv2t9Q | https://discord.gg/stando"

getgenv().Accounts = {OWNER = '${ownerUsername}', STAND = '${standUsername}'}

  --\\-- Stand-Configuration --//--

getgenv().StandConfig = {
    --\\-- ! Main ! --//--
    ['Position'] = 'Back', --Position Of Stand [Back | Left | Right]
    ['CrewID'] = 32570691, --Must Be In Group For It To Work
    ['Attack'] = 'Heavy', --Heavy = Super Punch Light = Spam Punch [Heavy | Light]
    ['StandMode'] = 'TheWorld', --[Star Platinum : OverHeaven | Star Platinum: The World | Star Platinum, Za Warudo! | TheWorld | Cmoon | King Crimson | Killer Queen | MIH | D4C]
    ['FlyMode'] = 'Glide', --[Glide | FlyV1 | FlyV2 | Hover | Heaven ]
    ['Pred'] = 0.34, --Prediction For Attack Or Targetting
    ['AutoPred'] = 0.23, --Prediction For Attack Or Targetting
    ['GunPred'] = 0.037, --Gun prediction [this is auto prediction sets]
    ['AutoPredic'] = false, --[true | false] Turn On Or Off Auto Prediction 
    ['AttackMode'] = 'Sky', --[Sky | Under] If [Sky] The Stand Will Attack Infront Of Target And If [Under] The Stand Will Attack In Underground
    ['GunMode'] = 'Under', --[Sky | Under]  The Stand Will Shooting Just Like What In The Settings
    ['GunType'] = 'Lmg', --[Lmg | Aug]  The Stand Will Shooting Just Like What In The Settings
    ['Resolver'] = false, --[true | false] Turn On Or Off Resolver If Someone Using Anti Lock
    --\\-- ! Antilock ! --//--
    ['SkyAmount'] = 1600, --Sky Velocity
    --\\-- ! Misc ! --//--
    ['AutoSaveLocation'] = '1', --[1 | 2]. '1' is bank food shop rooftop, '2' is "DA FURNITURE" Rooftop
    ['AttackDistance'] = 75, --Attack distance for "Attack!, Stab!, Gkill!" max distance
    ['Smoothing'] = false, --[true | false] If [false] Less Delays And if [true] The Stand Movement Will Smooth But Kinda Delayed
    ['CustomPrefix'] = '.', --[ ! | / | . | ? | > | < | $ | ; | : ] Custom target prefix
    ['CustomSummon'] = 'Summon!', --Custom [Summon!] Text
    ['SummonPoses'] = 'Pose1', --[false | Pose1 | Pose2 | Pose3]
    ['LowGraphics'] = false, --[true | false] Turns graphics down so your stand doesnt lag too much
    ['AntiStomp'] = true, --[true | false] The Stand Will Cannot Be Stomped Or Grabbed
    ['CustomNAME'] = 'Master', --Custom Name Text Default Is [Master] Example Of it 'Im Here, Master'
    ['Hidescreen'] = false, --[true | false] If [true] You WIll See White Blank Screen But The Performance Is Gonna Be Good]
    ['ChatCmds'] = true, --[true | false] Chatted When You Use Some Command
    ['MaskMode'] = 'Breathing', --[Surgeon | Paintball | Skull | Pumpkin | Hockey | Ninja | Riot | Breathing] The Stand Will Buy The Mask You Selected
    ['AutoMask'] = true, --[true | false] Auto Buy Mask When The St    and Respawn
    ['FPSCAP'] = false, --[false | 'NUMBER'] This is so your main account gets the most fps (MAXED IS 60, SUGGEST 30 FPS ON STANDS)
    ['Msg'] = 'Yare Yare Daze.', --When You Say [/e msg] It Makes All The Alts Say That Message
    ['Alt'] = false, --keep this false
    --//    ! Sounds !     \\--
    --\\ MUST HAVE BOOMBOX //--
    ['Sounds'] = true, --[true | false]
    ['CustomSong'] = 6703926669, --Enter A Song ID And Say 'Song!'
    ['SummonMusic'] = true, --[true | false]
    ['SummonMusicID'] = 'Default' -- Enter a Sound ID Put [Default] If You Would Like The Default Sound
}loadstring(game:HttpGet("https://xk5ng.github.io/V4.5"))()`;

  generatedCodeTextarea.value = generatedCode;
});

copyButton.addEventListener('click', () => {
  generatedCodeTextarea.select();
  document.execCommand('copy');
  copyMessage.textContent = 'Code copied!';
  setTimeout(() => {
    copyMessage.textContent = '';
  }, 2000);
});
