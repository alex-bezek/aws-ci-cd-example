# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    render html: '<h1>Look, it did CI/CD!!!</h1>'.html_safe
  end
end