# README

* Ruby version
  - 2.7.5

* Configuration
  - Application written in rails framework
  - uses Rails version `6.1.7`
  - uses external service called OpenWeather to get the weather data. This service requires an api key which is saved in credentials.yml.enc file. Master key to decrypt this will be shared on email. 

* Database creation
  - No database used 

* Database initialization
  - No database used

* How to run the test suite
  - run `rails test` on the terminal

* Services (job queues, cache servers, search engines, etc.)
  - Configured cache for development environment. 
  - Used "file store" to store the cached values

* Deployment instructions
  - run `bundle install` 
  - run `npm install` 
  - run `rails s` to run the server
  - run `rails dev:cache` to set up cache in development environment

# Weather-App
# API Documentation

## 1.Endpoint: GET / 

The APP root_path has a basic form with two mandatory fields: `zipcode` and `country`. This form is accessible at the root path of the app.

## 2. Endpoint: GET /get_temperature

On submitting the form, the API makes a GET call to retrieve the temperature.

### Request Parameters

- `zipcode` (mandatory): The postal code for the location.
- `country` (mandatory): The country code of the location.
#### Note
  - As per my research zipcode is not unique. Therefore, we need to consider country too to get the output as expected by the user.
  - To handle validations for zipcode per country(as different countries have different formats), I have considered only 2 countries ie USA (US) & IN (IN) due to time constraints
  - Querying the countries out of this scope returns an error saying that "We do not provide services for this country"
  - Zipcode validation is also written according to the regex of the format for only these 2 countries
     
### Response

The API responds with a JSON object in the following format:

```
{
  "success": true,
  "temperature": {current: 25.3, min: 23.4, max: 23.9},
  "cached": true/false  
}
```

- success (boolean): Indicates whether the request was successful.
- temperature (json): Current, min, max temperature values for the specified location.
- cached (boolean): Indicates whether the temperature value was retrieved from a cache.

### Example

- Request
GET /get_temperature?zipcode=500019&country=IN

- Response
```
{
  "success": true,
  "temperature": {
    "current": 29.76,
    "max": 29.76,
    "min": 29.25
  },
  "cached": true
}

```


### Error Handling
If there are errors in the request, the API will respond with an appropriate error message.

Example:
(External api errors handled in our server)  
```
{
  "success": false,
  "temperature": null,
  "error": "Sorry! We currently do not have the data for these parameters.",
  "cached": true
}

```
(Validation error sent by our application server)
```
{
  "success": false,
  "error": "Sorry! We currently do not provide services to this country"
}
```
Following HTTP status codes are sent in case of errors
- 422 - Validation errors handled in our application backend
- 400 - Bad request - invalid or missing parameters to external api service
- 401 - Unauthorized. External API api key is not granted access
- 404 - Data not found in the external api service database
- 429 - Too Many Requests to external api
- 503 - External service not reachable

# Project Flow Documentation

## Get / 
- Triggers CurrentWeatherController, index action
- This serves app/views/current_weather/index.html.erb template
- This template consists of a form with zipcode, country fields
- On submit, it makes an ajax call to the `GET /get_temperature` route with the form fields as params
  ### Note
  * Can improve the code by implementing the following TODOs
    - Handle unpermitted parameters( using strong parameters feature of rails) by raising an exception or returning the error to the users

## GET /get_temperature
- Triggers CurrentWeatherController, get_temperature action
- Before_action filter is used which validates the params received. Below validations are handled at the backend
   - Required zipcode & country fields
   - Validation on the zipcode. Since we are currently considering only US & IN where these zipcodes are numbers only. Validation is done such that it *accepts only numbers*.
       - However, in future, when we provide services to more countries, this will have to be extended to handle other country formats too.
   - Validation on country such that it *accepts only letters*
   - Validation on the country input. If it requests, the **countries that we do not service**, then it returns errors.
   - Validation on the **zipcode pattern** for the country. If the zipcode does not match with the pattern for that country, it returns error that there is no zipcode with that value in that country
   - Above mentioned validation methods have been extracted to a **ValidationService** rails concern `app/controllers/concerns/validation_service.rb`
 - If the validations are all passed, the control goes to `get_temperature_by_zipcode` method
 - This and the helpers methods for `get_temperature_by_zipcode` are defined in `app/controllers/concerns/current_temperature_service.rb`
 - We are using an external api given by `https://openweathermap.org/current`. Since rails has a gem which is a ruby client for OpenWeather. We are using it for retrieving current temperature.
     - [Reference to the api] (https://openweathermap.org/current#zip)
     - [Reference to the open-weather-ruby-client] (https://github.com/dblock/open-weather-ruby-client)
 - **Open Weather external api requires us to use an api key. This key has been saved in credentials.yml.enc which is encrypted using the master key. The master key has been shared on email.**
 - Once the request is fetched using the api, it is **cached for 30 mins**. So that subsequent requests with the same zipcode is served from cache
  ## Note: 
  - Validation is done in a before_action filter. 
  - TODO: cache needs to be done before validation so that the invalid requests are also cached. 
 - When the request is served from cache, a flag is set to true and sent to the front end to indicate users that the request has been served from cache
 -  We are using filestore for storing the cache in development environment
     - Can implement redis in production
     - Currently, same status code is sent even for cached response. Ideally, good to send 304 reponse
     - Retry messages can be sent by considering the error respones of external api
       
## TODO: Tasks to be done before production deployment
- **Security** 
  - API authentication can be done by using the token system(csrf) , which gives responses to only authenticated users and return errors otherwise
  - Rate limiting - Can restrict the number of requests per x time to prevent abuse of the app.
- **Logging and Monitoring of the application** 
    - Configure logging and add various info/error logs.
    - For Monitoring in production, can configure external tools
- **Full Test coverage** - Added few tests but need to add more unit tests
- **Scaling** - Can consider tools like Kubernetes for scaling
- **Caching** - File_store has been used for caching in development. In Production, can consider redis or similar

   
