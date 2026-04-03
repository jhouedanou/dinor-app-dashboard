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
    "url": "assets/Badge.BjoXA8fU.js",
    "revision": null
  }, {
    "url": "assets/Badge.CyRVNslW.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.CEMBqZ46.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.DHGVKDjO.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.BmIn_ohX.js",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.CUxzk6Un.js",
    "revision": null
  }, {
    "url": "assets/DinorTV.Dg3lzYbb.css",
    "revision": null
  }, {
    "url": "assets/EventDetail.CelBZMyC.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.D3519ub4.css",
    "revision": null
  }, {
    "url": "assets/EventsList.Bss-KOk6.js",
    "revision": null
  }, {
    "url": "assets/EventsList.DKdPWiZo.css",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.BDFn55TC.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.HOKXQ-I5.css",
    "revision": null
  }, {
    "url": "assets/Home.CqhinK6W.css",
    "revision": null
  }, {
    "url": "assets/Home.CxgRE9lj.js",
    "revision": null
  }, {
    "url": "assets/index.Bp0EUSzT.css",
    "revision": null
  }, {
    "url": "assets/index.D-yLDInQ.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.CN9_gs8d.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.DCsx9HV7.css",
    "revision": null
  }, {
    "url": "assets/PagesList.BDjeEwhH.css",
    "revision": null
  }, {
    "url": "assets/PagesList.CGF4ckFk.js",
    "revision": null
  }, {
    "url": "assets/Predictions.BglOaVlq.js",
    "revision": null
  }, {
    "url": "assets/Predictions.DSa3Y-AN.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.BXwLLt_q.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.D8Fsuwim.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.B2N2jqx8.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.C7a2DuTL.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.ClpmuCXo.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/Profile.BtcN_gh2.css",
    "revision": null
  }, {
    "url": "assets/Profile.DkqyAlS2.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.BfaXyNVE.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.CikpOQcH.css",
    "revision": null
  }, {
    "url": "assets/RecipesList.4PdiVt5Q.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.CEsnQzT2.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.CJv66M1U.js",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.DhpLTWqq.css",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TermsOfService.Dn-fC4sa.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.BuEkexk6.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.D6kw8lRb.css",
    "revision": null
  }, {
    "url": "assets/TipsList.BFkvQqZq.css",
    "revision": null
  }, {
    "url": "assets/TipsList.CFQh-hrx.js",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.BnIiBiUJ.css",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.D50tU6zq.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.15L4g23Q.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.B5MFIoVu.css",
    "revision": null
  }, {
    "url": "assets/useApi.gSM7bNGz.js",
    "revision": null
  }, {
    "url": "assets/useComments.CTfKxgWC.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.Cc77-dxn.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.7JmI38mu.css",
    "revision": null
  }, {
    "url": "assets/WebEmbed.Bfcg9e5b.js",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "01b0157176555de3635d4849c5871de2"
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
