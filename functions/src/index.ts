import { URLSearchParams } from 'url';
import * as functions from 'firebase-functions';
import fetch from 'node-fetch';

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
