module Pageflow
  class RobotsController < Pageflow::ApplicationController
    def show
      @entries = PublishedEntry.all(entry_request_scope)
      respond_to :text
    end

    private
    def entry_request_scope
      Pageflow.config.public_entry_request_scope.call(Entry, request)
    end

  end
end