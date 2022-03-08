ABOUT
=====
This is a macOS port of [dlrudie/Snip](https://github.com/dlrudie/Snip) written in Swift.
This program will generate a text file in your documents folder containing the currently playing song on spotify.

It currently only supports the [Spotify](https://www.spotify.com/) API.

IN DEVELOPMENT
=====
WIP:
* Output formatting support

In the future I want to support most if not all of the features that the original Snip program supports.
This includes:
* Choosing the output directory (pretty basic)
* Downloading the album artwork
* Support for the iTunes API

DISCLAIMER
=====
The program saves your Spotify **display name**, **access token** and **refresh token** with the [user-read-recently-played](https://developer.spotify.com/documentation/general/guides/authorization/scopes/#user-read-currently-playing) scope in [UserDefaults](https://developer.apple.com/documentation/foundation/userdefaults) which is **not** encrypted.

Using the access/refresh token someone can:
- Access publicly available information: that is, only information normally visible in the Spotify desktop, web, and mobile players.
- Get Read access to your recently played tracks.

They **cannot**:
- Log into your account
- Change your login credentials
- Change your user settings
- Use your account to play music
- See your private information

If you are concerned about the points mentioned in the first section of the disclaimer I advise you to not use this program.
