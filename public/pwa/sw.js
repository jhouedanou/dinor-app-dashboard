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
    "url": "assets/Badge.CyRVNslW.css",
    "revision": null
  }, {
    "url": "assets/Badge.g1NdF9e_.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.CMVqwP19.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.DpAOc3th.js",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.sp7o9PFO.js",
    "revision": null
  }, {
    "url": "assets/DinorTV.Dg3lzYbb.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.fy6fMgaz.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.BVAqvM5L.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.WLZIMIs3.css",
    "revision": null
  }, {
    "url": "assets/EventsList.CtgWx6d_.js",
    "revision": null
  }, {
    "url": "assets/EventsList.DKdPWiZo.css",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.HOKXQ-I5.css",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.qSpgtnK0.js",
    "revision": null
  }, {
    "url": "assets/Home.4R0HFCAY.css",
    "revision": null
  }, {
    "url": "assets/Home.CjcPzMlR.js",
    "revision": null
  }, {
    "url": "assets/index.BKNIucqc.css",
    "revision": null
  }, {
    "url": "assets/index.EH2eMeZJ.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.Bzko3SW-.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.DCsx9HV7.css",
    "revision": null
  }, {
    "url": "assets/PagesList.B4hFMhqb.css",
    "revision": null
  }, {
    "url": "assets/PagesList.Cwna7M3e.js",
    "revision": null
  }, {
    "url": "assets/Predictions.CrMfaMxi.js",
    "revision": null
  }, {
    "url": "assets/Predictions.DSa3Y-AN.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.B-ofz_tb.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.D8Fsuwim.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.B2N2jqx8.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.BVy4Xryy.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.CwVrB8bz.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/Profile.agKGjPyr.js",
    "revision": null
  }, {
    "url": "assets/Profile.Ejzdf5GE.css",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.DqdRmeDv.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.DWK8hMlH.css",
    "revision": null
  }, {
    "url": "assets/RecipesList.B4yB4IWL.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.CEsnQzT2.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.D7oYactt.js",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.DhpLTWqq.css",
    "revision": null
  }, {
    "url": "assets/TermsOfService.CoGikbsM.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TipDetail.Cu8RqVjM.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.D6kw8lRb.css",
    "revision": null
  }, {
    "url": "assets/TipsList.BFkvQqZq.css",
    "revision": null
  }, {
    "url": "assets/TipsList.CnzNoz-n.js",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.BnIiBiUJ.css",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.D0_qLsV5.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.B5MFIoVu.css",
    "revision": null
  }, {
    "url": "assets/Tournaments.BVFp01LW.js",
    "revision": null
  }, {
    "url": "assets/useApi.9wKjDGJj.js",
    "revision": null
  }, {
    "url": "assets/useComments.B069oZKo.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.Bvrl98ec.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.7JmI38mu.css",
    "revision": null
  }, {
    "url": "assets/WebEmbed.CXiRzr7I.js",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "6d6ee8a58c1404c18cc92a23d61bedab"
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
