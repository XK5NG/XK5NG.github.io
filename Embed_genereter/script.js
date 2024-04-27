const form = document.getElementById('webhook-form');
const titleInput = document.getElementById('title');
const descriptionInput = document.getElementById('description');
const imageUrlInput = document.getElementById('image-url');
const webhookCodeOutput = document.getElementById('webhook-code');

form.addEventListener('submit', (event) => {
  event.preventDefault();

  const title = titleInput.value.trim();
  const description = descriptionInput.value.trim();
  const imageUrl = imageUrlInput.value.trim();

  // Get current date and time
  const currentDate = new Date();

  // Format the date and time
  const formattedDate = currentDate.toLocaleDateString('en-US', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  });
  const formattedTime = currentDate.toLocaleTimeString('en-US', {
    hour: '2-digit',
    minute: '2-digit',
  });

  let webhookCode = `
<title>${title}</title>
<meta content="${description}" property="og:description" />
<meta content="${title}" property="og:title" />
<meta content="" property="og:url" />`;

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
<meta name="pubdate" content="${formattedDate} ${formattedTime}">
`;

  webhookCodeOutput.textContent = webhookCode;
});

function isValidUrl(url) {
  const urlPattern = /(http|https):\/\/(\w+:{0,1}\w*@)?(\S+(:\d+)?)(\/?|\/\w+\.)*\.\w{2,}(\/\w+)*\/?/gi;
  return urlPattern.test(url);
}

const copyButton = document.getElementById('copy-button');

copyButton.addEventListener('click', () => {
  const codeText = webhookCodeOutput.textContent;

  if (navigator.clipboard) {
    navigator.clipboard.writeText(codeText).then(() => {
      alert('Copied to clipboard!');
    }, () => {
      alert('Failed to copy to clipboard!');
    });
  } else {
    const textArea = document.createElement('textarea');
    textArea.value = codeText;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    textArea.remove();
  }
});
