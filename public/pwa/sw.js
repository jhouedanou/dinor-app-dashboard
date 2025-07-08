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
    "url": "assets/Badge.Bj4qGncG.js",
    "revision": null
  }, {
    "url": "assets/Badge.Id9DJ0yZ.css",
    "revision": null
  }, {
    "url": "assets/BannerSection.CYcXX-pp.js",
    "revision": null
  }, {
    "url": "assets/BannerSection.hXsewFe2.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.CBPAEsFF.css",
    "revision": null
  }, {
    "url": "assets/CookiePolicy.Cpj-IBq9.js",
    "revision": null
  }, {
    "url": "assets/DinorTV.B_QjgwLu.css",
    "revision": null
  }, {
    "url": "assets/DinorTV.CeasCwml.js",
    "revision": null
  }, {
    "url": "assets/EventDetail.42WhEGqo.css",
    "revision": null
  }, {
    "url": "assets/EventDetail.BGGsx2wJ.js",
    "revision": null
  }, {
    "url": "assets/EventsList.CuvQF2FA.js",
    "revision": null
  }, {
    "url": "assets/EventsList.D0Dw3tkF.css",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.C66P9zRd.js",
    "revision": null
  }, {
    "url": "assets/FavoriteButton.CJo52RHZ.css",
    "revision": null
  }, {
    "url": "assets/Home.Bor0wsJb.js",
    "revision": null
  }, {
    "url": "assets/Home.DeS83HLX.css",
    "revision": null
  }, {
    "url": "assets/index.DF5o7KZL.css",
    "revision": null
  }, {
    "url": "assets/index.DSySyJtv.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.BpmfM2Bt.js",
    "revision": null
  }, {
    "url": "assets/LikeButton.Cxg4SQ2v.css",
    "revision": null
  }, {
    "url": "assets/PagesList.C8e3BZ9t.css",
    "revision": null
  }, {
    "url": "assets/PagesList.DZj2o1uQ.js",
    "revision": null
  }, {
    "url": "assets/Predictions.Ccc_wFpF.css",
    "revision": null
  }, {
    "url": "assets/Predictions.ZqdI0sOb.js",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.6cp9vVfC.css",
    "revision": null
  }, {
    "url": "assets/PredictionsLeaderboard.VUfKrJAd.js",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.B4nF0aVF.css",
    "revision": null
  }, {
    "url": "assets/PredictionsTeams.DKx0pozh.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.Cau-mQy-.js",
    "revision": null
  }, {
    "url": "assets/PrivacyPolicy.DeflSHSI.css",
    "revision": null
  }, {
    "url": "assets/Profile.7ypi-PZp.js",
    "revision": null
  }, {
    "url": "assets/Profile.C-ytjVNy.css",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.CTv8Mbqn.css",
    "revision": null
  }, {
    "url": "assets/RecipeDetail.YPMBywxQ.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.C8sgsRc9.js",
    "revision": null
  }, {
    "url": "assets/RecipesList.CBXzT_R2.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.BHT7mAes.css",
    "revision": null
  }, {
    "url": "assets/SearchAndFilters.C7GShrRz.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.BjM5jobA.js",
    "revision": null
  }, {
    "url": "assets/TermsOfService.DiEZV5Dq.css",
    "revision": null
  }, {
    "url": "assets/TipDetail.CKDGDmas.js",
    "revision": null
  }, {
    "url": "assets/TipDetail.DmWKKydn.css",
    "revision": null
  }, {
    "url": "assets/TipsList.Cubx72i1.css",
    "revision": null
  }, {
    "url": "assets/TipsList.DRfGmxyS.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.DqXc5942.js",
    "revision": null
  }, {
    "url": "assets/Tournaments.DXBB89nw.css",
    "revision": null
  }, {
    "url": "assets/useApi.5y9sJIfb.js",
    "revision": null
  }, {
    "url": "assets/useComments.f2f6vNAY.js",
    "revision": null
  }, {
    "url": "assets/utils.l0sNRNKZ.js",
    "revision": null
  }, {
    "url": "assets/vendor.CgTKjNNK.js",
    "revision": null
  }, {
    "url": "assets/WebEmbed.BMjAmuFs.css",
    "revision": null
  }, {
    "url": "assets/WebEmbed.C8dbaPx3.js",
    "revision": null
  }, {
    "url": "index.html",
    "revision": "15ecafaf1b5c9a4052156a877dff6414"
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
