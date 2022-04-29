require "test_helper"

class ApiControllerTest < ActionDispatch::IntegrationTest
  test "ping" do
    get api_ping_url
    assert_response :success
    ret_obj = @response.parsed_body
    assert_equal true, ret_obj['success']
  end

  test "redirect to not found" do
    get '/api/doesnotexist'
    assert_redirected_to root_path
    get root_path
    assert_response :missing
  end

  test "get posts needs tag" do
    get api_posts_url
    assert_response 400
    assert_match /Tags.*/, @response.parsed_body['error']
    # but fake tags should be ok
    get api_posts_url, params: { tags: 'fake' }
    assert_response :success
    assert_empty @response.parsed_body['posts']
  end

  test "get posts fail on bad optional params" do
    get api_posts_url, params: { tags: 'tech', sortBy: 'dislikes' }
    assert_response 400
    assert_match /sortBy.*/, @response.parsed_body['error']
    get api_posts_url, params: { tags: 'tech', direction: 'sideways' }
    assert_response 400
    assert_match /direction.*/, @response.parsed_body['error']
  end
end
