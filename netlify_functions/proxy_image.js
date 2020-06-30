const fetch = require('node-fetch');

exports.handler = async (event, context) => {
    try {
        const body = JSON.parse(event.body);
        const res = await fetch(body.imageURL);
        const buffer = await res.buffer();
        const base64 = buffer.toString('base64');
        return {
            statusCode: 200,
            body: base64,
        };
    } catch (e) {
        return {
            statusCode: 500,
            body: e.message,
        };
    }
}