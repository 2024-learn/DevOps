const express = require('express');
const redis = require('redis');

const app = express();
const client = redis.createClient({
    host: 'redis-server',
    port: 6379 // default redis port
});
client.set('visits', 0);

app.get('/', (req, res) => {
    // process.exit(0);
    client.get('visits', (err, visits) => {
        res.send('Number of visit is ' + visits);
        client.set('visits', parseInt(visits) + 1);
    });
});

app.listen(8081, () => {
    console.log('Listening on port 4000');
});

//status codes
// 0 => exited and everything is okay
// 1,2,3,etc => exited because something went wrong