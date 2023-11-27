require 'test_helper'

class CurrentWeatherControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_template 'index'
  end

  test "should get temperature if params are valid" do
    params = { zipcode: '12345', country: 'US' }
    get :get_temperature, params: params
    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal true, json_response['success']
    assert_not_nil json_response['temperature']
    assert_not_nil json_response['cached']
  end

  test "should return error if required params are not sent" do
    params = { zipcode: '', country: '' }
    expected_message = 'Zipcode & Country must be present'

    get :get_temperature, params: params

    json_response = JSON.parse(response.body)
    assert_equal false, json_response['success']
    assert_equal expected_message, json_response['error']
    assert_response :unprocessable_entity
  end

  test "should return error if country  is not sent" do
    params = { zipcode: '12', country: '' }
    expected_message = 'Zipcode & Country must be present'

    get :get_temperature, params: params

    json_response = JSON.parse(response.body)
    assert_equal false, json_response['success']
    assert_equal expected_message, json_response['error']
    assert_response :unprocessable_entity
  end

  test "should return error if zipcode is  not sent" do
    params = { zipcode: '', country: 'ss' }
    expected_message = 'Zipcode & Country must be present'

    get :get_temperature, params: params

    json_response = JSON.parse(response.body)
    assert_equal false, json_response['success']
    assert_equal expected_message, json_response['error']
    assert_response :unprocessable_entity
  end

  test "return error if invalid zipcode is" do
    params = { zipcode: 'sds', country: 'ss' }
    expected_message = 'Invalid Zipcode. Zipcode should be a number'

    get :get_temperature, params: params

    json_response = JSON.parse(response.body)
    assert_equal false, json_response['success']
    assert_equal expected_message, json_response['error']
    assert_response :unprocessable_entity
  end

  test "should return error if invalid country code is sent" do
    params = { zipcode: '123456', country: '11s' }
    expected_message = 'Invalid Country Code. Country code should be a string of alphabets'

    get :get_temperature, params: params

    json_response = JSON.parse(response.body)
    assert_equal false, json_response['success']
    assert_equal expected_message, json_response['error']
    assert_response :unprocessable_entity
  end

  test "should return error if country is not servicable" do
    params = { zipcode: '123456', country: 'ss' }
    expected_message = 'Sorry! We currently do not provide services to this country'

    get :get_temperature, params: params

    json_response = JSON.parse(response.body)
    assert_equal false, json_response['success']
    assert_equal expected_message, json_response['error']
    assert_response :unprocessable_entity
  end
end
