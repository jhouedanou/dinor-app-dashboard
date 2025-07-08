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
    "url": "assets/Badge.CNGPDrCv.js",
    "revision": null
  }, {
    "url": "assets/Badge.Id9DJ0yZ.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.DmzHC45h.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.hXsewFe2.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CR2Q1wp9.js",
    "revision": null
  }, {
    "url": "assets/DinorTV.B_QjgwLu.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.CTgBaF-9.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.42WhEGqo.css",
    "revision": null
  }, {
    "url": "assets/EventDetail.Bzw2Up8G.js",
    "revision": null
  }, {
    "url": "assets/EventsList.D0Dw3tkF.css",
    "revision": null
  }, {
    "url": "assets/EventsList.DJHuMnhW.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.17FCFdzl.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.CJo52RHZ.css",
    "revision": null
  }, {
    "url": "assets/Home.5iAjwYTD.js",
    "revision": null
  }, {
    "url": "assets/Home.DeS83HLX.css",
    "revision": null
  }, {
    "url": "assets/index.BVqTe4Wo.js",
    "revision": null
  }, {
    "url": "assets/index.DF5o7KZL.css",
    "revision": null
  }, {
    "url": "assets/LikeButton.Cxg4SQ2v.css",
    "revision": null
  }, {
    "url": "assets/LikeButton.d8wMjEdR.js",
    "revision": null
  }, {
    "url": "assets/PagesList.C8e3BZ9t.css",
    "revision": null
  }, {
    "url": "assets/PagesList.RxxeSgbJ.js",
    "revision": null
  }, {
    "url": "assets/Predictions.Ccc_wFpF.css",
    "revision": null
  }, {
    "url": "assets/Predictions.DNrThQuD.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.6cp9vVfC.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.BViAzdRz.js",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.B4nF0aVF.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.D_Ee3Vi-.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DovUdt7A.js",
    "revision": null
  }, {
    "url": "assets/Profile.C-ytjVNy.css",
    "revision": null
  }, {
    "url": "assets/Profile.CXOCdJ_A.js",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.CTv8Mbqn.css",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.DvRjTxjl.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.BZUGVKwT.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.CBXzT_R2.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.BHT7mAes.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.ClTz3ss3.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DXea8RnF.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.DmWKKydn.css",
    "revision": null
  }, {
    "url": "assets/TipDetail.DneOqYIB.js",
    "revision": null
  }, {
    "url": "assets/TipsList.Cubx72i1.css",
    "revision": null
  }, {
    "url": "assets/TipsList.CyKQb_wu.js",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.9DZ9QV0q.js",
    "revision": null
  }, {
    "url": "assets/TournamentBetting.CBsS1oMN.css",
    "revision": null
  }, {
    "url": "assets/Tournaments.DmW-A6JG.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.DXBB89nw.css",
    "revision": null
  }, {
    "url": "assets/useApi.5h5onROK.js",
    "revision": null
  }, {
    "url": "assets/useComments.zh3_vmNZ.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.CgTKjNNK.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.B0iRHQSR.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.BMjAmuFs.css",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "ec0c217658acc7e103858f0274bd2a93"
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
