const ownerUsernameInput = document.getElementById('ownerUsername');
const standUsernameInput = document.getElementById('standUsername');
const generateButton = document.getElementById('generateButton');
const generatedCodeTextarea = document.getElementById('generatedCode');
const copyButton = document.getElementById('copyButton');
const copyMessage = document.getElementById('copyMessage');

generateButton.addEventListener('click', () => {
  const ownerUsername = ownerUsernameInput.value;
  const standUsername = standUsernameInput.value;

  const generatedCode = `getgenv().Accounts = {OWNER = '${ownerUsername}', STAND = '${standUsername}'}\n`;

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
