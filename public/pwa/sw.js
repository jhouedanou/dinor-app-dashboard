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
    "url": "assets/Badge.0upxbKjS.js",
    "revision": null
  }, {
    "url": "assets/Badge.Id9DJ0yZ.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.C_QZPgCv.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.CMVqwP19.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.C6AC2RrU.js",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.B_QjgwLu.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.D1_DSTZh.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.B9sGsjCV.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.gFsqTIsV.css",
    "revision": null
  }, {
    "url": "assets/EventsList.DKdPWiZo.css",
    "revision": null
  }, {
    "url": "assets/EventsList.DTQtSIHQ.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.Bv8YWZtt.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.CJo52RHZ.css",
    "revision": null
  }, {
    "url": "assets/Home.D__NtDlJ.js",
    "revision": null
  }, {
    "url": "assets/Home.Z4cHVvid.css",
    "revision": null
  }, {
    "url": "assets/index.BRBqb7Zw.js",
    "revision": null
  }, {
    "url": "assets/index.qS64aFQt.css",
    "revision": null
  }, {
    "url": "assets/LikeButton.Cxg4SQ2v.css",
    "revision": null
  }, {
    "url": "assets/LikeButton.DvAaTAbG.js",
    "revision": null
  }, {
    "url": "assets/PagesList.C8e3BZ9t.css",
    "revision": null
  }, {
    "url": "assets/PagesList.D6uotahN.js",
    "revision": null
  }, {
    "url": "assets/Predictions.CSxoNvLu.css",
    "revision": null
  }, {
    "url": "assets/Predictions.qCdW4CJN.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.6cp9vVfC.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.BWMKhIKF.js",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.B4nF0aVF.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.DHFMkyD_.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.B9mUGJ1w.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/Profile.CNpfp7p8.css",
    "revision": null
  }, {
    "url": "assets/Profile.DcSbHLUh.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.BGfISsQv.css",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.BtHp0pD9.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.CBXzT_R2.css",
    "revision": null
  }, {
    "url": "assets/RecipesList.fv0KSDHW.js",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.BIUnG-Rk.js",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.DhpLTWqq.css",
    "revision": null
  }, {
    "url": "assets/TermsOfService.Cyb4_HYb.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TipDetail.DCmZ-tLH.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.DmWKKydn.css",
    "revision": null
  }, {
    "url": "assets/TipsList.BjsJjff6.js",
    "revision": null
  }, {
    "url": "assets/TipsList.Cubx72i1.css",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.8IwLQpVq.js",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.CBsS1oMN.css",
    "revision": null
  }, {
    "url": "assets/Tournaments.CORkKjXO.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.DXBB89nw.css",
    "revision": null
  }, {
    "url": "assets/useApi.-JiNL5_S.js",
    "revision": null
  }, {
    "url": "assets/useComments.q8Z1xK1C.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.h2smxeay.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.BW_q2Y0J.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.CcOeVZaS.css",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "fe2f914681e30649b2f23c0edae3b37a"
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
