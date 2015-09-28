#Meetup-finder Demo

iOS app that allow users to find the upcoming technology meetups near their current location, using the [meetup.com API] (https://secure.meetup.com/meetup_api).

## Specs
- Swift 2.0
- iOS 9 compatible
- Created using XCode 7

## Getting Started
1. Clone this repository.
2. Open the project in XCode.
3. Open config.plist and set your Meetup.com API Key value in 'wsAPIKey'. This key is required to make every request to the Meetup API.
4. Build and run the app.

## Features
1. Meetup-finder allows users to see a list of upcoming technology meetups around their area by launching the app.
2. Users can locate and browse the events locations using the Map View.
3. More detailed information about the event is provided to the users an event is selected.
4. Users are able to add the event into their iCloud Calendar from the Detail Information View.

## API methods implemented
1. [/topics] (http://www.meetup.com/meetup_api/docs/topics/) to get all the "Tech" related topics. The urlkeys in the response are being sent as a parameter when requesting the meetups.
2. [/2/open_events] (http://www.meetup.com/meetup_api/docs/2/open_events/) to get all the upcoming public events hosted by Meetup groups.
3. [/2/groups] (http://www.meetup.com/meetup_api/docs/2/groups/) to get detailed information about the Meetup groups.

## Third-party frameworks/libraries 
Third-party open source framewors are used within this app:

1. [RestKit](https://github.com/RestKit/RestKit) - For consuming and modeling RESTful web resources
2. [SDWebImage](https://github.com/rs/SDWebImage) - Asynchronous image downloader with cache support*

Installed via the [CocoaPods](http://cocoapods.org/) dependency management tool, as it makes managing dependencies in the code easier.

``` bash
platform :ios, '8.4'

target 'Meetup Finder' do

pod 'RestKit', '~>  0.24.1'
pod 'SDWebImage', '~> 3.7'

end
```


*For downloading Meetup.com's group photos - Update: Feature removed from this version to avoid credentials to be blocked. Meetup.com allows only a maximum number of requests that can be made in a window of time. Clients that issue too many requests in a short period of time will be blocked for an hour. However, you can find the implementation to request the photos in DataManager.swif
