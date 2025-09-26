const express = require('express');
const app = express();
const port = process.env.PORT || 3000;

app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.get('/', (req, res) => {
  res.send(`<h1>CI/CD Web App</h1><p>Deployed at ${new Date().toISOString()}</p>`);
});

app.listen(port, () => {
  console.log(`App listening on port ${port}`);
});
