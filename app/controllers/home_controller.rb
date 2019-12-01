# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render html: '<h1>Hello World!!</h1>'.html_safe
  end
end