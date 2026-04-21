class FrontendController < ActionController::Base
  def show
    render file: Rails.public_path.join("index.html"), layout: false, content_type: "text/html"
  end
end
