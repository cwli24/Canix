# Simple JSON API
The task was to write a simple backend JSON API that requests data from an external server based on user requests, using the Rails framework.
This was implemented as an API controller via Rails, with the addition of multi-threaded requests and response data caching.

_Author's note: This is my first Ruby & Rails program (usage), so there's likely coding improvement possible. In the debugging process, I also spun up a ticket about the type of content Rail's cache can store. That's tracked here:_ https://github.com/rails/rails/issues/44982

### Setup
Run `bundle install` in the directory to load all the Gems and dependencies.

Run `rails server` to test the API on localhost default port 3000

Run `rails test` for Minitest

### API
`localhost:3000/api/ping` - test that it's working, should return a success response json

`localhost:3000/api/posts` - grab all the unique 'post' objects from https://api.hatchways.io/assessment/blog/posts
* (required) `?tags=___` - comma-delimited, 1 or more tag associated with posts
* (optional) `&sortBy=___` - ['id', 'reads', 'likes', 'popularity'] sorting category
* (optional) `&direction=___` - ['asc', 'desc'] sorting order

Any other paths will redirect you to root `/` with 404. 
