require "json"

STDOUT.sync = true

module Web

  class Resource < Sinatra::Base

    helpers do

      def protected!
        show_request
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? && @auth.basic? && @auth.credentials &&
          @auth.credentials == [ENV['HEROKU_USERNAME'], ENV['HEROKU_PASSWORD']]
      end

      def show_request
        body = request.body.read
        unless body.empty?
          STDOUT.puts "request body:"
          STDOUT.puts(@json_body = JSON.parse(body))
        end
        unless params.empty?
          STDOUT.puts "params: #{params.inspect}"
        end
      end

      #def json_body
      #  @json_body || (body = request.body.read && JSON.parse(body))
      #end

    end

    get '/' do
      'works!'
    end

    # provision
    post '/' do
      protected!
      status 201
      resource = Database.create
      {id: resource.id, config: {"MYSQL_ADDON_DATABASE_URL" => resource.url}}.to_json
    end

    # deprovision
    delete '/:id' do
      protected!
      resource = Database.find(params[:id].to_s)
      resource.destroy
      "ok"
    end

    # plan change
    put '/:id' do
      protected!
      resource = Database.find(params[:id].to_s)
      #resource.plan = json_body['plan']
      {}.to_json
    end

  end

end
