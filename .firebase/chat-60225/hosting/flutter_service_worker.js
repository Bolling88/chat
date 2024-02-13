'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"version.json": "32412dec1a4d3565a69feaddffdacb3c",
"index.html": "dede6f31f0ffd86f628c12b86346bab1",
"/": "dede6f31f0ffd86f628c12b86346bab1",
"main.dart.js": "8db29577c19b0545967f5dfc81aad657",
"flutter.js": "7d69e653079438abfbb24b82a655b0a4",
"favicon.png": "cbcc93af5b152b0b388d71cc19320a38",
"icons/Icon-192.png": "cbcc93af5b152b0b388d71cc19320a38",
"icons/Icon-maskable-192.png": "cbcc93af5b152b0b388d71cc19320a38",
"icons/Icon-maskable-512.png": "cb25cc53f3c83c3b8711811784933548",
"icons/Icon-512.png": "cb25cc53f3c83c3b8711811784933548",
"manifest.json": "58a762bda9828071184caf6a80558713",
"assets/AssetManifest.json": "dcbee5c056196a5a2198d2a1c4ef8b75",
"assets/NOTICES": "daeff7ca530f47694e33427da79ea4dc",
"assets/FontManifest.json": "7b2a36307916a9721811788013e65289",
"assets/AssetManifest.bin.json": "f3788010a9952211ba2adf7cd6f73cc5",
"assets/packages/giphy_get/assets/img/GIPHY_light.png": "7c7ed0e459349435c6694a720236d5f4",
"assets/packages/giphy_get/assets/img/poweredby_dark.png": "e4fe68503ab5d004deb31e43636a0a7c",
"assets/packages/giphy_get/assets/img/poweredby_light.png": "439da1ed3ca70fb090eb98698485c21e",
"assets/packages/giphy_get/assets/img/GIPHY_dark.png": "13139c9681ad6a03a0f4a45030aee388",
"assets/shaders/ink_sparkle.frag": "4096b5150bac93c41cbc9b45276bd90f",
"assets/AssetManifest.bin": "56eafecaa3fbe08081bb379969afb464",
"assets/fonts/MaterialIcons-Regular.otf": "b3ac1740202eff41c5fcd495d54f55a8",
"assets/assets/flutter_i18n/de.json": "c912bff994bed2476cd4163ac4c4fafb",
"assets/assets/flutter_i18n/ru.json": "d6cbbcbf6dad56c0941f89fa7a40a768",
"assets/assets/flutter_i18n/pt.json": "89b86328bfc6b000214b506fa5ebb17a",
"assets/assets/flutter_i18n/en.json": "004e0ec23e408470dbc9b65e046df2ec",
"assets/assets/flutter_i18n/pa.json": "6d6d5a95afc371fa05d3c9317941c505",
"assets/assets/flutter_i18n/ne.json": "e68a09e904216fb0566d5181603ff4ca",
"assets/assets/flutter_i18n/fr.json": "acf6c38735a0a873900735fb52143048",
"assets/assets/flutter_i18n/hi.json": "78a93775ded7548acc11f596a098c9a7",
"assets/assets/flutter_i18n/sv.json": "7cec7192bae3c87cb632e7b4e7e92ae6",
"assets/assets/flutter_i18n/es.json": "c0561356c9a2e6eb909174cab632b94b",
"assets/assets/flutter_i18n/ar.json": "7bc9a185200fef9139fa7e8544b69b27",
"assets/assets/html/privacy.md": "baa1ce167310d33a452979a6dbe5052c",
"assets/assets/html/copyright.md": "e2b05842d4bcfde06aa48ff6993651fb",
"assets/assets/html/terms.md": "8ffd7f2b3e0afd0d4042a40a7a4523ff",
"assets/assets/html/eula.md": "75c675f5be004120a702f06821deaeed",
"assets/assets/img/apple.png": "4f658b9a7d067de5238644b78d8d09cc",
"assets/assets/img/google.png": "ca2f7db280e9c773e341589a81c15082",
"assets/assets/lottie/premium.json": "64f3d0b9b40eb7fe287f08078920971e",
"assets/assets/lottie/premium_button.json": "c7b2e10882972675f34c688fdb262b2a",
"assets/assets/lottie/chest.json": "5d5f65b8ada0534c384edac11d5e902c",
"canvaskit/skwasm.js": "87063acf45c5e1ab9565dcf06b0c18b8",
"canvaskit/skwasm.wasm": "2fc47c0a0c3c7af8542b601634fe9674",
"canvaskit/chromium/canvaskit.js": "0ae8bbcc58155679458a0f7a00f66873",
"canvaskit/chromium/canvaskit.wasm": "143af6ff368f9cd21c863bfa4274c406",
"canvaskit/canvaskit.js": "eb8797020acdbdf96a12fb0405582c1b",
"canvaskit/canvaskit.wasm": "73584c1a3367e3eaf757647a8f5c5989",
"canvaskit/skwasm.worker.js": "bfb704a6c714a75da9ef320991e88b03"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"assets/AssetManifest.json",
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
