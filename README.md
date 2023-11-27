# README

* Ruby version
- 2.7.5

* Configuration
- Application written in rails framework
- uses Rails version `6.1.7`

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

* ...
# Weather-App
# API Documentation

## 1. Basic Form

The APP has a basic form with two mandatory fields: `zipcode` and `country`. This form is accessible at the root path of the app.

### Endpoint GET /

## 2. Get Temperature

On submitting the form, the API makes a GET call to retrieve the temperature.

### Endpoint GET /get_temperature

### Request Parameters

- `zipcode` (mandatory): The postal code for the location.
- `country` (mandatory): The country of the location.

### Response

The API responds with a JSON object in the following format:

```json
{
  "success": true,
  "temperature": {current: 25.3, min: 23.4, max: 23.9},
  "cached": true/false  
}

### Request Parameters

- `zipcode` (mandatory): The postal code for the location.
- `country` (mandatory): The country of the location.

### Response

The API responds with a JSON object in the following format:

```json
{
  "success": true,
  "temperature": {current: 25.3, min: 23.4, max: 23.9},
  "cached": true/false
}

- success (boolean): Indicates whether the request was successful.
- temperature (json): Current, min, max temperature values for the specified location.
- cached (boolean): Indicates whether the temperature value was retrieved from a cache.
