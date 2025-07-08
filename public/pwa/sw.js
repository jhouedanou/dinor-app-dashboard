/**
 * Copyright 2018 Google Inc. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *     http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// If the loader is already loaded, just stop.
if (!self.define) {
  let registry = {};

  // Used for `eval` and `importScripts` where we can't get script URL by other means.
  // In both cases, it's safe to use a global var because those functions are synchronous.
  let nextDefineUri;

  const singleRequire = (uri, parentUri) => {
    uri = new URL(uri + ".js", parentUri).href;
    return registry[uri] || (
      
        new Promise(resolve => {
          if ("document" in self) {
            const script = document.createElement("script");
            script.src = uri;
            script.onload = resolve;
            document.head.appendChild(script);
          } else {
            nextDefineUri = uri;
            importScripts(uri);
            resolve();
          }
        })
      
      .then(() => {
        let promise = registry[uri];
        if (!promise) {
          throw new Error(`Module ${uri} didn’t register its module`);
        }
        return promise;
      })
    );
  };

  self.define = (depsNames, factory) => {
    const uri = nextDefineUri || ("document" in self ? document.currentScript.src : "") || location.href;
    if (registry[uri]) {
      // Module is already loading or loaded.
      return;
    }
    let exports = {};
    const require = depUri => singleRequire(depUri, uri);
    const specialDeps = {
      module: { uri },
      exports,
      require
    };
    registry[uri] = Promise.all(depsNames.map(
      depName => specialDeps[depName] || require(depName)
    )).then(deps => {
      factory(...deps);
      return exports;
    });
  };
}
define(['./workbox-fb107ff4'], (function (workbox) { 'use strict';

  self.skipWaiting();
  workbox.clientsClaim();

  /**
   * The precacheAndRoute() method efficiently caches and responds to
   * requests for URLs in the manifest.
   * See https://goo.gl/S9QRab
   */
  workbox.precacheAndRoute([{
    "url": "assets/Badge.C1oBZDgE.js",
    "revision": null
  }, {
    "url": "assets/Badge.Id9DJ0yZ.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.Dia6K6xN.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.hXsewFe2.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.DG3T3unO.js",
    "revision": null
  }, {
    "url": "assets/DinorTV.B_QjgwLu.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.sFZs4eUi.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.Bnc6hQw4.css",
    "revision": null
  }, {
    "url": "assets/EventDetail.CM6gv3-l.js",
    "revision": null
  }, {
    "url": "assets/EventsList.BsZoLR4J.js",
    "revision": null
  }, {
    "url": "assets/EventsList.CbJQnL3v.css",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.BoFSTRW8.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.CJo52RHZ.css",
    "revision": null
  }, {
    "url": "assets/Home.BQTJSwcD.css",
    "revision": null
  }, {
    "url": "assets/Home.Dd52L0DX.js",
    "revision": null
  }, {
    "url": "assets/index.5t7qZfv1.css",
    "revision": null
  }, {
    "url": "assets/index.XHIxoS6z.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.BJL69eBX.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.Cxg4SQ2v.css",
    "revision": null
  }, {
    "url": "assets/PagesList.BUn6IA0a.js",
    "revision": null
  }, {
    "url": "assets/PagesList.C8e3BZ9t.css",
    "revision": null
  }, {
    "url": "assets/Predictions.C04acH9k.css",
    "revision": null
  }, {
    "url": "assets/Predictions.CwVTi9p8.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.DuLj1F0l.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.FNkssmND.js",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.Bxaa6x5e.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.CBbvCYiy.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.C95YL_bj.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/Profile.Cn5JPCj5.css",
    "revision": null
  }, {
    "url": "assets/Profile.DuGN-WqH.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.DdAzDlS4.css",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.uCiDGjlm.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.B1eUzoRy.css",
    "revision": null
  }, {
    "url": "assets/RecipesList.x6VyGgQB.js",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.BtyA_H3d.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.BWj8BrqP.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TermsOfService.us_x7z9Z.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.BObdZMQ9.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.Lgfflgvx.css",
    "revision": null
  }, {
    "url": "assets/TipsList.Cubx72i1.css",
    "revision": null
  }, {
    "url": "assets/TipsList.fBpo4zkF.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.BR02gkK7.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.D85W8BP-.css",
    "revision": null
  }, {
    "url": "assets/useApi.6L1KSNKU.js",
    "revision": null
  }, {
    "url": "assets/useComments.CUBUA6fe.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.CgTKjNNK.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.CKL2zDmX.css",
    "revision": null
  }, {
    "url": "assets/WebEmbed.CL59VtT0.js",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "39f09dc2a182c6bc3b929e2a08a81a46"
  }, {
    "url": "registerSW.js",
    "revision": "36a8c3eb862bdcf4382e8845651d1c5f"
  }, {
    "url": "manifest.webmanifest",
    "revision": "33839ebbad69569bcfaa929012fa5165"
  }], {});
  workbox.cleanupOutdatedCaches();
  workbox.registerRoute(new workbox.NavigationRoute(workbox.createHandlerBoundToURL("index.html")));
  workbox.registerRoute(/^https:\/\/.*\/api\//, new workbox.NetworkFirst({
    "cacheName": "api-cache",
    plugins: [new workbox.ExpirationPlugin({
      maxEntries: 100,
      maxAgeSeconds: 600
    })]
  }), 'GET');
  workbox.registerRoute(/\.(?:png|jpg|jpeg|svg|gif|webp)$/, new workbox.CacheFirst({
    "cacheName": "images-cache",
    plugins: [new workbox.ExpirationPlugin({
      maxEntries: 50,
      maxAgeSeconds: 2592000
    })]
  }), 'GET');

}));
