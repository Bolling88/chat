'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "5a8ac0ed1915c96ddd35b3ecd8a201d7",
"index.html": "37badda2b6112a9538921f8e5d66fac4",
"/": "37badda2b6112a9538921f8e5d66fac4",
"main.dart.js": "22a9b7161fae192a77f2801124d4089f",
"flutter.js": "c71a09214cb6f5f8996a531350400a9a",
"favicon.png": "cbcc93af5b152b0b388d71cc19320a38",
"icons/Icon-192.png": "cbcc93af5b152b0b388d71cc19320a38",
"icons/Icon-maskable-192.png": "cbcc93af5b152b0b388d71cc19320a38",
"icons/Icon-maskable-512.png": "cb25cc53f3c83c3b8711811784933548",
"icons/Icon-512.png": "cb25cc53f3c83c3b8711811784933548",
"manifest.json": "58a762bda9828071184caf6a80558713",
"assets/AssetManifest.json": "1c992f67e3bfd7b140897ad9b8dafe1a",
"assets/NOTICES": "343b2932d6921440a4749a5771d0d484",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "462979f387c1472a1afca199f0d44f6a",
"assets/packages/giphy_get/assets/img/GIPHY_light.png": "7c7ed0e459349435c6694a720236d5f4",
"assets/packages/giphy_get/assets/img/poweredby_dark.png": "e4fe68503ab5d004deb31e43636a0a7c",
"assets/packages/giphy_get/assets/img/poweredby_light.png": "439da1ed3ca70fb090eb98698485c21e",
"assets/packages/giphy_get/assets/img/GIPHY_dark.png": "13139c9681ad6a03a0f4a45030aee388",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/AssetManifest.bin": "84465fb42f8192c2fbf417d1a0978bc3",
"assets/fonts/MaterialIcons-Regular.otf": "25456ff969ccb5de5bc2831c954c9d70",
"assets/assets/flutter_i18n/de.json": "abfa726b20c244f8cefbe64c57716e11",
"assets/assets/flutter_i18n/ru.json": "d9f32f5d591476838a217d977f22d820",
"assets/assets/flutter_i18n/pt.json": "4d075280e5c99f280187f516011d954b",
"assets/assets/flutter_i18n/en.json": "2b6376be5e299c0f616775f0713a9c91",
"assets/assets/flutter_i18n/pa.json": "a6db0770d3b50d6c44b89c80003477a5",
"assets/assets/flutter_i18n/ne.json": "e76f7eb4706e61c163a35a73225abf1b",
"assets/assets/flutter_i18n/fr.json": "52a641cbbc3acf105b1d12ac317a59b1",
"assets/assets/flutter_i18n/hi.json": "9bcd7a1f9fd75a4e67e39ddb1dbd0eb7",
"assets/assets/flutter_i18n/sv.json": "c3b5b0080dd9eb305237bc263bc174a4",
"assets/assets/flutter_i18n/es.json": "1f34db8dc2e3b0961c48458ccf066824",
"assets/assets/flutter_i18n/ar.json": "2368dcbd4026e5a0f48ab0f9afc9febb",
"assets/assets/html/privacy.md": "baa1ce167310d33a452979a6dbe5052c",
"assets/assets/html/copyright.md": "e2b05842d4bcfde06aa48ff6993651fb",
"assets/assets/html/terms.md": "8ffd7f2b3e0afd0d4042a40a7a4523ff",
"assets/assets/html/eula.md": "75c675f5be004120a702f06821deaeed",
"assets/assets/img/apple_big.png": "3946b985144a2787feab681ca076412b",
"assets/assets/img/apple.png": "4f658b9a7d067de5238644b78d8d09cc",
"assets/assets/img/google_big.webp": "835a538df9cefd5bf549762d05fe9c49",
"assets/assets/img/google.png": "ca2f7db280e9c773e341589a81c15082",
"assets/assets/lottie/premium.json": "64f3d0b9b40eb7fe287f08078920971e",
"assets/assets/lottie/premium_button.json": "c7b2e10882972675f34c688fdb262b2a",
"assets/assets/lottie/chest.json": "5d5f65b8ada0534c384edac11d5e902c",
"assets/assets/ml_models/nude.tflite": "7bf99f388eba7c63f05131ebd4adcc9e",
"canvaskit/skwasm.js": "445e9e400085faead4493be2224d95aa",
"canvaskit/skwasm.js.symbols": "741d50ffba71f89345996b0aa8426af8",
"canvaskit/canvaskit.js.symbols": "38cba9233b92472a36ff011dc21c2c9f",
"canvaskit/skwasm.wasm": "e42815763c5d05bba43f9d0337fa7d84",
"canvaskit/chromium/canvaskit.js.symbols": "4525682ef039faeb11f24f37436dca06",
"canvaskit/chromium/canvaskit.js": "43787ac5098c648979c27c13c6f804c3",
"canvaskit/chromium/canvaskit.wasm": "f5934e694f12929ed56a671617acd254",
"canvaskit/canvaskit.js": "c86fbd9e7b17accae76e5ad116583dc4",
"canvaskit/canvaskit.wasm": "3d2a2d663e8c5111ac61a46367f751ac",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
