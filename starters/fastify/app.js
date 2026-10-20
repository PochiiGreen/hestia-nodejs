{
  "name": "hestia-express-app",
  "version": "1.0.0",
  "description": "Express application deployed via HestiaCP & PM2",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "node --watch app.js"
  },
  "dependencies": {
    "dotenv": "^16.4.5",
    "express": "^4.19.2"
  }
}
