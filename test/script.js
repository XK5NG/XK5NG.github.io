const form = document.getElementById('webhook-form');
const descriptionInput = document.getElementById('description');
const imageUrlInput = document.getElementById('image-url');
const webhookCodeOutput = document.getElementById('webhook-code');

form.addEventListener('submit', (event) => {
  event.preventDefault();

  const description = descriptionInput.value.trim();
  const imageUrl = imageUrlInput.value.trim();

  let webhookCode = `
<title>XK5NG</title>
<meta content="${description}" property="og:description" />
<meta content="XK5NG" property="og:title" />
<meta content="https://xk5ng.github.io/embeds" property="og:url" />`;

  if (imageUrl) {
    if (isValidUrl(imageUrl)) {
      webhookCode += `
<meta content="${imageUrl}" property="og:image" />`;
    } else {
      alert('Please enter a valid image URL.');
    }
  }

  webhookCode += `
<meta name="twitter:card" content="summary_large_image" />
<meta content="#6600ff" data-react-helmet="true" name="theme-color" />
`;

  webhookCodeOutput.textContent = webhookCode;
});

function isValidUrl(url) {
  const urlPattern = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+(:\d+)?)(\/?|\/\w+\.)*\.\w{2,}(\/\w+)*\/?/gi;
  return urlPattern.test(url);
}
