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
    "url": "assets/Badge.DafUQRlF.js",
    "revision": null
  }, {
    "url": "assets/Badge.Id9DJ0yZ.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.CAZNiHOq.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.hXsewFe2.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CfTQYa8X.js",
    "revision": null
  }, {
    "url": "assets/DinorTV.B_QjgwLu.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.DWqjpANd.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.Bnc6hQw4.css",
    "revision": null
  }, {
    "url": "assets/EventDetail.nxB9YPed.js",
    "revision": null
  }, {
    "url": "assets/EventsList.CbJQnL3v.css",
    "revision": null
  }, {
    "url": "assets/EventsList.CXAHH82f.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.CJo52RHZ.css",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.DeF1KCrM.js",
    "revision": null
  }, {
    "url": "assets/Home.BQTJSwcD.css",
    "revision": null
  }, {
    "url": "assets/Home.Du9FguLP.js",
    "revision": null
  }, {
    "url": "assets/index.5t7qZfv1.css",
    "revision": null
  }, {
    "url": "assets/index.DJpaKxkf.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.CUeMSxan.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.Cxg4SQ2v.css",
    "revision": null
  }, {
    "url": "assets/PagesList.C8e3BZ9t.css",
    "revision": null
  }, {
    "url": "assets/PagesList.CcuBOXYV.js",
    "revision": null
  }, {
    "url": "assets/Predictions.BKY_LyuX.css",
    "revision": null
  }, {
    "url": "assets/Predictions.CsYJpsy_.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.8cjXLrtZ.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.DkhXjq0y.js",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.Bxaa6x5e.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.DbbI8WGT.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DcFy1qKT.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/Profile.DjXiUyff.css",
    "revision": null
  }, {
    "url": "assets/Profile.ljDOh6gz.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.D0mj4iiH.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.DdAzDlS4.css",
    "revision": null
  }, {
    "url": "assets/RecipesList.B1eUzoRy.css",
    "revision": null
  }, {
    "url": "assets/RecipesList.DRthvgZu.js",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.BtyA_H3d.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.Du8oB3Fb.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.Bip55IiF.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TipDetail.JE04GtUK.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.Lgfflgvx.css",
    "revision": null
  }, {
    "url": "assets/TipsList.BeTqAp-c.js",
    "revision": null
  }, {
    "url": "assets/TipsList.Cubx72i1.css",
    "revision": null
  }, {
    "url": "assets/Tournaments.BTCep8XF.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.D85W8BP-.css",
    "revision": null
  }, {
    "url": "assets/useApi.CdDFkX3O.js",
    "revision": null
  }, {
    "url": "assets/useComments.Bp6N9YRo.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.CgTKjNNK.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.BTc4-gUO.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.CKL2zDmX.css",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "5c1341bfb7c6fc964868806232bd7b60"
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
