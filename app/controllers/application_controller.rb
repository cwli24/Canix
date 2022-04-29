class ApplicationController < ActionController::API
    def not_found
        # This method of returning html doesn't require additional modules for an API controller
        page_content = '<h1>Not Found</h1>
        The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.'
        render html: page_content.html_safe, :status => :not_found
    end
end
