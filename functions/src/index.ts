import { URLSearchParams } from 'url';
import * as functions from 'firebase-functions';
import fetch from 'node-fetch';
import * as GM from 'gm';

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//
// export const helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

export const searchImages = functions.https.onCall((data, context) => {
    return (async () => {
        const query = (data.query as string)?.trim();
        if (query === null || query === undefined || query === '') {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'The functions must be called with "query" argument.'
            );
        }

        const params = new URLSearchParams();
        params.set('cx', '015696260223066657084:ox8zgs27vlu');
        params.set('key', 'AIzaSyDECcGBgA9o-GcfOeutIrbhBGa3UgRXXnA');
        params.set('searchType', 'image');
        params.set('q', query);

        const baseUrl = 'https://customsearch.googleapis.com/customsearch/v1';
        const url = `${baseUrl}?${params.toString()}`;
        console.log('url', url);

        const res = await fetch(url);
        const json = await res.json();
        console.log('json', json);

        return json;
    })();
});

export const createLgtmImage = functions.https.onCall((data, context) => {
    return (async () => {
        const image = (data.image as string)?.trim();
        if (image === null || image === undefined || image === '') {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'The functions must be called with "image" argument.'
            );
        }

        const gm = GM.subClass({ imageMagick: true });
        const buffer = Buffer.from(image, 'base64');

        const imageBuffer: Buffer = await new Promise((resolve, reject) => {
            gm(buffer)
                .resize(500)
                .font('Helvetica.ttf', 128)
                .fill('white')
                .stroke('black', 1)
                .drawText(0, 0, 'LGTM', 'Center')
                .toBuffer((err, value) => {
                    if (err) {
                        reject(err);
                    } else {
                        resolve(value);
                    }
                });
        });
        const base64 = imageBuffer.toString('base64');
        return {
            image: base64,
        };
    })();
});