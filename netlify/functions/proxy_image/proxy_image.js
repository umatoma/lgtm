const fetch = require('node-fetch');

exports.handler = async (event, context) => {
    try {
        const url = event.queryStringParameters.url;
        const res = await fetch(url);
        const buffer = await res.buffer();
        const base64 = buffer.toString('base64');
        const headers = {
            'content-type': res.headers.get('content-type'),
            'content-length': res.headers.get('content-length'),
            'access-control-allow-origin': '*',
        };
        return {
            statusCode: 200,
            headers: headers,
            isBase64Encoded: true,
            body: base64,
        };
    } catch (e) {
        return {
            statusCode: 500,
            body: e.message,
        };
    }
}