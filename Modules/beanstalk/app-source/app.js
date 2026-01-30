const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.send(`
    <h1>Hello from AWS Elastic Beanstalk! 🌱</h1>
    <h2>Redneck Renovations 2026</h2>
    <p>Deployed with Terraform on ${new Date().toISOString()}</p>
  `);
});

app.listen(port, () => {
  console.log(`App listening at http://localhost:${port}`);
});