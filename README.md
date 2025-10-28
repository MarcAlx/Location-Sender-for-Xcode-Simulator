# Location Sender for Xcode Simulator

Simple app to ease custom location sending to Xcode Simulator.


📍 Send location by searching an address or clicking on map
![](./demo/v2.0.0/search-demo.gif)

🏁 Automate location sending by providing a GeoJSON
![](./demo/v2.0.0/routing-demo.gif)

## A note on routing mode

### Playback capabilities

- Play/Pause
- Reset
- Loop
- Playback rate control (from 100ms to 5s)
- Playback feedback on map (green part is what has been played)

### GeoJSON

Routing mode relies on [GeoJSON](https://geojson.org) file. 

This way you can provide your own route made of WGS84 coordinates. Your GeoJSON may contain the following objects :
 
| Objects | Behavior |
| - | - |
| Linestring | Each point will be considered as part of the route | 
| MultiPoint | Each point will be considered as part of a single line/route |
| Polygon | Each point will be considered as part of a single line/route |
| MultiLineString | Only first line will be considered as route |
| MultiPolygon | Only first polygon will be considered as route |
| Feature | Geometry will be considered if it matches one of the previous enumerated type |
| FeatureCollection | First feature with a supported geometry type will be considered |

_n.b as a result, every geometry made of less than two points are incompatible._

You can find sample [GeoJSON](https://geojson.org) files [here](./samples/).

Build your own via [geojson.io](https://geojson.io/)!

## Considered features (ETA, when it's done)

- Route playback based on speed instead of point rate
- Add support for modern app icon via [./src/LocationSenderForSimulator/Icon.icon](./src/LocationSenderForSimulator/Icon.icon) 

_n.b this app is not compatible with App Sandbox_

## Changelog

### v2.0.0

- [routing] Introduce routing mode via GeoJSON file
- [search] It's now possible to send every location 
- [general] Improved UX

### v1.0.0

- First version

## Resources

`cellphone-marker.svg` used in AppIcon came from [https://pictogrammers.com](https://pictogrammers.com), and is relased under the following [Pictogrammers Free License](https://pictogrammers.com/docs/general/license/).