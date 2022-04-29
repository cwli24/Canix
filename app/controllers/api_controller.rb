require 'http'
require 'concurrent'

class ApiController < ApplicationController
  EXTDATA_URL = 'https://api.hatchways.io/assessment/blog/posts'  # This is the URL to retrieve data from

  def ping
    response = { :success => true }
    render json: response, :status => :ok
  end

  def posts
    tags, sort_by, direction = params.values_at(:tags, :sortBy, :direction)
    # Check for missing or bad fields, and set default values.
    if tags.nil?
      resp_error "Tags parameter is required"
      return
    end
    if sort_by && !['id', 'reads', 'likes', 'popularity'].include?(sort_by)
      resp_error "sortBy parameter is invalid"
      return
    end
    if direction && !['asc', 'desc'].include?(direction)
      resp_error "direction parameter is invalid"
      return
    end
    sort_by ||= 'id'
    direction ||= 'asc'

    # Call main helper to get the requested data
    ret = fetch_data_for_tags tags.split(','), sort_by, direction

    render json: { :posts => ret }, :status => :ok
  end

  ###############################################################
  private

  def resp_error(msg)
    render json: { :error => msg }, :status => :bad_request
  end

  ##
  # Takes in an array of tags, and fetch data associated with each tag from a defined URL. The data is
  # amassed into a json, sorted by a field in either ascending or descending order.
  def fetch_data_for_tags(tags, sort_by, direction)
    fetch_requests = Array.new(tags.size)
    allTagPosts = Concurrent::Hash.new                    # threads-shared hash to store all the unique posts (by ID) retrieved

    # Make a HTTP GET thread for each tag (execute inline).
    (0...tags.size).each do |idx|
      fetch_requests[idx] = Thread.new do
        # Grab the data from cache, or fetch it if it doesn't exist yet
        tag_posts = Rails.cache.fetch( tags[idx], expires_in: 3.hours, race_condition_ttl: 2, skip_nil: true) do
          response = HTTP.get(EXTDATA_URL, :params => {:tag => tags[idx]}).parse['posts']   # cache will not(cannot) store raw HTTP responses
          if response.empty?
            nil   # Discard/don't store invalid tags which returns an empty json object
          else
            response
          end
        end

        tag_posts&.each do |post|
          post_id = post['id']
          next if allTagPosts.has_key?(post_id)    # we don't need to include a post already seen
          allTagPosts[post_id] = post              # but if we haven't, collate it
        end
      end
    end
    fetch_requests.each(&:join)         # let threads finish gathering all of the unique posts first

    # Extract the posts and sort them as dictated by the params.
    sorted_posts = allTagPosts.values
    if direction == 'desc'
      sorted_posts.sort! { |p1, p2| p2[sort_by] <=> p1[sort_by] }
    else
      sorted_posts.sort! { |p1, p2| p1[sort_by] <=> p2[sort_by] }
    end
    return sorted_posts
  end
end
