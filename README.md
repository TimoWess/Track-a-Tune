ABOUT
=====
Track-a-Tune tries to bring the functionality of [dlrudie/Snip](https://github.com/dlrudie/Snip) to mac OS using Swift.
This program will generate a text file in your documents folder containing the currently playing song on spotify in a format of your choosing.

It currently only supports the [Spotify](https://www.spotify.com/) API.

HOW TO USE
=====
### Authentication
1. Download the zip file containing the app and extract it
2. Open the app
3. A browser window will open, requesting you to log in with your Spotify credentials
4. If the app displays a text saying you are logged in you are done with the authentication step
5. If the app still only shows that "Log in" button there was an error accessing the auth code from the redirect. In that case press the "Log in" button
6. A browser window will open, requesting you to log in with your Spotify credentials
7. Should the app again not log you in automatically there will be a text field titled "Auth code"
8. Paste the auth code from the redirect url into the text field and press the "Request Access Token" button
9. You should now be logged in

### Formatting

There are 4 different replacement strings available:
* $$t -> Track title
* $$a -> Artist name
* $$l -> Album name
* $$n -> New line character
Input your desired output format into the text field

#### Example:
* Formatting string:	$$l - $$t by $$a 
* Output:				*Album name* - *Track title* by *Artist name*

IN DEVELOPMENT
=====
WIP:
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
