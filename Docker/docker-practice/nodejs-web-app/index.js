// require the express library specified in the package.json file
const express = require('express');

const app = express();

// setup a single route handler:
app.get('/', (req, res) => {
    res.send('Hi There from Phyllisland!');
});

// set a port for application to listen to:
app.listen(8080, () => {
    console.log('listening on port 8080');
});




// comments for package.json
// in order for our app to work correctly, we need a copy of express: * (any version)
// start command in "scripts" => "node index.js" will get the server up and running